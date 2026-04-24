// tb_top.sv
`timescale 1ns/1ps

module tb_top;

  logic       clk;
  logic       rst_n;
  logic       en;
  logic [7:0] count;

  // クロック生成
  always #5 clk = ~clk;

  // トップモジュールのインスタンス
  top u_top (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .count (count)
  );

  initial begin
    clk   = 0;
    rst_n = 0;
    en    = 0;

    // リセット解除
    #20 rst_n = 1;
    #10 en    = 1;

    // 42 に到達するまでカウントアップさせる
    #1000;

    $display("Simulation finished.");
    $finish;
  end

endmodule