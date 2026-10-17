// ============================================================================
// Stewart Platform Horizontal-Level Controller (SystemVerilog)
// ============================================================================
// IMUのロール・ピッチ計測値を入力として、6自由度スチュアートプラットホームの
// 各アクチュエータ長さを制御し、プラットフォームを常に地面と水平に保つ。
//
// 固定小数点形式: Q16.16 (16bit整数部 + 16bit小数部)
// 角度単位: ラジアン (Q16.16)
// 長さ単位: メートル (Q16.16)
// ============================================================================

`timescale 1ns / 1ps

// ----------------------------------------------------------------------------
// 固定小数点ユーティリティパッケージ (Q16.16)
// ----------------------------------------------------------------------------
package fixed_point_pkg;
    localparam int FRAC_BITS = 16;
    localparam int SCALE     = 1 << FRAC_BITS;  // 65536

    // Q16.16 乗算 (a*b) -> c
    // 入力はQ16.16、出力もQ16.16
    function automatic signed [31:0] qmul(
        input signed [31:0] a,
        input signed [31:0] b
    );
        logic signed [63:0] tmp;
        tmp = ( (64'(a)) * (64'(b)) );
        qmul = tmp[31 + FRAC_BITS : FRAC_BITS];
    endfunction

    // Q16.16 MAC (累積乗算加算): acc = acc + a*b
    function automatic signed [47:0] qmac48(
        input signed [47:0] acc,
        input signed [31:0] a,
        input signed [31:0] b
    );
        logic signed [63:0] tmp;
        tmp = ( (64'(a)) * (64'(b)) );
        qmac48 = acc + (tmp >>> FRAC_BITS);
    endfunction

    // Q16.16 飽和クリップ (出力幅指定)
    function automatic signed [31:0] qclip32(
        input signed [47:0] val
    );
        if (val >  signed'(48'h7FFF_FFFF_FFFF)) qclip32 = 32'h7FFF_FFFF;
        else if (val < signed'(48'h8000_0000_0000)) qclip32 = 32'h8000_0000;
        else qclip32 = val[31:0];
    endfunction

    // ラジアン→Q16.16 変換ヘルパー (float rad * SCALE)
    // 例: 0.5 rad -> 0.5 * 65536 = 32768
endpackage

// ----------------------------------------------------------------------------
// PID Controller (Q16.16 fixed-point)
// ----------------------------------------------------------------------------
module imu_pid_controller #(
    parameter signed [31:0] Kp = 32'd13107,   // 0.2  * 65536
    parameter signed [31:0] Ki = 32'd655,     // 0.01 * 65536
    parameter signed [31:0] Kd = 32'd6553,    // 0.1  * 65536
    parameter signed [31:0] OUT_MAX = 32'd65536, // +1.0 m (or rad)
    parameter signed [31:0] OUT_MIN = -32'd65536  // -1.0 m (or rad)
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic [31:0] setpoint,   // Q16.16 目標値 (通常 0)
    input  logic [31:0] measured,   // Q16.16 計測値
    output logic [31:0] control     // Q16.16 制御出力
);
    import fixed_point_pkg::*;

    logic signed [31:0] error, error_prev;
    logic signed [47:0] integral;
    logic signed [31:0] derivative;
    logic signed [47:0] p_term, i_term, d_term;
    logic signed [47:0] control48;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            error      <= '0;
            error_prev <= '0;
            integral   <= '0;
            derivative <= '0;
            control    <= '0;
        end else if (en) begin
            // 誤差計算
            error <= setpoint - measured;

            // 積分項 (アンチワインドアップ付き)
            if ((control48 > OUT_MAX && error > 0) ||
                (control48 < OUT_MIN && error < 0)) begin
                // 飽和時は積分を更新しない
                integral <= integral;
            end else begin
                integral <= integral + error;
            end

            // 微分項
            derivative <= error - error_prev;
            error_prev <= error;

            // PID項計算
            p_term = qmac48('0, Kp, error);
            i_term = qmac48('0, Ki, integral[31:0]);
            d_term = qmac48('0, Kd, derivative);

            control48 = p_term + i_term + d_term;

            // 飽和処理
            if (control48 > OUT_MAX) control <= OUT_MAX;
            else if (control48 < OUT_MIN) control <= OUT_MIN;
            else control <= control48[31:0];
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Jacobian Transform (Roll/Pitch/Heave -> 6 Actuator Lengths)
// 線形化ヤコビアン: delta_l = J * [roll; pitch; heave]
// ノミナル長さを加算して絶対長さを出力
// ----------------------------------------------------------------------------
module jacobian_transform (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic [31:0] roll,     // Q16.16 ラジアン (PID出力)
    input  logic [31:0] pitch,    // Q16.16 ラジアン (PID出力)
    input  logic [31:0] heave,    // Q16.16 メートル (通常0 or 手動入力)
    output logic [31:0] length0,  // Q16.16 アクチュエータ長さ
    output logic [31:0] length1,
    output logic [31:0] length2,
    output logic [31:0] length3,
    output logic [31:0] length4,
    output logic [31:0] length5
);
    import fixed_point_pkg::*;

    // ------------------------------------------------------------------------
    // プラットフォーム幾何パラメータ (Q16.16)
    // ノミナルアクチュエータ長さ: ~0.3107 m
    // ------------------------------------------------------------------------
    localparam signed [31:0] L0_NOM = 32'd20360;  // 0.3107 * 65536

    // ヤコビアン係数 (Q16.16)
    // J = [[ 0.04828, -0.08363, 0.96564],
    //      [ 0.09656,  0.0,     0.96564],
    //      [ 0.04828,  0.08363, 0.96564],
    //      [-0.04828,  0.08363, 0.96564],
    //      [-0.09656,  0.0,     0.96564],
    //      [-0.04828, -0.08363, 0.96564]]
    localparam signed [31:0] J_R0 = 32'd3164;   // +0.04828
    localparam signed [31:0] J_R1 = 32'd6328;   // +0.09656
    localparam signed [31:0] J_R3 = -32'd3164;  // -0.04828
    localparam signed [31:0] J_R4 = -32'd6328;  // -0.09656

    localparam signed [31:0] J_P0 = -32'd5481;  // -0.08363
    localparam signed [31:0] J_P2 = 32'd5481;   // +0.08363

    localparam signed [31:0] J_H  = 32'd63284;  // +0.96564 (heave共通)

    logic signed [47:0] acc0, acc1, acc2, acc3, acc4, acc5;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            length0 <= L0_NOM;
            length1 <= L0_NOM;
            length2 <= L0_NOM;
            length3 <= L0_NOM;
            length4 <= L0_NOM;
            length5 <= L0_NOM;
        end else if (en) begin
            // length_i = L0_NOM + J[i,0]*roll + J[i,1]*pitch + J[i,2]*heave
            acc0 = qmac48(qmac48(qmac48(48'(L0_NOM), J_R0, roll), J_P0, pitch), J_H, heave);
            acc1 = qmac48(qmac48(qmac48(48'(L0_NOM), J_R1, roll), 32'd0, pitch), J_H, heave);
            acc2 = qmac48(qmac48(qmac48(48'(L0_NOM), J_R0, roll), J_P2, pitch), J_H, heave);
            acc3 = qmac48(qmac48(qmac48(48'(L0_NOM), J_R3, roll), J_P2, pitch), J_H, heave);
            acc4 = qmac48(qmac48(qmac48(48'(L0_NOM), J_R4, roll), 32'd0, pitch), J_H, heave);
            acc5 = qmac48(qmac48(qmac48(48'(L0_NOM), J_R3, roll), J_P0, pitch), J_H, heave);

            length0 <= qclip32(acc0);
            length1 <= qclip32(acc1);
            length2 <= qclip32(acc2);
            length3 <= qclip32(acc3);
            length4 <= qclip32(acc4);
            length5 <= qclip32(acc5);
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Actuator Interface (Length -> PWM or DAC output)
// サーボ/リニアアクチュエータへのPWMデューティ変換
// ----------------------------------------------------------------------------
module actuator_interface #(
    parameter signed [31:0] L_MIN = 32'd13107,  // 0.2 m
    parameter signed [31:0] L_MAX = 32'd52428,  // 0.8 m (例)
    parameter int           PWM_MAX = 1023      // 10bit PWM分解能
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic [31:0] length_q16, // Q16.16 目標長さ
    output logic [9:0]  pwm_duty    // PWMデューティ (0~1023)
);
    import fixed_point_pkg::*;

    logic signed [31:0] clamped_len;
    logic signed [47:0] norm48;     // 正規化値 (0.0 ~ 1.0 in Q16.16)
    logic        [31:0] norm_q16;
    logic        [47:0] duty48;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_duty <= '0;
        end else if (en) begin
            // 長さを飽和
            if (length_q16 > L_MAX) clamped_len = L_MAX;
            else if (length_q16 < L_MIN) clamped_len = L_MIN;
            else clamped_len = length_q16;

            // norm = (clamped - L_MIN) / (L_MAX - L_MIN)
            // Q16.16 で: norm = (clamped - L_MIN) * SCALE / (L_MAX - L_MIN)
            norm48 = (48'(clamped_len - L_MIN) <<< FRAC_BITS) / (L_MAX - L_MIN);
            norm_q16 = norm48[31:0];

            // duty = norm * PWM_MAX
            duty48 = (norm_q16 * PWM_MAX);
            pwm_duty <= duty48[(31+FRAC_BITS)-:10]; // 上位10bitを抽出
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Top-Level Stewart Platform Horizontal-Level Controller
// ----------------------------------------------------------------------------
module stewart_platform_controller #(
    parameter signed [31:0] PID_KP = 32'd13107,   // 0.2
    parameter signed [31:0] PID_KI = 32'd655,    // 0.01
    parameter signed [31:0] PID_KD = 32'd6553,    // 0.1
    parameter signed [31:0] PID_MAX = 32'd6554,  // +0.1 rad 制御上限
    parameter signed [31:0] PID_MIN = -32'd6554   // -0.1 rad 制御下限
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,

    // IMU入力 (Q16.16 ラジアン)
    input  logic [31:0] imu_roll,     // ロール角
    input  logic [31:0] imu_pitch,    // ピッチ角

    // 手動ヒーブ(上下)入力 (Q16.16 メートル、通常0)
    input  logic [31:0] cmd_heave,

    // アクチュエータPWM出力
    output logic [9:0]  pwm0,
    output logic [9:0]  pwm1,
    output logic [9:0]  pwm2,
    output logic [9:0]  pwm3,
    output logic [9:0]  pwm4,
    output logic [9:0]  pwm5,

    // 内部モニタ出力 (Q16.16、デバッグ用)
    output logic [31:0] dbg_roll_ctrl,
    output logic [31:0] dbg_pitch_ctrl,
    output logic [31:0] dbg_length0,
    output logic [31:0] dbg_length1,
    output logic [31:0] dbg_length2,
    output logic [31:0] dbg_length3,
    output logic [31:0] dbg_length4,
    output logic [31:0] dbg_length5
);

    logic [31:0] roll_ctrl;
    logic [31:0] pitch_ctrl;
    logic [31:0] length0, length1, length2, length3, length4, length5;

    // 水平目標値 = 0 (Q16.16)
    localparam logic [31:0] ZERO_SETPOINT = 32'd0;

    // ------------------------------------------------------------------------
    // Roll PID
    // ------------------------------------------------------------------------
    imu_pid_controller #(
        .Kp     (PID_KP),
        .Ki     (PID_KI),
        .Kd     (PID_KD),
        .OUT_MAX(PID_MAX),
        .OUT_MIN(PID_MIN)
    ) u_pid_roll (
        .clk       (clk),
        .rst_n     (rst_n),
        .en        (en),
        .setpoint  (ZERO_SETPOINT),
        .measured  (imu_roll),
        .control   (roll_ctrl)
    );

    // ------------------------------------------------------------------------
    // Pitch PID
    // ------------------------------------------------------------------------
    imu_pid_controller #(
        .Kp     (PID_KP),
        .Ki     (PID_KI),
        .Kd     (PID_KD),
        .OUT_MAX(PID_MAX),
        .OUT_MIN(PID_MIN)
    ) u_pid_pitch (
        .clk       (clk),
        .rst_n     (rst_n),
        .en        (en),
        .setpoint  (ZERO_SETPOINT),
        .measured  (imu_pitch),
        .control   (pitch_ctrl)
    );

    // ------------------------------------------------------------------------
    // Jacobian Transform (Roll/Pitch/Heave -> 6 Lengths)
    // ------------------------------------------------------------------------
    jacobian_transform u_jacobian (
        .clk     (clk),
        .rst_n   (rst_n),
        .en      (en),
        .roll    (roll_ctrl),
        .pitch   (pitch_ctrl),
        .heave   (cmd_heave),
        .length0 (length0),
        .length1 (length1),
        .length2 (length2),
        .length3 (length3),
        .length4 (length4),
        .length5 (length5)
    );

    // ------------------------------------------------------------------------
    // Actuator Interfaces (6ch)
    // ------------------------------------------------------------------------
    actuator_interface u_act0 (.clk(clk), .rst_n(rst_n), .en(en), .length_q16(length0), .pwm_duty(pwm0));
    actuator_interface u_act1 (.clk(clk), .rst_n(rst_n), .en(en), .length_q16(length1), .pwm_duty(pwm1));
    actuator_interface u_act2 (.clk(clk), .rst_n(rst_n), .en(en), .length_q16(length2), .pwm_duty(pwm2));
    actuator_interface u_act3 (.clk(clk), .rst_n(rst_n), .en(en), .length_q16(length3), .pwm_duty(pwm3));
    actuator_interface u_act4 (.clk(clk), .rst_n(rst_n), .en(en), .length_q16(length4), .pwm_duty(pwm4));
    actuator_interface u_act5 (.clk(clk), .rst_n(rst_n), .en(en), .length_q16(length5), .pwm_duty(pwm5));

    // ------------------------------------------------------------------------
    // Debug outputs
    // ------------------------------------------------------------------------
    assign dbg_roll_ctrl  = roll_ctrl;
    assign dbg_pitch_ctrl = pitch_ctrl;
    assign dbg_length0    = length0;
    assign dbg_length1    = length1;
    assign dbg_length2    = length2;
    assign dbg_length3    = length3;
    assign dbg_length4    = length4;
    assign dbg_length5    = length5;

endmodule

// ----------------------------------------------------------------------------
// Testbench (簡易シミュレーション例)
// ----------------------------------------------------------------------------
`ifdef SIMULATION
module tb_stewart_platform_controller;
    import fixed_point_pkg::*;

    logic clk = 0;
    logic rst_n;
    logic en;

    logic [31:0] imu_roll, imu_pitch;
    logic [31:0] cmd_heave;

    logic [9:0] pwm0, pwm1, pwm2, pwm3, pwm4, pwm5;
    logic [31:0] dbg_roll, dbg_pitch;
    logic [31:0] dbg_l0, dbg_l1, dbg_l2, dbg_l3, dbg_l4, dbg_l5;

    always #5 clk = ~clk;  // 100MHz

    stewart_platform_controller dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .en            (en),
        .imu_roll      (imu_roll),
        .imu_pitch     (imu_pitch),
        .cmd_heave     (cmd_heave),
        .pwm0          (pwm0),
        .pwm1          (pwm1),
        .pwm2          (pwm2),
        .pwm3          (pwm3),
        .pwm4          (pwm4),
        .pwm5          (pwm5),
        .dbg_roll_ctrl (dbg_roll),
        .dbg_pitch_ctrl(dbg_pitch),
        .dbg_length0   (dbg_l0),
        .dbg_length1   (dbg_l1),
        .dbg_length2   (dbg_l2),
        .dbg_length3   (dbg_l3),
        .dbg_length4   (dbg_l4),
        .dbg_length5   (dbg_l5)
    );

    initial begin
        $display("============================================================");
        $display(" Stewart Platform Horizontal-Level Controller Testbench");
        $display("============================================================");

        rst_n = 0;
        en = 0;
        imu_roll  = 32'd0;   // 0 rad
        imu_pitch = 32'd0;   // 0 rad
        cmd_heave = 32'd0;   // 0 m

        #100;
        rst_n = 1;
        #20;
        en = 1;

        // ケース1: プラットフォームが +5度 (0.0873 rad) ロール傾いている
        #100;
        imu_roll = 32'd5729;  // 0.0873 rad (approx +5 deg)
        $display("[T=%0t] Set IMU Roll = +5 deg (0.0873 rad)", $time);

        #5000;
        $display("[T=%0t] Roll Ctrl = %0d (Q16.16), Lengths = %0d %0d %0d %0d %0d %0d",
                 $time, dbg_roll, dbg_l0, dbg_l1, dbg_l2, dbg_l3, dbg_l4, dbg_l5);

        // ケース2: プラットフォームが -3度 (-0.0524 rad) ピッチ傾いている
        imu_roll  = 32'd0;
        imu_pitch = -32'd3438; // -0.0524 rad (approx -3 deg)
        $display("[T=%0t] Set IMU Pitch = -3 deg (-0.0524 rad)", $time);

        #5000;
        $display("[T=%0t] Pitch Ctrl = %0d (Q16.16), Lengths = %0d %0d %0d %0d %0d %0d",
                 $time, dbg_pitch, dbg_l0, dbg_l1, dbg_l2, dbg_l3, dbg_l4, dbg_l5);

        // ケース3: ロール+ピッチ複合
        imu_roll  = 32'd2865;  // +2.5 deg
        imu_pitch = -32'd2299; // -2.0 deg
        $display("[T=%0t] Set IMU Roll=+2.5deg, Pitch=-2.0deg", $time);

        #5000;
        $display("[T=%0t] Roll=%0d Pitch=%0d, Lengths=%0d %0d %0d %0d %0d %0d",
                 $time, dbg_roll, dbg_pitch,
                 dbg_l0, dbg_l1, dbg_l2, dbg_l3, dbg_l4, dbg_l5);

        $display("============================================================");
        $display(" Simulation Finished");
        $display("============================================================");
        $finish;
    end
endmodule
`endif
