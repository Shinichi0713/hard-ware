module generic_counter #(
    parameter int WIDTH   = 8,      // カウンタのビット幅
    parameter int MAX_VAL = 255     // カウントの最大値
)(
    input  logic             clk,   // クロック
    input  logic             rst_n, // 負論理リセット
    output logic [WIDTH-1:0] count  // 現在のカウント値
);

    // --- カウント動作（順序回路） ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // リセット時は 0
            count <= {WIDTH{1'b0}};
        end else begin
            if (count >= MAX_VAL[WIDTH-1:0]) begin
                // 最大値に達したら 0 に戻る
                count <= {WIDTH{1'b0}};
            end else begin
                // それ以外はインクリメント
                count <= count + 1'b1;
            end
        end
    end

endmodule