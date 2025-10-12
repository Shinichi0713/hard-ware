module ff (clk, aclr, clken, d, q);
  input clk, aclr, clken, d;
  output q;

  reg    q;

always@(posedge clk or negedge aclr)
begin
  if (aclr == 1'b0)
    q <= 1'b0;
  else if (clken == 1'b1)
    q <= d;
end

endmodule
