`timescale 1 ps/ 1 ps
module mux4_sim();
// constants                                           
// general purpose registers
  reg [3:0] a;
  reg [3:0] b;
  reg sel;
// wires                                               
  wire [3:0] y;
//
// assign statements (if any)                          
mux4 u1 (
// port map - connection between master ports and signals/registers   
  .sel(sel),
  .a(a),
  .b(b),
  .y(y)
);
//
parameter CYCLE=100000;

initial
begin
  sel = 1'b0;
end
always # (CYCLE/2)
  sel <= ~sel; 

initial
begin
  a = 4'b1001;
end

initial
begin
  b = 4'b0111;	
end

endmodule
