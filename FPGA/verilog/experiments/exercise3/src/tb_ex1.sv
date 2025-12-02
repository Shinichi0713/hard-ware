module priority_encoder_4x2_tb;

    // テストベンチ内の信号宣言
    logic [3:0] in_tb;
    logic [1:0] out_tb;
    logic valid_tb;

    // DUT (Design Under Test) のインスタンス化
    // priority_encoder_4x2 モジュールは外部で定義されている必要があります
    priority_encoder_4x2 dut (
        .in(in_tb),
        .out(out_tb),
        .valid(valid_tb)
    );

    // テストシーケンス
    initial begin
        // 波形ダンプの設定
        $dumpfile("priority_encoder.vcd"); // 波形ファイル名
        $dumpvars(0, priority_encoder_4x2_tb);

        $display("-------------------------------------------------------");
        $display("--- Testing 4x2 Priority Encoder ---");
        $display("-------------------------------------------------------");
        $display(" Time | Input | Output | Valid | Expected | Result ");

        // テストケース 1: 全て 0
        in_tb = 4'b0000;
        #10;
        // 期待値: out=00, valid=0
        $display(" %4d |  %b  |  %b   |   %b   |   00/0   | %s ", 
                 $time, in_tb, out_tb, valid_tb, 
                 (out_tb == 2'b00 && valid_tb == 1'b0) ? "PASS" : "FAIL");

        // テストケース 2: 最下位ビットのみ 1 (優先度 最低)
        in_tb = 4'b0001;
        #10;
        // 期待値: out=00, valid=1
        $display(" %4d |  %b  |  %b   |   %b   |   00/1   | %s ", 
                 $time, in_tb, out_tb, valid_tb, 
                 (out_tb == 2'b00 && valid_tb == 1'b1) ? "PASS" : "FAIL");

        // テストケース 3: in[2] が 1
        in_tb = 4'b0100;
        #10;
        // 期待値: out=10, valid=1
        $display(" %4d |  %b  |  %b   |   %b   |   10/1   | %s ", 
                 $time, in_tb, out_tb, valid_tb, 
                 (out_tb == 2'b10 && valid_tb == 1'b1) ? "PASS" : "FAIL");

        // テストケース 4: 競合 (in[3] と in[1] が 1) -> in[3] (優先度最高) が勝つ
        in_tb = 4'b1010;
        #10;
        // 期待値: out=11, valid=1
        $display(" %4d |  %b  |  %b   |   %b   |   11/1   | %s ", 
                 $time, in_tb, out_tb, valid_tb, 
                 (out_tb == 2'b11 && valid_tb == 1'b1) ? "PASS" : "FAIL");
        
        // テストケース 5: 全て 1 -> in[3]