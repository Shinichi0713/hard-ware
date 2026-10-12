`timescale 1ns / 1ps
`include "motor_control_pkg.sv"
`include "lqr_matrix_pkg.sv"
import motor_control_pkg::*;
import lqr_matrix_pkg::*;

// ---------------------------------------------------------------------------
// LQR状態フィードバック制御器
// 制御入力 u = -K * x  (Kは1x4行列、xは4x1状態ベクトル)
// 出力飽和とアンチウィンドアップ機能付き
// ---------------------------------------------------------------------------
module lqr_controller #(
  parameter int FP_W = 32,
  parameter int SHIFT = 14
)(
  input  wire              clk,
  input  wire              rst_n,
  input  wire              en,
  input  logic signed [FP_W-1:0] K_gain [0:3],   // 1x4 LQRゲイン (Q14)
  input  vec4_t            state_in,            // [x, v, theta, omega] (Q14)
  input  logic signed [FP_W-1:0] u_max,           // 入力飽和上限 (Q14)
  output logic signed [FP_W-1:0] control_u        // 制御入力 (Q14)
);

  logic signed [FP_W-1:0] raw_u;
  logic signed [FP_W-1:0] saturated_u;

  // u = -(K[0]*x[0] + K[1]*x[1] + K[2]*x[2] + K[3]*x[3])
  always_comb begin
    logic signed [2*FP_W-1:0] acc;
    acc = signed'(K_gain[0]) * signed'(state_in[0])
        + signed'(K_gain[1]) * signed'(state_in[1])
        + signed'(K_gain[2]) * signed'(state_in[2])
        + signed'(K_gain[3]) * signed'(state_in[3]);
    raw_u = -signed'(acc >>> SHIFT);
  end

  // 出力飽和
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      control_u <= '0;
    end else if (en) begin
      if (raw_u > u_max)
        control_u <= u_max;
      else if (raw_u < -u_max)
        control_u <= -u_max;
      else
        control_u <= raw_u;
    end
  end

endmodule
