`timescale 1ns/1ps

module tb_generic_counter;
    // テスト用のパラメータ定義
    localparam int TEST_WIDTH = 4;
    localparam int TEST_MAX   = 9;

    logic                  clk;
    logic                  rst_n;
    logic [TEST_WIDTH-1:0] count;

    // --- インスタンス化 (パラメータの書き換え) ---
    generic_counter #(
        .WIDTH(TEST_WIDTH),
        .MAX_VAL(TEST_MAX)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    // クロック生成 (100MHz)
    always #5 clk = ~clk;

    initial begin
        // 初期化
        clk = 0;
        rst_n = 0;

        // リセット解除
        #20 rst_n = 1;

        // 15サイクル分（一周半以上）シミュレーション実行
        repeat (15) @(posedge clk);

        $finish;
    end

    // モニタリング
    initial begin
        $monitor("Time: %0t | Reset: %b | Count: %d", $time, rst_n, count);
    end
endmodule