`timescale 1ns / 1ps
`include "motor_control_pkg.sv"
`include "lqr_matrix_pkg.sv"
import motor_control_pkg::*;
import lqr_matrix_pkg::*;

// ---------------------------------------------------------------------------
// LQRゲイン計算器 (離散時間Riccati方程式の反復解法)
// P_{k+1} = Q + A^T P_k A - A^T P_k B (R + B^T P_k B)^{-1} B^T P_k A
// K = (R + B^T P B)^{-1} B^T P A
// ---------------------------------------------------------------------------
module lqr_gain_calculator #(
  parameter int FP_W = 32,
  parameter int SHIFT = 14,
  parameter int MAX_ITER = 100
)(
  input  wire              clk,
  input  wire              rst_n,
  input  wire              start,
  output logic             done,
  output logic signed [FP_W-1:0] K_gain [0:3]  // 1x4 LQRゲイン行列
);

  // システムパラメータ (Q14固定小数点)
  // M=1.0, m=0.1, l=0.5, g=9.81, Ts=0.001
  // 離散化: Ad = I + A*Ts, Bd = B*Ts (前進オイラー)
  localparam logic signed [FP_W-1:0] TS_FP = 32'sd16; // 0.001*16384 ≈ 16 (粗い近似)
  // 実際にはTs=0.001はQ14では1LSB未満なので、シミュレーション用にTs=0.01とする
  // Ts=0.01 -> 0.01*16384 = 163.84 ≈ 164
  localparam logic signed [FP_W-1:0] TS_SIM = 32'sd164;

  // 連続系A行列 (Q14)
  // A = [[0, 1, 0, 0],
  //      [0, 0, -0.981, 0],
  //      [0, 0, 0, 1],
  //      [0, 0, 21.582, 0]]
  localparam mat44_t A_CONT = '{
    '{32'sd0,     FP_ONE,       32'sd0,       32'sd0},
    '{32'sd0,     32'sd0,       -32'sd16070,  32'sd0},   // -0.981*16384
    '{32'sd0,     32'sd0,       32'sd0,       FP_ONE},
    '{32'sd0,     32'sd0,       32'sd353597,  32'sd0}    // 21.582*16384
  };

  // 連続系B行列 (Q14)
  // B = [[0], [1.0], [0], [-2.0]]
  localparam vec4_t B_CONT = '{
    32'sd0,
    FP_ONE,        // 1.0
    32'sd0,
    -32'sd32768    // -2.0
  };

  // Q行列 (対角: [10, 1, 100, 1])
  localparam mat44_t Q_MAT = '{
    '{32'sd163840, 32'sd0,      32'sd0,        32'sd0},
    '{32'sd0,      FP_ONE,      32'sd0,        32'sd0},
    '{32'sd0,      32'sd0,      32'sd1638400, 32'sd0},  // 100*16384
    '{32'sd0,      32'sd0,      32'sd0,        FP_ONE}
  };

  // R行列 (スカラ: 0.1)
  localparam logic signed [FP_W-1:0] R_VAL = 32'sd1638; // 0.1*16384

  // 離散系行列
  mat44_t Ad, P_next, P_curr, APA, AT_P, AT_P_A, AT_P_B_BT_P_A;
  vec4_t  Bd, AT_P_B;
  logic signed [FP_W-1:0] Bt_P_B, denom, inv_denom;
  mat14_t K_temp;

  // 状態機
  typedef enum logic [3:0] {
    ST_IDLE,
    ST_DISCRETIZE,
    ST_INIT_P,
    ST_COMP_ATP,
    ST_COMP_ATPA,
    ST_COMP_ATPB,
    ST_COMP_BTPB,
    ST_COMP_DENOM,
    ST_COMP_K,
    ST_UPDATE_P,
    ST_CHECK_CONV,
    ST_DONE
  } lqr_state_e;

  lqr_state_e state;
  logic [7:0] iter_cnt;
  logic signed [FP_W-1:0] max_diff;

  // 離散化: Ad = I + A*Ts, Bd = B*Ts
  function automatic mat44_t discretize_A(input mat44_t A_c, input logic signed [FP_W-1:0] ts);
    mat44_t Ad_out;
    for (int i=0; i<4; i++)
      for (int j=0; j<4; j++)
        if (i==j)
          Ad_out[i][j] = FP_ONE + fp_mul(A_c[i][j], ts);
        else
          Ad_out[i][j] = fp_mul(A_c[i][j], ts);
    return Ad_out;
  endfunction

  function automatic vec4_t discretize_B(input vec4_t B_c, input logic signed [FP_W-1:0] ts);
    vec4_t Bd_out;
    for (int i=0; i<4; i++)
      Bd_out[i] = fp_mul(B_c[i], ts);
    return Bd_out;
  endfunction

  // B^T * P * B (スカラ)
  function automatic logic signed [FP_W-1:0] compute_BtPB(
    input vec4_t Bd_in, input mat44_t P_in
  );
    logic signed [2*FP_W-1:0] acc;
    logic signed [FP_W-1:0] PB [0:3];
    acc = '0;
    // P*B
    for (int i=0; i<4; i++) begin
      PB[i] = fp_mul(P_in[i][0], Bd_in[0])
             + fp_mul(P_in[i][1], Bd_in[1])
             + fp_mul(P_in[i][2], Bd_in[2])
             + fp_mul(P_in[i][3], Bd_in[3]);
    end
    // B^T * (P*B)
    acc = signed'(Bd_in[0]) * signed'(PB[0])
        + signed'(Bd_in[1]) * signed'(PB[1])
        + signed'(Bd_in[2]) * signed'(PB[2])
        + signed'(Bd_in[3]) * signed'(PB[3]);
    return signed'(acc >>> SHIFT);
  endfunction

  // A^T * P * B (4x1)
  function automatic vec4_t compute_ATPB(input mat44_t A_in, input mat44_t P_in, input vec4_t B_in);
    vec4_t y;
    logic signed [FP_W-1:0] PB [0:3];
    // P*B
    for (int i=0; i<4; i++) begin
      PB[i] = fp_mul(P_in[i][0], B_in[0])
             + fp_mul(P_in[i][1], B_in[1])
             + fp_mul(P_in[i][2], B_in[2])
             + fp_mul(P_in[i][3], B_in[3]);
    end
    // A^T * (P*B)
    for (int i=0; i<4; i++) begin
      logic signed [2*FP_W-1:0] acc;
      acc = signed'(A_in[0][i]) * signed'(PB[0])
          + signed'(A_in[1][i]) * signed'(PB[1])
          + signed'(A_in[2][i]) * signed'(PB[2])
          + signed'(A_in[3][i]) * signed'(PB[3]);
      y[i] = signed'(acc >>> SHIFT);
    end
    return y;
  endfunction

  // メイン状態機
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= ST_IDLE;
      done <= 1'b0;
      iter_cnt <= '0;
      for (int i=0; i<4; i++) K_gain[i] <= '0;
      for (int i=0; i<4; i++)
        for (int j=0; j<4; j++)
          P_curr[i][j] <= '0;
    end else begin
      case (state)
        ST_IDLE: begin
          done <= 1'b0;
          if (start) begin
            iter_cnt <= '0;
            state <= ST_DISCRETIZE;
          end
        end

        ST_DISCRETIZE: begin
          // Ad = I + A*Ts, Bd = B*Ts
          Ad <= discretize_A(A_CONT, TS_SIM);
          Bd <= discretize_B(B_CONT, TS_SIM);
          state <= ST_INIT_P;
        end

        ST_INIT_P: begin
          // P_0 = Q
          P_curr <= Q_MAT;
          state <= ST_COMP_ATP;
        end

        ST_COMP_ATP: begin
          // A^T * P
          for (int i=0; i<4; i++)
            for (int j=0; j<4; j++) begin
              logic signed [2*FP_W-1:0] acc;
              acc = signed'(Ad[0][i]) * signed'(P_curr[0][j])
                  + signed'(Ad[1][i]) * signed'(P_curr[1][j])
                  + signed'(Ad[2][i]) * signed'(P_curr[2][j])
                  + signed'(Ad[3][i]) * signed'(P_curr[3][j]);
              AT_P[i][j] <= signed'(acc >>> SHIFT);
            end
          state <= ST_COMP_ATPA;
        end

        ST_COMP_ATPA: begin
          // AT_P * Ad
          for (int i=0; i<4; i++)
            for (int j=0; j<4; j++) begin
              logic signed [2*FP_W-1:0] acc;
              acc = signed'(AT_P[i][0]) * signed'(Ad[0][j])
                  + signed'(AT_P[i][1]) * signed'(Ad[1][j])
                  + signed'(AT_P[i][2]) * signed'(Ad[2][j])
                  + signed'(AT_P[i][3]) * signed'(Ad[3][j]);
              AT_P_A[i][j] <= signed'(acc >>> SHIFT);
            end
          state <= ST_COMP_ATPB;
        end

        ST_COMP_ATPB: begin
          AT_P_B <= compute_ATPB(Ad, P_curr, Bd);
          state <= ST_COMP_BTPB;
        end

        ST_COMP_BTPB: begin
          Bt_P_B <= compute_BtPB(Bd, P_curr);
          state <= ST_COMP_DENOM;
        end

        ST_COMP_DENOM: begin
          denom <= R_VAL + Bt_P_B;
          state <= ST_COMP_K;
        end

        ST_COMP_K: begin
          // inv_denom = 1/denom
          inv_denom <= scalar_inv(denom);
          state <= ST_UPDATE_P;
        end

        ST_UPDATE_P: begin
          logic signed [FP_W-1:0] scale;
          scale = inv_denom;
          // K = scale * B^T * P * A (1x4)
          for (int j=0; j<4; j++) begin
            K_gain[j] <= fp_mul(scale, AT_P_B[j]);
            K_temp[j] <= fp_mul(scale, AT_P_B[j]);
          end
          // P = Q + AT_P_A - AT_P_B * K
          for (int i=0; i<4; i++)
            for (int j=0; j<4; j++)
              P_next[i][j] <= Q_MAT[i][j] + AT_P_A[i][j]
                            - fp_mul(AT_P_B[i], K_temp[j]);
          state <= ST_CHECK_CONV;
        end

        ST_CHECK_CONV: begin
          max_diff <= mat44_max_diff(P_next, P_curr);
          if (iter_cnt >= MAX_ITER) begin
            state <= ST_DONE;
          end else begin
            P_curr <= P_next;
            iter_cnt <= iter_cnt + 1'b1;
            state <= ST_COMP_ATP;
          end
        end

        ST_DONE: begin
          done <= 1'b1;
          if (!start) state <= ST_IDLE;
        end
      endcase
    end
  end

endmodule
