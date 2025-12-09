// -----------------------------------------------------
// パケットトランザクションクラスの定義
// -----------------------------------------------------
class PacketTransaction;
    
    // 1. ランダム変数 (rand) の定義
    rand bit [15:0] addr;   // 16ビットのアドレス
    rand bit [7:0]  data;   // 8ビットのデータ
    rand int        length; // パケット長
    
    // 2. 制約 (Constraint) の定義
    // 'data' と 'addr' に特定のランダムな条件を課す
    constraint even_data_c { 
        // data は偶数であること
        (data % 2) == 0; 
    }
    
    constraint addr_range_c {
        // addr は 1000 から 2000 の間であること
        addr inside {[16'd1000 : 16'd2000]}; 
        // さらに、addrの最上位ビットは1であること (MSB is set)
        addr[15] == 1; 
    }
    
    constraint length_c {
        // length は 4, 8, または 16 のいずれかであること
        length inside {4, 8, 16};
    }

    // 3. コンストラクタ (初期化関数)
    function new();
        // コンストラクタで特に処理なし
    endfunction
    
    // 4. 表示用メソッド
    function void display();
        $display("----------------------------------");
        $display(" Address: %h (%d)", addr, addr);
        $display(" Data (Even): %h (%d)", data, data);
        $display(" Length: %d", length);
        $display("----------------------------------");
    endfunction

endclass

// -----------------------------------------------------
// メインのテストベンチ部分
// -----------------------------------------------------
module generator_tb;

    initial begin
        // クラスのインスタンス化（オブジェクトの生成）
        PacketTransaction pkt = new();

        $display("--- 🛠️ 制約付きランダムデータ生成 ---");
        
        // 5回ランダム化を実行し、結果を表示
        repeat (5) begin
            // 乱数生成を実行
            // randc は使用していないため、rand() メソッドで実行
            if (pkt.randomize()) begin 
                $display("✅ Randomization Success (Time: %0t)", $time);
                pkt.display();
            end else begin
                $error("❌ Randomization Failed: 制約に矛盾があります。");
            end
            #10; // シミュレーション時間を少し進める
        end
        
        $finish;
    end
endmodule