module mux4x4 #(parameter WIDTH=4)
(
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    output logic [7:0] product
);
    always_comb begin
        product = a*b;
    end
endmodule