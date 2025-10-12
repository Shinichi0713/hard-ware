`timescale 1 ps/ 1 ps
module ff_sim();
// constants                                           
// general purpose registers
  reg aclr;
  reg clk;
  reg clken;
  reg d;
// wires                                               
  wire q;

// assign statements (if any)                          
ff u1 (
// port map - connection between master ports and signals/registers   
  .aclr(aclr),
  .clk(clk),
  .clken(clken),
  .d(d),
  .q(q)
);

// aclr
initial
begin
  aclr =         1'b1;
  aclr = #30000  1'b0;
  aclr = #10000  1'b1;
  aclr = #100000 1'b0;
  aclr = #10000  1'b1;
end 

// clk
always
begin
  clk =       1'b0;
  clk = #5000 1'b1;
        #5000;
end 

// clken
initial
begin
  clken =         1'b1;
  clken = #100000 1'b0;
  clken = #100000 1'b1;
end 

// d
initial
begin
  d =        1'b0;
  d = #10000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
  d = #20000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
  d = #10000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
  d = #20000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
  d = #10000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
  d = #20000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
  d = #10000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
  d = #20000 1'b1;
  d = #40000 1'b0;
  d = #20000 1'b1;
  d = #20000 1'b0;
end 

endmodule
