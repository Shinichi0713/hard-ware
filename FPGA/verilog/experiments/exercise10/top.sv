// top.sv
module top (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       en,
  output logic [7:0] count
);

  sneaky_counter u_counter (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .count (count)
  );

endmodule