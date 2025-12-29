module top_module (
    input  logic        clk,
    input  logic        rst_n,
    output logic [7:0]  count_8bit,  // デフォルト用
    output logic [9:0]  count_10bit  // 10bit/500用
);

    // 1. デフォルト設定のカウンタ (8bit, 255)
    // パラメータを省略すると、定義時のデフォルト値が使われます
    generic_counter counter_inst1 (
        .clk   (clk),
        .rst_n (rst_n),
        .count (count_8bit)
    );

    // 2. パラメータを変更したカウンタ (10bit, 500)
    // #(.パラメータ名(値)) の形式で上書きします
    generic_counter #(
        .WIDTH   (10),
        .MAX_VAL (500)
    ) counter_inst2 (
        .clk   (clk),
        .rst_n (rst_n),
        .count (count_10bit)
    );

endmodule