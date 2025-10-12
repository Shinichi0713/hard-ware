module mult4x4 (a, b, product);
  input [3:0] a, b;
  output [7:0] product;

  reg [7:0] product ;

always@(a or b)
  product <= a * b;

endmodule
