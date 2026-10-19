`timescale 1ns / 1ps

module servo_pwm_generator (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        valid_in,
    input  logic signed [31:0] leg_length [0:5],  // Q16.16 mm
    output logic [5:0]  pwm_out
);

    import stewart_pkg::*;

    // サーボ角変換パラメータ
    // 中立時のパルス幅 = 1500us
    // サーボ角範囲: ±45deg -> ±500us
    // 1deg ≈ 11.11us
    // 脚長変化 -> サーボ角変換は機構依存
    // 簡易: 脚長変化 1mm -> パルス 10us 変化（仮定）
    localparam int PULSE_CENTER_US = 1500;
    localparam int PULSE_CENTER_CNT = PULSE_CENTER_US * 1000 / PWM_CLK_NS; // 75000
    localparam int MM_TO_US_NUM = 10;   // 1mm -> 10us
    localparam int MM_TO_US_DEN = 1;

    logic [31:0] pwm_counter;
    logic [31:0] pulse_width [0:5];
    logic        update_pending;

    // クロック分周（50MHz -> 50Hz PWM）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_counter <= 0;
            pwm_out     <= 6'b000000;
            update_pending <= 0;
            for (int i = 0; i < 6; i++) pulse_width[i] <= PULSE_CENTER_CNT;
        end else begin
            // 新しい脚長データをパルス幅に変換
            if (valid_in) begin
                update_pending <= 1;
            end

            if (update_pending && pwm_counter == 0) begin
                update_pending <= 0;
                for (int i = 0; i < 6; i++) begin
                    // leg_length は Q16.16 mm
                    // delta_mm = (leg_length - NEUTRAL_HEIGHT) >> 16
                    logic signed [31:0] delta_mm;
                    logic signed [31:0] delta_us;
                    logic signed [31:0] pulse_cnt;

                    delta_mm = (leg_length[i] - NEUTRAL_HEIGHT) >>> 16;
                    delta_us = delta_mm * MM_TO_US_NUM / MM_TO_US_DEN;
                    pulse_cnt = PULSE_CENTER_CNT + (delta_us * 1000 / PWM_CLK_NS);

                    // クリップ
                    if (pulse_cnt < PWM_MIN_CNT) pulse_width[i] <= PWM_MIN_CNT;
                    else if (pulse_cnt > PWM_MAX_CNT) pulse_width[i] <= PWM_MAX_CNT;
                    else pulse_width[i] <= pulse_cnt;
                end
            end

            // PWM カウンタ
            if (pwm_counter >= PWM_PERIOD_CNT - 1) begin
                pwm_counter <= 0;
            end else begin
                pwm_counter <= pwm_counter + 1;
            end

            // PWM 出力
            for (int i = 0; i < 6; i++) begin
                pwm_out[i] <= (pwm_counter < pulse_width[i]) ? 1'b1 : 1'b0;
            end
        end
    end

endmodule