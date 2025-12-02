// 8ビット Dフリップフロップ配列 (非同期リセット付き)
module d_ff_array (
    input  logic        clk,    // クロック信号
    input  logic        rst_n,  // 非同期リセット (Lowアクティブ)
    input  logic [7:0]  d,      // 8ビットデータ入力
    output logic [7:0]  q       // 8ビットデータ出力
);

    // sequential logic (シーケンシャル回路) を記述するための always_ff ブロック
    // @(posedge clk or negedge rst_n) は、クロックの立ち上がりエッジ
    // または非同期リセットの立ち下がりエッジ (アクティブエッジ) のいずれかで
    // ブロック内の処理を実行することを示しています。
    always_ff @(posedge clk or negedge rst_n) begin
        // リセット条件: 非同期リセット信号がアクティブ (rst_n == 0) の場合
        if (!rst_n) begin
            // リセット時、出力 q を '0' にクリアする (リセット状態)
            q <= 8'b0;
        end 
        // 通常動作条件: リセットが非アクティブ (rst_n == 1) の場合
        else begin
            // クロックの立ち上がりエッジで入力 d の値を q に転送 (通常動作)
            q <= d;
        end
    end

endmodule