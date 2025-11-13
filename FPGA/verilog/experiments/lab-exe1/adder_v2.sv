module adder()
    import "DPI-C" function void c_add(
        input  int a,
        input  int b,
        output int sum,
        output int carry
    );

    parameter WIDTH = 8;

    input  logic [WIDTH-1:0] a;     // ??A
    input  logic [WIDTH-1:0] b;     // ??B
    output logic [WIDTH-1:0] sum;   // ????????
    output logic              carry; // ??????

    // ????
    always_comb begin
        {carry, sum} = a + b;  // ???????????
    end