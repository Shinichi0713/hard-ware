//=======================================================
//  Testbench for ff
//  非同期クリア + クロックイネーブル付きDフリップフロップの動作確認
//=======================================================

`timescale 1ns/1ps

module tb_ff;

    // テストベンチ内信号宣言
    logic clk;
    logic aclr;
    logic clken;
    logic d;
    logic q;

    // DUT (Device Under Test) インスタンス化
    ff uut (
        .clk(clk),
        .aclr(aclr),
        .clken(clken),
        .d(d),
        .q(q)
    );

    // クロック生成（10ns周期 → 100MHz）
    initial clk = 0;
    always #5 clk = ~clk;

    // テストシナリオ
    initial begin
        // 波形出力用（任意）
        $dumpfile("tb_ff.vcd");
        $dumpvars(0, tb_ff);

        // 初期化
        aclr  = 1'b0;  // 非同期クリアアクティブ
        clken = 1'b0;
        d     = 1'b0;
        #10;

        // 1. 非同期クリアが有効 → q は常に 0
        $display("[%0t ns] aclr=0 → 非同期クリア動作", $time);
        #10;

        // 2. 非同期クリア解除
        aclr = 1'b1;
        $display("[%0t ns] aclr=1 → 動作開始", $time);

        // 3. clken=1 のとき d を取り込む
        clken = 1'b1;
        d = 1'b1;  #10;  // q should become 1
        d = 1'b0;  #10;  // q should become 0

        // 4. clken=0 のとき q は保持
        clken = 1'b0;
        d = 1'b1;
        #20; // q should remain the same

        // 5. 非同期クリア再度アクティブ
        aclr = 1'b0;
        #10; // q should reset to 0
        aclr = 1'b1;
        #10;

        $display("[%0t ns] テスト完了", $time);
        $finish;
    end

endmodule
