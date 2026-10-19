`timescale 1ns / 1ps

module stewart_top #(
    parameter int CLK_HZ = 50_000_000
)(
    input  logic        clk,
    input  logic        rst_n,
    // IMU SPI
    output logic        imu_cs_n,
    output logic        imu_sclk,
    output logic        imu_mosi,
    input  logic        imu_miso,
    // サーボ PWM 出力 x6
    output logic [5:0]  servo_pwm,
    // ステータス
    output logic        running,
    output logic        attitude_valid_led
);

    import stewart_pkg::*;

    // IMU データ
    logic signed [15:0] accel_x, accel_y, accel_z;
    logic signed [15:0] gyro_x, gyro_y, gyro_z;
    logic               imu_data_valid;
    logic               imu_busy;

    // 姿勢推定結果
    logic signed [31:0] roll, pitch;
    logic               attitude_valid;

    // 逆運動学結果
    logic signed [31:0] leg_lengths [0:5];
    logic               ik_valid;

    // タイミング制御（1kHz IMUサンプリング）
    logic [31:0] tick_counter;
    logic        sample_trigger;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_counter   <= 0;
            sample_trigger <= 0;
            running        <= 0;
        end else begin
            sample_trigger <= 0;
            if (tick_counter >= (CLK_HZ / 1000) - 1) begin  // 1ms
                tick_counter   <= 0;
                sample_trigger <= 1;
                running        <= 1;
            end else begin
                tick_counter <= tick_counter + 1;
            end
        end
    end

    // IMU SPI コントローラ
    imu_spi_controller #(
        .CLK_HZ(CLK_HZ),
        .SPI_CLK_HZ(1_000_000)
    ) u_imu_spi (
        .clk        (clk),
        .rst_n      (rst_n),
        .spi_cs_n   (imu_cs_n),
        .spi_sclk   (imu_sclk),
        .spi_mosi   (imu_mosi),
        .spi_miso   (imu_miso),
        .accel_x    (accel_x),
        .accel_y    (accel_y),
        .accel_z    (accel_z),
        .gyro_x     (gyro_x),
        .gyro_y     (gyro_y),
        .gyro_z     (gyro_z),
        .data_valid (imu_data_valid),
        .start      (sample_trigger),
        .busy       (imu_busy)
    );

    // 姿勢推定
    attitude_estimator u_attitude (
        .clk           (clk),
        .rst_n         (rst_n),
        .imu_valid     (imu_data_valid),
        .accel_x_raw   (accel_x),
        .accel_y_raw   (accel_y),
        .accel_z_raw   (accel_z),
        .gyro_x_raw    (gyro_x),
        .gyro_y_raw    (gyro_y),
        .attitude_valid(attitude_valid),
        .roll          (roll),
        .pitch         (pitch)
    );

    // 逆運動学
    stewart_ik u_ik (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (attitude_valid),
        .roll      (roll),
        .pitch     (pitch),
        .valid_out (ik_valid),
        .leg_length(leg_lengths)
    );

    // サーボ PWM 生成
    servo_pwm_generator u_pwm (
        .clk         (clk),
        .rst_n       (rst_n),
        .valid_in    (ik_valid),
        .leg_length  (leg_lengths),
        .pwm_out     (servo_pwm)
    );

    // LED インジケータ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            attitude_valid_led <= 0;
        end else begin
            attitude_valid_led <= attitude_valid;
        end
    end

endmodule