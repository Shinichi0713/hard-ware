// sneaky_counter.sv
module sneaky_counter (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       en,
  output logic [7:0] count
);

  logic [7:0] next_count;

  always_comb begin
    next_count = count + 8'd1;
    if (count == 8'd42) begin
      next_count = 8'd0;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 8'd0;
    end else if (en) begin
      count <= next_count;
    end
  end

endmodule