`timescale 1ms / 1us
// ============================================================
// SystemVerilog: LQR制御による台車型ロボットの位置追従シミュレーション
// ============================================================
// 動作内容:
//   1次元水平面上の台車（質量 m=1.0kg, 粘性摩擦 b=0.3N·s/m）を
//   LQR状態フィードバック（K=[10.0, 5.1854]）で目標位置 r=5.0m へ追従させる。
//   オイラー法（dt=50ms）で連続系を離散化し、200ステップ（10秒）シミュレートする。
//
// 実行方法（Google Colab 例）:
//   !apt-get update -qq && apt-get install -y -qq iverilog > /dev/null 2>&1
//   !iverilog -g2012 -o robot_control.vvp robot_control_lqr.sv
//   !vvp robot_control.vvp
//   # 生成された robot_trajectory.txt を Python でプロット可能
// ============================================================

module cart_robot_lqr;

  // --------------------------------------------------
  // パラメータ設定
  // --------------------------------------------------
  // 物理パラメータ
  const real m = 1.0;                 // 質量 [kg]
  const real b = 0.3;                 // 粘性係数 [N·s/m]

  // LQRゲイン（Python control.lqr の計算結果を直接使用）
  const real K1 = 10.0;               // 位置フィードバックゲイン
  const real K2 = 5.18543526;         // 速度フィードバックゲイン

  // 参照入力スケーリング（Nbar ≒ 10.0）
  const real Nbar = 10.0;

  // 目標位置
  const real r_target = 5.0;          // [m]

  // シミュレーションパラメータ
  const real dt = 0.05;               // 刻み幅 [s] (= 50 ms)
  const int  TOTAL_STEPS = 200;       // 10.0 s / 0.05 s = 200 ステップ

  // --------------------------------------------------
  // 閉ループ連続系行列（A_cl = A - B*K, B_cl = B*Nbar）
  // A = [[0, 1], [0, -b/m]]  B = [[0], [1/m]]
  // A_cl = [[0, 1], [-K1/m, -(b/m + K2/m)]]
  // B_cl = [[0], [Nbar/m]]
  // --------------------------------------------------
  const real A_cl_11 = 0.0;
  const real A_cl_12 = 1.0;
  const real A_cl_21 = -K1 / m;
  const real A_cl_22 = -(b + K2) / m;

  const real B_cl_1  = 0.0;
  const real B_cl_2  = Nbar / m;

  // --------------------------------------------------
  // 状態変数
  // --------------------------------------------------
  real pos;   // 位置 p [m]
  real vel;   // 速度 v [m/s]
  real u;     // 制御入力（駆動力）[N]

  int step_count;

  // 出力ファイル用ディスクリプタ
  int fd;

  // --------------------------------------------------
  // 初期化
  // --------------------------------------------------
  initial begin
    // 初期状態 x0 = [0.0, 0.0]
    pos = 0.0;
    vel = 0.0;
    step_count = 0;

    // VCD波形ダンプ（GTKWave等で閲覧可能）
    $dumpfile("robot_control_lqr.vcd");
    $dumpvars(0, cart_robot_lqr);

    // 軌跡テキストファイル出力（時刻, 位置, 速度, 入力）
    fd = $fopen("robot_trajectory.txt", "w");
    if (fd == 0) begin
      $display("Error: Could not open robot_trajectory.txt");
      $finish;
    end
    $fdisplay(fd, "# time[s] position[m] velocity[m/s] input[N]");
    $fdisplay(fd, "%0.3f %0.6f %0.6f %0.6f", 0.0, pos, vel, u);

    $display("================================================");
    $display(" LQR Cart Robot Position Control Simulation");
    $display(" Target = %0.1f m | dt = %0.2f s | Steps = %0d", r_target, dt, TOTAL_STEPS);
    $display("================================================");
    $display("%8s %12s %12s %12s", "time[s]", "pos[m]", "vel[m/s]", "u[N]");
    $display("------------------------------------------------");
    $display("%8.3f %12.6f %12.6f %12.6f", 0.0, pos, vel, u);
  end

  // --------------------------------------------------
  // 制御入力計算（組み込みクロック毎に実行）
  // u = -K*x + Nbar*r = -K1*pos - K2*vel + Nbar*r_target
  // --------------------------------------------------
  always @(*) begin
    u = -K1 * pos - K2 * vel + Nbar * r_target;
  end

  // --------------------------------------------------
  // 状態更新（オイラー法による数値積分）
  //   dx/dt = A_cl*x + B_cl*r
  //   p_{k+1} = p_k + dt * (A_cl_11*p_k + A_cl_12*v_k + B_cl_1*r)
  //   v_{k+1} = v_k + dt * (A_cl_21*p_k + A_cl_22*v_k + B_cl_2*r)
  // --------------------------------------------------
  always #(50) begin  // 50 ms 毎に更新
    if (step_count < TOTAL_STEPS) begin
      real pos_next, vel_next;

      pos_next = pos + dt * (A_cl_11 * pos + A_cl_12 * vel + B_cl_1 * r_target);
      vel_next = vel + dt * (A_cl_21 * pos + A_cl_22 * vel + B_cl_2 * r_target);

      pos = pos_next;
      vel = vel_next;
      step_count = step_count + 1;

      // 画面出力（10ステップ毎にサンプリング表示）
      if ((step_count % 10) == 0 || step_count == TOTAL_STEPS) begin
        $display("%8.3f %12.6f %12.6f %12.6f",
                 step_count * dt, pos, vel, u);
      end

      // ファイル出力（全ステップ）
      $fdisplay(fd, "%0.3f %0.6f %0.6f %0.6f",
                step_count * dt, pos, vel, u);
    end else begin
      // シミュレーション終了処
      $fclose(fd);
      $display("------------------------------------------------");
      $display(" Simulation completed. Results saved to:");
      $display("   - robot_trajectory.txt");
      $display("   - robot_control_lqr.vcd");
      $display("================================================");
      $finish;
    end
  end

endmodule
