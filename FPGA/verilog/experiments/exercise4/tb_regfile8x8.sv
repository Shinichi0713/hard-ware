`timescale 1ns/1ps

module regfile8x8_tb;

    logic clk;
    logic rst_n;
    logic we;
    logic [2:0] wr_addr;
    logic [7:0] wr_data;
    logic [2:0] rd_addr;
    logic [7:0] rd_data;

    // DUT
    regfile8x8 dut(
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // clock: 100MHz
    end

    // テストシナリオ
    initial begin
        $display("=== REGFILE TEST START ===");

        // 初期値
        rst_n   = 0;
        we      = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_addr = 0;

        // リセット
        #12;
        rst_n = 1;

        // レジスタに順番に書き込み
        for (int i = 0; i < 8; i++) begin
            @(posedge clk);
            we      = 1;
            wr_addr = i[2:0];
            wr_data = 8'h10 + i;
        end

        @(posedge clk);
        we = 0;

        // 読み出しテスト
        for (int i = 0; i < 8; i++) begin
            rd_addr = i[2:0];
            #1;  // 組み合わせ読み出しのため少し待つ
            $display("Read reg[%0d] = %h", i, rd_data);
        end

        // ランダムアクセスチェック
        $display("=== RANDOM ACCESS TEST ===");
        repeat (5) begin
            int a = $urandom_range(0, 7);
            rd_addr = a;
            #1;
            $display("Random read reg[%0d] = %h", a, rd_data);
        end

        $display("=== REGFILE TEST END ===");
        $finish;
    end

endmodule
