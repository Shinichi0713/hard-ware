// ============================================================================
// Module: viewshed_raycast_core
// Description: 3D Ray-Casting パイプラインによる Line-of-Sight (LOS) 遮蔽判定コア
// ============================================================================

module viewshed_raycast_core #(
    parameter int COORD_WIDTH   = 32,  // 座標データ幅 (固定小数点 16.16)
    parameter int SAMPLE_STEPS  = 16,  // 1視線あたりのサンプル分割数
    parameter int MEM_ADDR_W    = 10   // 地形BRAMアドレス幅
)(
    input  logic                   clk,
    input  logic                   rst_n,

    // 制御・データ入力
    input  logic                   start,
    input  logic [COORD_WIDTH-1:0] obs_x,
    input  logic [COORD_WIDTH-1:0] obs_y,
    input  logic [COORD_WIDTH-1:0] obs_z,
    input  logic [COORD_WIDTH-1:0] tgt_x,
    input  logic [COORD_WIDTH-1:0] tgt_y,
    input  logic [COORD_WIDTH-1:0] tgt_z,

    // 地形メモリ（BRAM）インターフェース
    output logic [MEM_ADDR_W-1:0]  terrain_mem_addr,
    input  logic [COORD_WIDTH-1:0] terrain_mem_rdata,

    // 判定結果出力
    output logic                   done,
    output logic                   is_visible
);

    // 固定小数点演算用定数 (16.16 Format)
    localparam logic [COORD_WIDTH-1:0] OBS_HEIGHT = 32'h0001_B333; // 1.7m (0x1.B333)

    typedef enum logic [1:0] {
        IDLE,
        RAYCAST,
        EVALUATE,
        DONE
    } state_t;

    state_t state;

    // 内部レジスタ
    logic [COORD_WIDTH-1:0] reg_obs_z_eye;
    logic signed [COORD_WIDTH-1:0] dx, dy, dz;
    logic [3:0] step_counter;
    logic       blocked;

    // 簡易XY座標 -> メモリアドレスマッピング関数
    function automatic logic [MEM_ADDR_W-1:0] coord_to_addr(
        input logic [COORD_WIDTH-1:0] x,
        input logic [COORD_WIDTH-1:0] y
    );
        // 上位ビットをインターリーブしてアドレス生成 (グリッドマッピングの簡略化)
        return {x[23:19], y[23:19]};
    endfunction

    // 視線補間サンプル位置計算
    logic [COORD_WIDTH-1:0] sample_x, sample_y, sample_z;
    
    always_comb begin
        // sample_xyz = obs_xyz + (delta_xyz * step / SAMPLE_STEPS)
        sample_x = obs_x + (dx * step_counter / SAMPLE_STEPS);
        sample_y = obs_y + (dy * step_counter / SAMPLE_STEPS);
        sample_z = reg_obs_z_eye + (dz * step_counter / SAMPLE_STEPS);
    end

    // 地形BRAM読出しアドレス設定
    assign terrain_mem_addr = coord_to_addr(sample_x, sample_y);

    // メインステートマシン ＆ パイプライン制御
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            done         <= 1'b0;
            is_visible   <= 1'b0;
            step_counter <= '0;
            blocked      <= 1'b0;
            dx           <= '0;
            dy           <= '0;
            dz           <= '0;
            reg_obs_z_eye<= '0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        reg_obs_z_eye <= obs_z + OBS_HEIGHT; // 目の高さ補正
                        dx            <= $signed(tgt_x) - $signed(obs_x);
                        dy            <= $signed(tgt_y) - $signed(obs_y);
                        dz            <= $signed(tgt_z) - $signed(obs_z + OBS_HEIGHT);
                        step_counter  <= 4'd1; // 始点直後はスキップ
                        blocked       <= 1'b0;
                        state         <= RAYCAST;
                    end
                end

                RAYCAST: begin
                    // 視線高度 vs 地形標高の比較
                    if (terrain_mem_rdata > sample_z) begin
                        blocked <= 1'b1; // 遮蔽発生
                    end

                    if (step_counter == (SAMPLE_STEPS - 1)) begin
                        state <= EVALUATE;
                    end else begin
                        step_counter <= step_counter + 1'b1;
                    end
                end

                EVALUATE: begin
                    is_visible <= ~blocked;
                    done       <= 1'b1;
                    state      <= DONE;
                end

                DONE: begin
                    done  <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule