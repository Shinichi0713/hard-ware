`timescale 1ns/1ps

module tb_top_module;
    logic       clk;
    logic       rst_n;
    logic [7:0] count_8bit;
    logic [9:0] count_10bit;

    // テスト対象（top_module）のインスタンス化
    top_module dut (.*);

    // クロック生成 (10ns周期 = 100MHz)
    always #5 clk = ~clk;

    initial begin
        // 初期状態
        clk = 0;
        rst_n = 0;

        // リセット解除
        #20 rst_n = 1;

        // 550サイクル程度回して、両方のカウンタが一周するのを確認
        repeat (550) @(posedge clk);

        $display("Simulation Finished.");
        $finish;
    end

    // ログ出力（値が変化した時だけ表示）
    initial begin
        $monitor("Time:%0t | 8bit_cnt:%d | 10bit_cnt:%d", 
                 $time, count_8bit, count_10bit);
    end
endmodule