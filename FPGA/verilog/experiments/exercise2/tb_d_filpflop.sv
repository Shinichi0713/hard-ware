/*
 * Dフリップフロップ (d_flipflop) のテストベンチ
 * - クロック生成
 * - 非同期リセットの検証
 * - データ転送（d -> q）の検証
 */
module tb_d_flipflop;

    // ----------------------------------------------------
    // 信号宣言 (DUT: Device Under Test への接続信号)
    // ----------------------------------------------------
    // 入力信号はドライバーとして機能 (初期値設定とシーケンスでの変更)
    logic clk;
    logic rst_n;
    logic d;
    
    // 出力信号は観測用
    logic q;

    // ----------------------------------------------------
    // テスト対象モジュールのインスタンス化
    // ----------------------------------------------------
    d_flipflop dut (
        .clk  (clk),
        .rst_n(rst_n),
        .d    (d),
        .q    (q)
    );

    // ----------------------------------------------------
    // クロック生成プロセス
    // ----------------------------------------------------
    // 周期 20 (時間単位) のクロックを生成
    parameter CLK_PERIOD = 10; 
    
    initial begin
        clk = 1'b0;
        // 永遠に半周期 (5時間単位) ごとにクロックを反転
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // ----------------------------------------------------
    // テストシーケンス
    // ----------------------------------------------------
    initial begin
        $display("--------------------------------------------------");
        $display("Test Sequence Start (CLK_PERIOD: %0d)", CLK_PERIOD);
        $display("--------------------------------------------------");

        // 1. 初期化と非同期リセットの検証
        rst_n = 1'b0; // リセット有効 (アクティブ・ロー)
        d     = 1'b1; // データ入力は High に設定
        # (CLK_PERIOD * 1.5); // 1.5クロック周期待機
        $display("Time=%0t: (RESET ACTIVE) rst_n=0. q must be 0.", $time);
        
        // 2. リセット解除とデータの初期転送
        rst_n = 1'b1; // リセット解除
        d     = 1'b0; // dを0に設定
        # CLK_PERIOD; // 1クロック周期待機 (qは0のまま)
        $display("Time=%0t: d=0. q updated to 0 on posedge clk.", $time);

        // 3. データ転送 (0 -> 1)
        d = 1'b1;
        # CLK_PERIOD; // 1クロック周期待機 (qは1に更新される)
        $display("Time=%0t: d=1. q updated to 1 on posedge clk.", $time);

        // 4. データ変化 (1 -> 0)
        d = 1'b0;
        # CLK_PERIOD; // 1クロック周期待機 (qは0に更新される)
        $display("Time=%0t: d=0. q updated to 0 on posedge clk.", $time);

        // 5. データ保持の検証 (クロックエッジ外での変化は無視される)
        d = 1'b1;
        # (CLK_PERIOD / 2); // クロックが High の状態で待機
        $display("Time=%0t: d=1. q should remain 0 (no posedge clk).", $time);
        
        # (CLK_PERIOD / 2); // クロック立ち上がり (qは1に更新される)
        $display("Time=%0t: Posedge clk. q updated to 1.", $time);

        // 6. 再度非同期リセットの検証 (動作中)
        d = 1'b0;
        # (CLK_PERIOD / 4);
        rst_n = 1'b0; // リセット有効
        # (CLK_PERIOD / 2);
        $display("Time=%0t: (RESET ACTIVE) q should be 0 immediately.", $time);
        
        // テスト終了
        # (CLK_PERIOD * 2);
        $display("--------------------------------------------------");
        $display("Test Sequence Finished.");
        $stop; 
    end

    // ----------------------------------------------------
    // シミュレーション時の信号観測
    // ----------------------------------------------------
    initial begin
        // シミュレーション時間と主要信号の変化を常時出力
        $monitor("TIME=%0t | clk=%b | rst_n=%b | d=%b | q=%b", $time, clk, rst_n, d, q);
    end

endmodule