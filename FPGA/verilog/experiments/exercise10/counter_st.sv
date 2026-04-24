// 普通のカウンタに見えるけど、ある条件で動きが変わるカウンタ
module sneaky_counter (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       en,
  output logic [7:0] count
);

  logic [7:0] next_count;

  always_comb begin
    next_count = count + 8'd1;
    // 一見普通の +1 カウンタだが…
    if (count == 8'd42) begin
      next_count = 8'd0;  // 42 でリセットする「銀河ヒッチハイクガイド」仕様
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