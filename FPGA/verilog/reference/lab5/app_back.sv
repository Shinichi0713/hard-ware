// ============================================================================
// Module: viewshed_web_top
// Description: Webアプリケーション(WASM/C++ API)とのインターフェースを持つ
//              SystemVerilog Viewshed 解析トップモジュール
// ============================================================================

`timescale 1ns / 1ps

module viewshed_web_top #(
    parameter int COORD_WIDTH  = 32, // 16.16 固定小数点
    parameter int MEM_ADDR_W   = 10, // 1024 セル BRAM
    parameter int MAX_WAYPOINTS= 64  // 最大処理ウェイポイント数
)(
    input  logic                   clk,
    input  logic                   rst_n,

    // --- Web API / BUS コマンド・コントロール ---
    input  logic                   web_cmd_valid,   // 設定更新フラグ
    output logic                   web_busy,        // 演算中フラグ
    output logic                   web_done,        // 演算完了フラグ

    // --- Web 経由のパラメータ入力 ---
    input  logic [COORD_WIDTH-1:0] web_obs_x,
    input  logic [COORD_WIDTH-1:0] web_obs_y,
    input  logic [COORD_WIDTH-1:0] web_obs_z,
    input  logic [COORD_WIDTH-1:0] web_obs_height,  // 監視者目線高さ (default 1.7m)
    input  logic [7:0]             web_sample_steps,// レーザー分割数 (e.g. 16/32)

    // --- ウェイポイント・メモリ書き込み (Web -> FPGA) ---
    input  logic [5:0]             web_wp_addr,
    input  logic [COORD_WIDTH-1:0] web_wp_x,
    input  logic [COORD_WIDTH-1:0] web_wp_y,
    input  logic [COORD_WIDTH-1:0] web_wp_z,
    input  logic                   web_wp_we,

    // --- 地形 BRAM 書き込み (Web -> FPGA) ---
    input  logic [MEM_ADDR_W-1:0]  web_dem_addr,
    input  logic [COORD_WIDTH-1:0] web_dem_z,
    input  logic                   web_dem_we,

    // --- 結果出力ビットマップ (FPGA -> Web) ---
    // bit[i] = 1: ウェイポイントiは可視 (赤), 0: 不可視 (青)
    output logic [MAX_WAYPOINTS-1:0] web_visibility_bitmap
);

    // --- 内部 BRAM & レジスタ ---
    logic [COORD_WIDTH-1:0] dem_bram [0:(1<<MEM_ADDR_W)-1];
    logic [COORD_WIDTH-1:0] wp_x_ram [0:MAX_WAYPOINTS-1];
    logic [COORD_WIDTH-1:0] wp_y_ram [0:MAX_WAYPOINTS-1];
    logic [COORD_WIDTH-1:0] wp_z_ram [0:MAX_WAYPOINTS-1];

    // Webからのメモリ書き込みロジック
    always_ff @(posedge clk) begin
        if (web_dem_we) begin
            dem_bram[web_dem_addr] <= web_dem_z;
        end
        if (web_wp_we) begin
            wp_x_ram[web_wp_addr] <= web_wp_x;
            wp_y_ram[web_wp_addr] <= web_wp_y;
            wp_z_ram[web_wp_addr] <= web_wp_z;
        end
    end

    // シリアル/並列 制御ステートマシン
    typedef enum logic [1:0] { IDLE, PROCESSING, FINISH } state_t;
    state_t state;

    logic [5:0] current_wp_idx;
    logic       core_start;
    logic       core_done;
    logic       core_visible;

    logic [MEM_ADDR_W-1:0] core_mem_addr;
    logic [COORD_WIDTH-1:0] core_mem_rdata;

    // BRAM 読み出し
    assign core_mem_rdata = dem_bram[core_mem_addr];

    // Viewshed コアのインスタンス
    viewshed_raycast_core #(
        .COORD_WIDTH(COORD_WIDTH),
        .MEM_ADDR_W(MEM_ADDR_W)
    ) u_viewshed_core (
        .clk(clk),
        .rst_n(rst_n),
        .start(core_start),
        .obs_x(web_obs_x),
        .obs_y(web_obs_y),
        .obs_z(web_obs_z),
        .obs_height(web_obs_height),
        .sample_steps(web_sample_steps),
        .tgt_x(wp_x_ram[current_wp_idx]),
        .tgt_y(wp_y_ram[current_wp_idx]),
        .tgt_z(wp_z_ram[current_wp_idx]),
        .terrain_mem_addr(core_mem_addr),
        .terrain_mem_rdata(core_mem_rdata),
        .done(core_done),
        .is_visible(core_visible)
    );

    // シーケンサ: 全ウェイポイントを自動順次計算
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            web_busy <= 1'b0;
            web_done <= 1'b0;
            current_wp_idx <= '0;
            core_start <= 1'b0;
            web_visibility_bitmap <= '0;
        end else begin
            case (state)
                IDLE: begin
                    web_done <= 1'b0;
                    if (web_cmd_valid) begin
                        web_busy <= 1'b1;
                        current_wp_idx <= '0;
                        core_start <= 1'b1;
                        state <= PROCESSING;
                    end
                end

                PROCESSING: begin
                    core_start <= 1'b0;
                    if (core_done) begin
                        // 結果をビットマップへ登録
                        web_visibility_bitmap[current_wp_idx] <= core_visible;

                        if (current_wp_idx == MAX_WAYPOINTS - 1) begin
                            state <= FINISH;
                        end else begin
                            current_wp_idx <= current_wp_idx + 1'b1;
                            core_start <= 1'b1; // 次のWP計算を開始
                        end
                    end
                end

                FINISH: begin
                    web_busy <= 1'b0;
                    web_done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule


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