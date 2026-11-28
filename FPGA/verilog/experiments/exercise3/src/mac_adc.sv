`timescale 1ns/1ps

module mac_unit #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 32
) (
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        clear_acc,
    input  logic                        en,
    input  logic signed [DATA_W-1:0]    a,
    input  logic signed [DATA_W-1:0]    b,
    output logic signed [ACC_W-1:0]     acc_out
);

    logic signed [2*DATA_W-1:0] mult_reg;
    logic signed [ACC_W-1:0]    acc_reg;

    // 乗算段のパイプラインレジスタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mult_reg <= '0;
        end else if (en) begin
            mult_reg <= a * b;
        end
    end

    // 累積加算段
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_reg <= '0;
        end else if (clear_acc) begin
            acc_reg <= en ? {{(ACC_W - 2*DATA_W){mult_reg[2*DATA_W-1]}}, mult_reg} : '0;
        end else if (en) begin
            acc_reg <= acc_reg + {{(ACC_W - 2*DATA_W){mult_reg[2*DATA_W-1]}}, mult_reg};
        end
    end

    assign acc_out = acc_reg;

endmodule