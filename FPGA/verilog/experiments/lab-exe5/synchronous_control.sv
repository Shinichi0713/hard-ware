//////////////////////////////////////////////////////////////////////////////
// 同期モータ S字速度制御器
// - S字速度プロファイル生成 (加加速度制限付き)
// - 速度PI制御器 (出力はトルク電流指令 Iq_ref)
// - Id_ref = 0 (表面磁石同期モータ SPM を想定)
//////////////////////////////////////////////////////////////////////////////

module sync_motor_scurve_ctrl #(
    parameter int WIDTH = 32,
    parameter int FRAC  = 10          // 固定小数点スケーリング (例: Q22.10)
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              enable,

    // 指令値・制約
    input  logic signed [WIDTH-1:0] target_velocity,       // 目標速度 (スケール済み)
    input  logic signed [WIDTH-1:0] actual_velocity,       // フィードバック速度
    input  logic signed [WIDTH-1:0] max_accel,             // 最大加速度 [速度単位/制御周期]
    input  logic signed [WIDTH-1:0] max_jerk,              // 最大加加速度 [加速度単位/制御周期]
    input  logic signed [WIDTH-1:0] max_torque_current,    // 最大トルク電流 (Iqリミット)

    // PIゲイン (Q22.10 など FRAC に合わせたスケール)
    input  logic signed [WIDTH-1:0] kp,
    input  logic signed [WIDTH-1:0] ki,

    // FOC / 電流制御器への出力
    output logic signed [WIDTH-1:0] id_ref,
    output logic signed [WIDTH-1:0] iq_ref,
    output logic              busy
);

    // -------------------------------------------------------------------------
    // 状態定義
    // -------------------------------------------------------------------------
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_ACC_JERK_UP,      // 加加速 (jerk > 0)
        ST_ACC_CONST,        // 等加速
        ST_ACC_JERK_DOWN,    // 減加速 (jerk < 0, accel -> 0)
        ST_STEADY,           // 定速
        ST_DEC_JERK_UP,      // 加減速 (jerk < 0, accel becomes negative)
        ST_DEC_CONST,        // 等減速
        ST_DEC_JERK_DOWN     // 減減速 (jerk > 0, accel -> 0)
    } state_t;

    state_t state;
    logic signed [WIDTH-1:0] vel_cmd;   // S字化された速度指令
    logic signed [WIDTH-1:0] accel;     // 現在の加速度
    logic signed [WIDTH-1:0] next_accel;

    logic signed [WIDTH-1:0] vel_err;   // target - vel_cmd
    logic signed [WIDTH-1:0] speed_err; // vel_cmd - actual
    logic signed [WIDTH-1:0] integrator;
    logic signed [WIDTH-1:0] p_term, i_term, pi_out;

    // -------------------------------------------------------------------------
    // 組み合わせ回路
    // -------------------------------------------------------------------------
    always_comb begin
        vel_err   = target_velocity - vel_cmd;
        speed_err = vel_cmd - actual_velocity;
        p_term    = (speed_err * kp) >>> FRAC;
        i_term    = integrator;
        pi_out    = p_term + i_term;
    end

    // -------------------------------------------------------------------------
    // 順序回路
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= ST_IDLE;
            vel_cmd     <= '0;
            accel       <= '0;
            integrator  <= '0;
            id_ref      <= '0;
            iq_ref      <= '0;
            busy        <= 1'b0;
        end else if (!enable) begin
            state       <= ST_IDLE;
            vel_cmd     <= '0;
            accel       <= '0;
            integrator  <= '0;
            id_ref      <= '0;
            iq_ref      <= '0;
            busy        <= 1'b0;
        end else begin
            busy <= (state != ST_IDLE);

            // -----------------------------------------------------------------
            // 1. S字速度プロファイル生成
            // -----------------------------------------------------------------
            case (state)
                ST_IDLE: begin
                    accel <= '0;
                    if (vel_err > max_jerk) begin
                        state <= ST_ACC_JERK_UP;
                    end else if (vel_err < -max_jerk) begin
                        state <= ST_DEC_JERK_UP;
                    end else begin
                        vel_cmd <= target_velocity;
                    end
                end

                ST_ACC_JERK_UP: begin
                    next_accel = accel + max_jerk;
                    if (next_accel > max_accel) begin
                        next_accel = max_accel;
                        state <= ST_ACC_CONST;
                    end
                    accel   <= next_accel;
                    vel_cmd <= vel_cmd + accel;

                    // 残り速度誤差が小さくなったら加加速を終了
                    if (vel_err > '0 && vel_err <= (accel + max_accel))
                        state <= ST_ACC_JERK_DOWN;
                end

                ST_ACC_CONST: begin
                    accel   <= max_accel;
                    vel_cmd <= vel_cmd + accel;
                    if (vel_err > '0 && vel_err <= accel)
                        state <= ST_ACC_JERK_DOWN;
                end

                ST_ACC_JERK_DOWN: begin
                    next_accel = accel - max_jerk;
                    if (next_accel <= '0) begin
                        next_accel = '0;
                        vel_cmd    <= target_velocity;
                        state      <= ST_STEADY;
                    end else begin
                        vel_cmd <= vel_cmd + accel;
                    end
                    accel <= next_accel;
                end

                ST_STEADY: begin
                    accel   <= '0;
                    vel_cmd <= target_velocity;
                    if (vel_err > max_accel)
                        state <= ST_ACC_JERK_UP;
                    else if (vel_err < -max_accel)
                        state <= ST_DEC_JERK_UP;
                end

                ST_DEC_JERK_UP: begin
                    next_accel = accel - max_jerk; // accel becomes negative
                    if (next_accel < -max_accel) begin
                        next_accel = -max_accel;
                        state      <= ST_DEC_CONST;
                    end
                    accel   <= next_accel;
                    vel_cmd <= vel_cmd + accel;

                    if (vel_err < '0 && -vel_err <= (-accel + max_accel))
                        state <= ST_DEC_JERK_DOWN;
                end

                ST_DEC_CONST: begin
                    accel   <= -max_accel;
                    vel_cmd <= vel_cmd + accel;
                    if (vel_err < '0 && -vel_err <= -accel)
                        state <= ST_DEC_JERK_DOWN;
                end

                ST_DEC_JERK_DOWN: begin
                    next_accel = accel + max_jerk; // return to zero
                    if (next_accel >= '0) begin
                        next_accel = '0;
                        vel_cmd    <= target_velocity;
                        state      <= ST_STEADY;
                    end else begin
                        vel_cmd <= vel_cmd + accel;
                    end
                    accel <= next_accel;
                end

                default: state <= ST_IDLE;
            endcase

            // オーバーシュート防止
            if ((target_velocity >= '0 && vel_cmd > target_velocity) ||
                (target_velocity < '0 && vel_cmd < target_velocity))
                vel_cmd <= target_velocity;

            // -----------------------------------------------------------------
            // 2. 速度PI制御器 (S字指令を追従)
            // -----------------------------------------------------------------
            // アンチワインドアップ: 出力が飽和していて誤差と同符号なら積分停止
            if ((pi_out < max_torque_current && pi_out > -max_torque_current) ||
                (speed_err > '0 && pi_out <= '0) ||
                (speed_err < '0 && pi_out >= '0)) begin
                integrator <= integrator + ((speed_err * ki) >>> FRAC);
            end

            // 積分器リミット
            if (integrator > max_torque_current)
                integrator <= max_torque_current;
            else if (integrator < -max_torque_current)
                integrator <= -max_torque_current;

            // 出力リミット (トルク電流飽和)
            if (pi_out > max_torque_current) begin
                iq_ref <= max_torque_current;
            end else if (pi_out < -max_torque_current) begin
                iq_ref <= -max_torque_current;
            end else begin
                iq_ref <= pi_out;
            end

            // d軸電流指令: 表面磁石同期モータでは弱め制御がなければ 0
            id_ref <= '0;
        end
    end

endmodule