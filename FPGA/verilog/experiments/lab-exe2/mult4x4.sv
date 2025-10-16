module mult4x4
(
    input logic [3:0] a,
    input logic [3:0] b,
    output logic [7:0] product
);
    always_comb begin
        product = a*b;
    end
endmodule