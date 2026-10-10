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