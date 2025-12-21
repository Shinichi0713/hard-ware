module reg_file (
    input  logic       clk,      // クロック
    input  logic       rst_n,    // 負論理リセット
    input  logic       we,       // 書き込みイネーブル
    input  logic [2:0] wr_addr,  // 書き込みアドレス（2^3 = 8）
    input  logic [7:0] wr_data,  // 書き込みデータ（8bit）
    input  logic [2:0] rd_addr,  // 読み出しアドレス
    output logic [7:0] rd_data   // 読み出しデータ
);

    // 8bit幅のレジスタが8個のメモリ配列
    logic [7:0] registers [8];

    // --- 読み出し（組み合わせ論理） ---
    // アドレスが変われば即座に出力データも変わる
    assign rd_data = registers[rd_addr];

    // --- 書き込み（順序回路） ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // リセット時、全レジスタを0に初期化
            for (int i = 0; i < 8; i++) begin
                registers[i] <= 8'h00;
            end
        end else if (we) begin
            // weが1のとき、指定アドレスへデータを格納
            registers[wr_addr] <= wr_data;
        end
    end

endmodule

