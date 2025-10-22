module hello (
    clk
);
  input clk;
  reg [31:0] count = 0;
  always_ff @(clk) begin : counter
    count <= count + 1;
  end
endmodule