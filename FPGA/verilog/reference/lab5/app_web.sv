// ============================================================================
// Module: tb_viewshed_top
// Description: ViewShed コア機能のテストベンチ（模擬地形BRAM連携）
// ============================================================================

`timescale 1ns / 1ps

module tb_viewshed_top;

    localparam int COORD_WIDTH  = 32;
    localparam int SAMPLE_STEPS = 16;
    localparam int MEM_ADDR_W   = 10;

    // クロック・リセット
    logic clk;
    logic rst_n;

    // DUT インターフェース
    logic                   start;
    logic [COORD_WIDTH-1:0] obs_x, obs_y, obs_z;
    logic [COORD_WIDTH-1:0] tgt_x, tgt_y, tgt_z;
    logic [MEM_ADDR_W-1:0]  terrain_mem_addr;
    logic [COORD_WIDTH-1:0] terrain_mem_rdata;
    logic                   done;
    logic                   is_visible;

    // 模擬 BRAM (地形標高データ)
    logic [COORD_WIDTH-1:0] terrain_bram [0:(1<<MEM_ADDR_W)-1];

    // DUT (Device Under Test) インスタンス
    viewshed_raycast_core #(
        .COORD_WIDTH(COORD_WIDTH),
        .SAMPLE_STEPS(SAMPLE_STEPS),
        .MEM_ADDR_W(MEM_ADDR_W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .obs_x(obs_x),
        .obs_y(obs_y),
        .obs_z(obs_z),
        .tgt_x(tgt_x),
        .tgt_y(tgt_y),
        .tgt_z(tgt_z),
        .terrain_mem_addr(terrain_mem_addr),
        .terrain_mem_rdata(terrain_mem_rdata),
        .done(done),
        .is_visible(is_visible)
    );

    // BRAM リード動作
    always_ff @(posedge clk) begin
        terrain_mem_rdata <= terrain_bram[terrain_mem_addr];
    end

    // クロック生成 (100MHz)
    always #5 clk = ~clk;

    // テストシナリオ
    initial begin
        // 初期化
        clk   = 0;
        rst_n = 0;
        start = 0;
        obs_x = '0; obs_y = '0; obs_z = '0;
        tgt_x = '0; tgt_y = '0; tgt_z = '0;

        // BRAM 初期化（デフォルト平坦地 10.0m）
        for (int i = 0; i < (1<<MEM_ADDR_W); i++) begin
            terrain_bram[i] = 32'h000A_0000; // 10.0 (16.16 固定小数点)
        end

        #20;
        rst_n = 1;
        #20;

        // --- シナリオ 1: 障害物なし（可視テスト） ---
        $display("--------------------------------------------------");
        $display("[Test 1] 障害物なしの平原テスト開始");
        obs_x = 32'h0014_0000; // 20.0m
        obs_y = 32'h0014_0000; // 20.0m
        obs_z = 32'h000C_0000; // 12.0m

        tgt_x = 32'h0050_0000; // 80.0m
        tgt_y = 32'h0050_0000; // 80.0m
        tgt_z = 32'h001E_0000; // 30.0m (UAV高度)

        start = 1;
        #10;
        start = 0;

        wait(done);
        #10;
        if (is_visible)
            $display("[SUCCESS] テスト 1: 視界良好 (可視: 赤判定対象)");
        else
            $display("[FAIL] テスト 1: 遮蔽検知エラー");

        #50;

        // --- シナリオ 2: 途中に高い山（障害物）を配置（不可視テスト） ---
        $display("--------------------------------------------------");
        $display("[Test 2] 視線上に山（標高50m）が存在する遮蔽テスト");
        
        // 視線通過経路のメモリに障害物を書き込み
        for (int i = 0; i < (1<<MEM_ADDR_W); i++) begin
            terrain_bram[i] = 32'h0032_0000; // 標高 50.0m
        end

        start = 1;
        #10;
        start = 0;

        wait(done);
        #10;
        if (!is_visible)
            $display("[SUCCESS] テスト 2: 遮蔽検知成功 (不可視: 青判定対象)");
        else
            $display("[FAIL] テスト 2: 遮蔽見逃しエラー");

        $display("--------------------------------------------------");
        $finish;
    end

endmodule

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