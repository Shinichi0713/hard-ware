//============================================================
// 8-bit Adder
//============================================================
module adder #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,     // ??A
    input  logic [WIDTH-1:0] b,     // ??B
    output logic [WIDTH-1:0] sum,   // ????????
    output logic              carry // ??????
);

    // ????
    always_comb begin
        {carry, sum} = a + b;  // ???????????
    end

endmodule

