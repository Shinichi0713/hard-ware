module regfile8x8 (
    input  logic        clk,
    input  logic        rst_n,      // active-low reset
    input  logic        we,         // write enable
    input  logic [2:0]  wr_addr,    // write address (0-7)
    input  logic [7:0]  wr_data,    // write data
    input  logic [2:0]  rd_addr,    // read address (0-7)
    output logic [7:0]  rd_data     // read data (combinational)
);

    logic [7:0] regfile [7:0];      // 8 registers, each 8-bit wide

    // 書き込み（同期）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // リセットで全レジスタを 0 初期化
            for (int i = 0; i < 8; i++) begin
                regfile[i] <= 8'h00;
            end
        end else if (we) begin
            regfile[wr_addr] <= wr_data;
        end
    end

    // 読み出し（組み合わせ）
    always_comb begin
        rd_data = regfile[rd_addr];
    end

endmodule
