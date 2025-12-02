// 優先度エンコーダ (4入力 -> 2出力)
module priority_encoder_4x2 (
    input  logic [3:0] in,      // 4ビット入力 (in[3]が最高優先度)
    output logic [1:0] out,     // 2ビット出力 (エンコードされた位置)
    output logic valid          // 有効フラグ (inが全て0でない場合に1)
);

    // 組み合わせ回路を記述するための always_comb ブロック
    always_comb begin
        // デフォルト値 (inが全て0の場合)
        // 優先度エンコーダの出力は、in[3:0]が全て0の場合、無効で出力は未定義(ここでは0)とする。
        out = 2'b00;
        valid = 1'b0;

        // 最高優先度 (in[3]) から順にチェックする
        // if-else if 構造により、最高優先度のビットが '1' であれば、
        // それ以降の条件はチェックされない（優先度が保証される）。

        if (in[3]) begin
            // in[3] が '1' の場合: 最も優先度が高い
            out = 2'b11; // 3 (11)
            valid = 1'b1;
        end 
        else if (in[2]) begin
            // in[3] が '0' で、in[2] が '1' の場合
            out = 2'b10; // 2 (10)
            valid = 1'b1;
        end 
        else if (in[1]) begin
            // in[3], in[2] が '0' で、in[1] が '1' の場合
            out = 2'b01; // 1 (01)
            valid = 1'b1;
        end 
        else if (in[0]) begin
            // in[3], in[2], in[1] が '0' で、in[0] が '1' の場合
            out = 2'b00; // 0 (00)
            valid = 1'b1;
        end 
        // 全て '0' の場合は、初期設定 (out=00, valid=0) のまま終了する
    end

endmodule