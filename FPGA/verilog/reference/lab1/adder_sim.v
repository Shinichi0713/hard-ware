`timescale 1 ps/ 1 ps
module adder_sim();
// constants                                           
// general purpose registers
  reg [15:0] a;
  reg [15:0] b;
// wires                                               
  wire [15:0] sum;

// assign statements (if any)                          
adder u1 (
// port map - connection between master ports and signals/registers   
  .a(a),
  .b(b),
  .sum(sum)
);

initial
begin
  a = 16'b0;
  a = #100000 16'b0000000000000000;
  a = #100000 16'b0000000000000011;
  a = #100000 16'b0000000000001100;
  a = #100000 16'b0000000000001111;
  a = #100000 16'b0000000000110000;
  a = #100000 16'b0000000000110011;
  a = #100000 16'b0000000000000100;
end 

initial
begin
  b = 16'b0;
  b = #050000 16'b0000000000000000;
  b = #100000 16'b0000000000000001;
  b = #050000 16'b0000000000000010;
  b = #100000 16'b0000000000000011;
  b = #050000 16'b0000000000000100;
  b = #100000 16'b0000000000000101;
  b = #050000 16'b0000000000000000;
  b = #100000 16'b0000000000000001;
  b = #050000 16'b0000000000000010;
end

endmodule

