`timescale 1ns/1ps

module tb_reg_file;
    logic       clk;
    logic       rst_n;
    logic       we;
    logic [2:0] wr_addr;
    logic [7:0] wr_data;
    logic [2:0] rd_addr;
    logic [7:0] rd_data;

    // インスタンス化
    reg_file dut (.*);

    // クロック生成 (100MHz)
    always #5 clk = ~clk;

    initial begin
        // --- 1. 初期設定 ---
        clk = 0;
        rst_n = 0;
        we = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_addr = 0;

        #20 rst_n = 1; // リセット解除

        // --- 2. 書き込みテスト ---
        // アドレス 3 に 0xA5 を書き込む
        @(posedge clk);
        we = 1;
        wr_addr = 3'd3;
        wr_data = 8'hA5;
        
        // アドレス 7 に 0x5A を書き込む
        @(posedge clk);
        wr_addr = 3'd7;
        wr_data = 8'h5A;

        @(posedge clk);
        we = 0; // 書き込み終了

        // --- 3. 読み出しテスト ---
        // アドレス 3 を読み出し
        #10 rd_addr = 3'd3;
        #1 $display("Read Addr 3: Data = %h (Expected: A5)", rd_data);

        // アドレス 7 を読み出し
        #10 rd_addr = 3'd7;
        #1 $display("Read Addr 7: Data = %h (Expected: 5A)", rd_data);

        // 未書き込みのアドレス（アドレス 0 など）を確認
        #10 rd_addr = 3'd0;
        #1 $display("Read Addr 0: Data = %h (Expected: 00)", rd_data);

        #50 $finish;
    end

    // 波形出力用（環境に合わせて使用）
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_reg_file);
    end
endmodule