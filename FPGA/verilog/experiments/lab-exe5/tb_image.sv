module rgb_to_grayscale_tb;

    // 信号宣言
    logic        clk = 1'b0;
    logic        rst_n;
    logic [23:0] rgb_in;
    logic        valid_in;
    logic [7:0]  gray_out;
    logic        valid_out;

    // DUTのインスタンス化
    rgb_to_grayscale dut (
        .clk(clk),
        .rst_n(rst_n),
        .rgb_in(rgb_in),
        .valid_in(valid_in),
        .gray_out(gray_out),
        .valid_out(valid_out)
    );

    // クロック生成 (50MHz相当: 10ns周期)
    always #10 clk = ~clk;

    // テストシーケンス
    initial begin
        // 1. 初期化とリセット
        rst_n = 1'b0;
        valid_in = 1'b0;
        #20; // リセット期間
        
        rst_n = 1'b1;
        #10;

        $display("-----------------------------------------------------------------------");
        $display(" Time | RGB Input  | Expected Gray | Actual Gray | Valid_Out | Result ");
        $display("-----------------------------------------------------------------------");
        
        // 2. テストケース 1: 白 (R=255, G=255, B=255) -> 期待値: 255
        rgb_in = 24'hFF_FF_FF;
        valid_in = 1'b1;
        #20;
        // 期待値の計算: (255+255+255)/3 = 255
        // 実際の出力は1クロック遅れるため、20ns後に確認
        $display(" %4d |   %h   |       %d       |     %d     |    %b      | %s",
                 $time, rgb_in, 255, gray_out, valid_out, 
                 (valid_out && gray_out == 8'd255) ? "PASS" : "FAIL");

        // 3. テストケース 2: 黒 (R=0, G=0, B=0) -> 期待値: 0
        rgb_in = 24'h00_00_00;
        valid_in = 1'b1;
        #20;
        // 期待値の計算: (0+0+0)/3 = 0
        $display(" %4d |   %h   |       %d       |     %d     |    %b      | %s",
                 $time, rgb_in, 0, gray_out, valid_out, 
                 (valid_out && gray_out == 8'd0) ? "PASS" : "FAIL");
                 
        // 4. テストケース 3: 緑 (R=0, G=255, B=0) -> 期待値: 255/3 ≈ 85
        rgb_in = 24'h00_FF_00;
        valid_in = 1'b1;
        #20;
        // 期待値の計算: (0+255+0)/3 = 85
        $display(" %4d |   %h   |       %d       |     %d     |    %b      | %s",
                 $time, rgb_in, 85, gray_out, valid_out, 
                 (valid_out && gray_out == 8'd85) ? "PASS" : "FAIL");

        // 5. テストケース 4: 中間的な値 (R=10, G=50, B=90) -> 期待値: 50
        rgb_in = 24'h5A_32_0A; // 0x0A, 0x32, 0x5A は 10, 50, 90
        valid_in = 1'b1;
        #20;
        // 期待値の計算: (10+50+90)/3 = 150/3 = 50
        $display(" %4d |   %h   |       %d       |     %d     |    %b      | %s",
                 $time, rgb_in, 50, gray_out, valid_out, 
                 (valid_out && gray_out == 8'd50) ? "PASS" : "FAIL");
                 
        valid_in = 1'b0; // 入力停止
        #100;
        
        $finish;
    end
endmodule