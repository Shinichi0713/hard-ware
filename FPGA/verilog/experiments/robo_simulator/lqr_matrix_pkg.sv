`ifndef LQR_MATRIX_PKG_SV
`define LQR_MATRIX_PKG_SV

package lqr_matrix_pkg;

  import motor_control_pkg::*; // FP_SHIFT=14, FP_WIDTH=32, fp_mul等

  // 4x4 行列型
  typedef logic signed [FP_WIDTH-1:0] mat44_t [0:3][0:3];
  typedef logic signed [FP_WIDTH-1:0] vec4_t  [0:3];
  typedef logic signed [FP_WIDTH-1:0] mat14_t [0:3]; // 1x4 行ベクトル

  // -------------------------------------------------------------------------
  // スカラ逆数 (Q14) : 1/x をニュートン・ラプソン法で近似
  // -------------------------------------------------------------------------
  function automatic logic signed [FP_WIDTH-1:0] scalar_inv(
    input logic signed [FP_WIDTH-1:0] x
  );
    logic signed [FP_WIDTH-1:0] y;
    // 初期値: 1/x の粗い近似 (x が Q14 で 0.1~10 程度を想定)
    // 実際はフライン計算で定数化するか、初期値テーブルを用いる
    y = FP_ONE / (x >>> 10); // 粗い近似
    // 1回のニュートン反復: y_{n+1} = y_n * (2 - x * y_n)
    y = fp_mul(y, (FP_ONE <<< 1) - fp_mul(x, y));
    y = fp_mul(y, (FP_ONE <<< 1) - fp_mul(x, y));
    return y;
  endfunction

  // -------------------------------------------------------------------------
  // 4x4 行列加算
  // -------------------------------------------------------------------------
  function automatic mat44_t mat44_add(input mat44_t A, input mat44_t B);
    mat44_t C;
    for (int i=0; i<4; i++)
      for (int j=0; j<4; j++)
        C[i][j] = A[i][j] + B[i][j];
    return C;
  endfunction

  // -------------------------------------------------------------------------
  // 4x4 行列減算
  // -------------------------------------------------------------------------
  function automatic mat44_t mat44_sub(input mat44_t A, input mat44_t B);
    mat44_t C;
    for (int i=0; i<4; i++)
      for (int j=0; j<4; j++)
        C[i][j] = A[i][j] - B[i][j];
    return C;
  endfunction

  // -------------------------------------------------------------------------
  // 4x4 × 4x4 行列乗算 (Q14固定小数点)
  // -------------------------------------------------------------------------
  function automatic mat44_t mat44_mul(input mat44_t A, input mat44_t B);
    mat44_t C;
    for (int i=0; i<4; i++) begin
      for (int j=0; j<4; j++) begin
        logic signed [2*FP_WIDTH-1:0] acc;
        acc = '0;
        for (int k=0; k<4; k++) begin
          acc = acc + (signed'(A[i][k]) * signed'(B[k][j]));
        end
        C[i][j] = signed'(acc >>> FP_SHIFT);
      end
    end
    return C;
  endfunction

  // -------------------------------------------------------------------------
  // 4x4 転置
  // -------------------------------------------------------------------------
  function automatic mat44_t mat44_transpose(input mat44_t A);
    mat44_t At;
    for (int i=0; i<4; i++)
      for (int j=0; j<4; j++)
        At[i][j] = A[j][i];
    return At;
  endfunction

  // -------------------------------------------------------------------------
  // 4x4 × 4x1 ベクトル乗算
  // -------------------------------------------------------------------------
  function automatic vec4_t mat44_mul_vec4(input mat44_t A, input vec4_t v);
    vec4_t y;
    for (int i=0; i<4; i++) begin
      logic signed [2*FP_WIDTH-1:0] acc;
      acc = '0;
      for (int j=0; j<4; j++) begin
        acc = acc + (signed'(A[i][j]) * signed'(v[j]));
      end
      y[i] = signed'(acc >>> FP_SHIFT);
    end
    return y;
  endfunction

  // -------------------------------------------------------------------------
  // 1x4 × 4x4 行列乗算
  // -------------------------------------------------------------------------
  function automatic mat14_t mat14_mul_mat44(input mat14_t r, input mat44_t A);
    mat14_t y;
    for (int j=0; j<4; j++) begin
      logic signed [2*FP_WIDTH-1:0] acc;
      acc = '0;
      for (int i=0; i<4; i++) begin
        acc = acc + (signed'(r[i]) * signed'(A[i][j]));
      end
      y[j] = signed'(acc >>> FP_SHIFT);
    end
    return y;
  endfunction

  // -------------------------------------------------------------------------
  // 1x4 × 4x1 スカラ内積
  // -------------------------------------------------------------------------
  function automatic logic signed [FP_WIDTH-1:0] mat14_mul_vec4(
    input mat14_t r, input vec4_t v
  );
    logic signed [2*FP_WIDTH-1:0] acc;
    acc = '0;
    for (int i=0; i<4; i++) begin
      acc = acc + (signed'(r[i]) * signed'(v[i]));
    end
    return signed'(acc >>> FP_SHIFT);
  endfunction

  // -------------------------------------------------------------------------
  // 4x1 × 1x4 外積 (4x4行列)
  // -------------------------------------------------------------------------
  function automatic mat44_t vec4_outer_mat14(input vec4_t v, input mat14_t r);
    mat44_t Y;
    for (int i=0; i<4; i++)
      for (int j=0; j<4; j++)
        Y[i][j] = fp_mul(v[i], r[j]);
    return Y;
  endfunction

  // -------------------------------------------------------------------------
  // ベトル演算
  // -------------------------------------------------------------------------
  function automatic vec4_t vec4_add(input vec4_t a, input vec4_t b);
    vec4_t y;
    for (int i=0; i<4; i++) y[i] = a[i] + b[i];
    return y;
  endfunction

  function automatic vec4_t vec4_sub(input vec4_t a, input vec4_t b);
    vec4_t y;
    for (int i=0; i<4; i++) y[i] = a[i] - b[i];
    return y;
  endfunction

  function automatic vec4_t vec4_scale(input vec4_t v, input logic signed [FP_WIDTH-1:0] s);
    vec4_t y;
    for (int i=0; i<4; i++) y[i] = fp_mul(v[i], s);
    return y;
  endfunction

  // -------------------------------------------------------------------------
  // 行列スケール
  // -------------------------------------------------------------------------
  function automatic mat44_t mat44_scale(input mat44_t A, input logic signed [FP_WIDTH-1:0] s);
    mat44_t Y;
    for (int i=0; i<4; i++)
      for (int j=0; j<4; j++)
        Y[i][j] = fp_mul(A[i][j], s);
    return Y;
  endfunction

  // -------------------------------------------------------------------------
  // 行列最大絶対値差 (収束判定用)
  // -------------------------------------------------------------------------
  function automatic logic signed [FP_WIDTH-1:0] mat44_max_diff(
    input mat44_t A, input mat44_t B
  );
    logic signed [FP_WIDTH-1:0] max_val, diff;
    max_val = '0;
    for (int i=0; i<4; i++) begin
      for (int j=0; j<4; j++) begin
        diff = (A[i][j] > B[i][j]) ? (A[i][j] - B[i][j]) : (B[i][j] - A[i][j]);
        if (diff > max_val) max_val = diff;
      end
    end
    return max_val;
  endfunction

endpackage

`endif
