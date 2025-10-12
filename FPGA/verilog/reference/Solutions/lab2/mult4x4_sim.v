`timescale 1 ps/ 1 ps
module mult4x4_sim();
// constants                                           
// general purpose registers
  reg [3:0] a;
  reg [3:0] b;
// wires                                               
  wire [7:0] product;

// assign statements (if any)                          
mult4x4 u1 (
// port map - connection between master ports and signals/registers   
  .a(a),
  .b(b),
  .product(product)
);

parameter CYCLE=20000;

initial
begin
  a = 4'b0000;
end
always # (CYCLE)
  a <= a + 1;

initial
begin
  b = 4'b1111;
end

always # (CYCLE)
  b <= b - 1;

endmodule
