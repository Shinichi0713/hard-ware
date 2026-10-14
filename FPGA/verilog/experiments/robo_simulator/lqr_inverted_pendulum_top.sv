`timescale 1ns / 1ps
`include "motor_control_pkg.sv"
`include "lqr_matrix_pkg.sv"
import motor_control_pkg::*;
import lqr_matrix_pkg::*;

// ---------------------------------------------------------------------------
// LQR制御倒立振子 トップレベルモジュール
// LQRゲイン計算 -> 状態フィードバック制御 -> プラントシミュレーション
// ---------------------------------------------------------------------------
module lqr_inverted_pendulum_top #(
  parameter int FP_W = 32,
  parameter int SHIFT = 14
)(
  input  wire              clk,
  input  wire              rst_n,
  input  wire              start_calc,    // LQRゲイン計算開始トリガ
  output logic             calc_done,     // LQRゲイン計算完了
  input  wire              sim_en,        // シミュレーション実行イネーブル
  output vec4_t            state_out,     // プラント状態出力 [x, v, theta, omega]
  output logic signed [FP_W-1:0] control_u,   // 制御入力出力
  output logic signed [FP_W-1:0] K_gain_out [0:3] // LQRゲイン出力
);

  // LQRゲイン計算器
  logic signed [FP_W-1:0] K_gain_internal [0:3];
  logic lqr_done;

  lqr_gain_calculator #(
    .FP_W     (FP_W),
    .SHIFT    (SHIFT),
    .MAX_ITER (100)
  ) u_lqr_calc (
    .clk     (clk),
    .rst_n   (rst_n),
    .start   (start_calc),
    .done    (lqr_done),
    .K_gain  (K_gain_internal)
  );

  assign calc_done = lqr_done;
  assign K_gain_out = K_gain_internal;

  // LQR制御器
  localparam logic signed [FP_W-1:0] U_MAX = 32'sd65536; // 4.0 N (4.0*16384)

  lqr_controller #(
    .FP_W  (FP_W),
    .SHIFT (SHIFT)
  ) u_lqr_ctrl (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (sim_en),
    .K_gain    (K_gain_internal),
    .state_in  (state_out),
    .u_max     (U_MAX),
    .control_u (control_u)
  );

  // 倒立振子プラント
  inverted_pendulum_plant #(
    .FP_W  (FP_W),
    .SHIFT (SHIFT)
  ) u_plant (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (sim_en),
    .control_u (control_u),
    .state_out (state_out)
  );

endmodule
