`timescale 1ns / 1ps
`include "motor_control_pkg.sv"
`include "lqr_matrix_pkg.sv"
import motor_control_pkg::*;
import lqr_matrix_pkg::*;

// ---------------------------------------------------------------------------
// LQR制御倒立振子 統合テストベンチ
// LQRゲイン計算 -> 状態フィードバック制御 -> プラントシミュレーション
// 状態と制御入力をファイルにログ出力 (Pythonで可視化可能)
// ---------------------------------------------------------------------------
module tb_lqr_inverted_pendulum;

  // クロク/リセット
  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk; // 100MHz

  // 入力信号
  logic start_calc;
  logic sim_en;

  // 出力信号
  logic calc_done;
  vec4_t state_out;
  logic signed [FP_WIDTH-1:0] control_u;
  logic signed [FP_WIDTH-1:0] K_gain_out [0:3];

  // DUT
  lqr_inverted_pendulum_top #(
    .FP_W  (32),
    .SHIFT (14)
  ) u_dut (
    .clk         (clk),
    .rst_n       (rst_n),
    .start_calc  (start_calc),
    .calc_done   (calc_done),
    .sim_en      (sim_en),
    .state_out   (state_out),
    .control_u   (control_u),
    .K_gain_out  (K_gain_out)
  );

  // シミュレーションパラメータ
  localparam int SIM_CYCLES = 10000; // 10000 * 10ns = 100us (Ts=0.01s で1000ステップ)
  localparam int TS_TICKS = 1000000; // 0.01s = 1ms * 1000 = 1000000 * 10ns
  logic [31:0] tick_cnt;
  logic sample_tick;

  // サンプリングトリガ (Ts = 0.01s)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tick_cnt <= '0;
      sample_tick <= 1'b0;
    end else begin
      if (tick_cnt >= TS_TICKS - 1) begin
        tick_cnt <= '0;
        sample_tick <= 1'b1;
      end else begin
        tick_cnt <= tick_cnt + 1'b1;
        sample_tick <= 1'b0;
      end
    end
  end

  // ログファイル出力
  int log_fd;
  int step_cnt;

  // Q14 -> 実数変換関数 (テストベンチ用)
  function real fp_to_real(input logic signed [FP_WIDTH-1:0] val);
    return real'(val) / real'(1 << FP_SHIFT);
  endfunction

  // -------------------------------------------------------------------------
  // テストシーケンス
  // -------------------------------------------------------------------------
  initial begin
    // 初期化
    rst_n <= 1'b0;
    start_calc <= 1'b0;
    sim_en <= 1'b0;
    step_cnt <= 0;

    // ログファイルオープン
    log_fd = $fopen("lqr_sim_log.csv", "w");
    if (log_fd == 0) begin
      $display("ERROR: Could not open log file!");
      $finish;
    end
    $fwrite(log_fd, "step,time_s,x_m,v_ms,theta_rad,omega_rads,u_n\n");

    #100;
    rst_n <= 1'b1;
    #100;

    // LQRゲイン計算開始
    $display("============================================");
    $display("LQRゲイン計算開始");
    $display("============================================");
    start_calc <= 1'b1;
    @(posedge clk);
    start_calc <= 1'b0;

    // 計算完了待ち
    wait(calc_done);
    @(posedge clk);
    $display("LQRゲイン計算完了!");
    $display("K = [%0.6f, %0.6f, %0.6f, %0.6f]",
      fp_to_real(K_gain_out[0]),
      fp_to_real(K_gain_out[1]),
      fp_to_real(K_gain_out[2]),
      fp_to_real(K_gain_out[3])
    );

    #100;

    // シミュレーション開始
    $display("============================================");
    $display("シミレーション開始 (初期角度: 0.3 rad)");
    $display("============================================");
    sim_en <= 1'b1;

    // シミュレーション実行
    repeat (SIM_CYCLES) begin
      @(posedge clk);
      if (sample_tick) begin
        step_cnt <= step_cnt + 1;
        $fwrite(log_fd, "%0d,%0.4f,%0.6f,%0.6f,%0.6f,%0.6f,%0.6f\n",
          step_cnt,
          real'(step_cnt) * 0.01,
          fp_to_real(state_out[0]),
          fp_to_real(state_out[1]),
          fp_to_real(state_out[2]),
          fp_to_real(state_out[3]),
          fp_to_real(control_u)
        );

        // 100ステップごとに状態を表示
        if (step_cnt % 100 == 0) begin
          $display("[Step %0d] x=%0.4f v=%0.4f theta=%0.4f omega=%0.4f u=%0.4f",
            step_cnt,
            fp_to_real(state_out[0]),
            fp_to_real(state_out[1]),
            fp_to_real(state_out[2]),
            fp_to_real(state_out[3]),
            fp_to_real(control_u)
          );
        end
      end
    end

    sim_en <= 1'b0;
    $fclose(log_fd);

    $display("============================================");
    $display("シミュレーション完了!");
    $display("ログファイル: lqr_sim_log.csv");
    $display("============================================");

    $finish;
  end

  // 波形ダンプ
  initial begin
    $dumpfile("lqr_inverted_pendulum_tb.vcd");
    $dumpvars(0, tb_lqr_inverted_pendulum);
  end

  // タイムアウト監視
  initial begin
    #100000000;
    $display("TIMEOUT!");
    $finish;
  end

endmodule
