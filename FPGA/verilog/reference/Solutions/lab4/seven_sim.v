`timescale 1 ps/ 1 ps
module seven_sim();
// constants                                           
// general purpose registers
  reg [2:0] inp;
// wires                                               
  wire a,b,c,d,e,f,g;
//
// assign statements (if any)                          
seven u1 (
// port map - connection between master ports and signals/registers   
  .inp(inp),
  .a(a),
  .b(b),
  .c(c),
  .d(d),
  .e(e),
  .f(f),
  .g(g)
);

parameter CYCLE=4000;

initial
begin
  inp = 3'b000;
end
always # (CYCLE/2)
	inp <= inp + 1; 

endmodule
