`timescale 1ns / 1ps
`include "motor_control_pkg.sv"
`include "lqr_matrix_pkg.sv"
import motor_control_pkg::*;
import lqr_matrix_pkg::*;

// ---------------------------------------------------------------------------
// 倒立振子プラント (非線形状態方程式, 前進オイラー積分)
// dx/dt = f(x, u) を Ts=0.01s で積分
// ---------------------------------------------------------------------------
module inverted_pendulum_plant #(
  parameter int FP_W = 32,
  parameter int SHIFT = 14
)(
  input  wire              clk,
  input  wire              rst_n,
  input  wire              en,
  input  wire signed [FP_W-1:0] control_u, // 制御入力 [N] (Q14)
  output vec4_t            state_out        // [x, v, theta, omega] (Q14)
);

  // 物理パラメータ (Q14)
  localparam logic signed [FP_W-1:0] M_FP  = 32'sd16384;      // M = 1.0
  localparam logic signed [FP_W-1:0] m_FP  = 32'sd1638;       // m = 0.1
  localparam logic signed [FP_W-1:0] l_FP  = 32'sd8192;       // l = 0.5
  localparam logic signed [FP_W-1:0] g_FP  = 32'sd160700;    // g = 9.81
  localparam logic signed [FP_W-1:0] TS_FP = 32'sd164;       // Ts = 0.01 (Q14)

  // 状態レジスタ
  vec4_t state;
  assign state_out = state;

  // 三角関数近似 (コーディックまたは多項式近似)
  // 簡易: sin(x) ≈ x - x^3/6, cos(x) ≈ 1 - x^2/2 (小角度近似)
  // より精度を求める場合はLUTまたはCORDICを用いる
  function automatic logic signed [FP_W-1:0] sin_approx(
    input logic signed [FP_W-1:0] theta
  );
    logic signed [FP_W-1:0] theta2, theta3, term;
    theta2 = fp_mul(theta, theta);
    theta3 = fp_mul(theta2, theta);
    // sin(θ) ≈ θ - θ^3/6
    term = fp_mul(theta3, 32'sd2731); // 1/6 ≈ 0.1667 -> 2731 in Q14
    return theta - term;
  endfunction

  function automatic logic signed [FP_W-1:0] cos_approx(
    input logic signed [FP_W-1:0] theta
  );
    logic signed [FP_W-1:0] theta2, term;
    theta2 = fp_mul(theta, theta);
    // cos(θ) ≈ 1 - θ^2/2
    term = fp_mul(theta2, FP_ONE >>> 1); // /2
    return FP_ONE - term;
  endfunction

  // 状態方程式 dx/dt = f(x,u)
  // dx1 = v
  // dv  = (u + m*sinθ*(l*ω^2 + g*cosθ)) / (M + m*sin²θ)
  // dθ  = ω
  // dω  = (-u*cosθ - m*l*ω²*sinθ*cosθ - (M+m)*g*sinθ) / (l*(M + m*sin²θ))
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state[0] <= '0;  // x = 0
      state[1] <= '0;  // v = 0
      state[2] <= 32'sd4915; // theta = 0.3 rad (0.3*16384=4915)
      state[3] <= '0;  // omega = 0
    end else if (en) begin
      logic signed [FP_W-1:0] sin_t, cos_t;
      logic signed [FP_W-1:0] omega_sq;
      logic signed [FP_W-1:0] denom; // M + m*sin²θ
      logic signed [FP_W-1:0] num_dv, num_domega;
      logic signed [FP_W-1:0] dx, dv, dtheta, domega;
      logic signed [FP_W-1:0] l_omega_sq, m_l_omega_sq;
      logic signed [FP_W-1:0] m_plus_M;

      sin_t = sin_approx(state[2]);
      cos_t = cos_approx(state[2]);
      omega_sq = fp_mul(state[3], state[3]);

      // denom = M + m*sin²θ
      denom = M_FP + fp_mul(m_FP, fp_mul(sin_t, sin_t));
      m_plus_M = M_FP + m_FP;

      // dv numerator = u + m*sinθ*(l*ω² + g*cosθ)
      l_omega_sq = fp_mul(l_FP, omega_sq);
      num_dv = control_u + fp_mul(m_FP, fp_mul(sin_t, l_omega_sq + fp_mul(g_FP, cos_t)));
      dv = fp_mul(num_dv, scalar_inv(denom));

      // domega numerator = -u*cosθ - m*l*ω²*sinθ*cosθ - (M+m)*g*sinθ
      m_l_omega_sq = fp_mul(m_FP, fp_mul(l_FP, fp_mul(omega_sq, fp_mul(sin_t, cos_t))));
      num_domega = -fp_mul(control_u, cos_t) - m_l_omega_sq
                   - fp_mul(m_plus_M, fp_mul(g_FP, sin_t));
      domega = fp_mul(num_domega, scalar_inv(fp_mul(l_FP, denom)));

      dx = state[1];
      dtheta = state[3];

      // 前進オイラー積分: x_{k+1} = x_k + dx * Ts
      state[0] <= state[0] + fp_mul(dx, TS_FP);
      state[1] <= state[1] + fp_mul(dv, TS_FP);
      state[2] <= state[2] + fp_mul(dtheta, TS_FP);
      state[3] <= state[3] + fp_mul(domega, TS_FP);
    end
  end

endmodule
