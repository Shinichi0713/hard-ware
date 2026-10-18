`timescale 1ns / 1ps

module imu_spi_controller #(
    parameter int CLK_HZ = 50_000_000,
    parameter int SPI_CLK_HZ = 1_000_000
)(
    input  logic        clk,
    input  logic        rst_n,
    // SPI 物理インターフェース
    output logic        spi_cs_n,
    output logic        spi_sclk,
    output logic        spi_mosi,
    input  logic        spi_miso,
    // 出力データ
    output logic signed [15:0] accel_x,
    output logic signed [15:0] accel_y,
    output logic signed [15:0] accel_z,
    output logic signed [15:0] gyro_x,
    output logic signed [15:0] gyro_y,
    output logic signed [15:0] gyro_z,
    output logic        data_valid,
    // 設定
    input  logic        start,
    output logic        busy
);

    import stewart_pkg::*;

    localparam int SCLK_DIV = CLK_HZ / (2 * SPI_CLK_HZ);

    typedef enum logic [3:0] {
        ST_IDLE,
        ST_INIT_PWR,
        ST_READ_ACCEL_XH,
        ST_READ_ACCEL_XL,
        ST_READ_ACCEL_YH,
        ST_READ_ACCEL_YL,
        ST_READ_ACCEL_ZH,
        ST_READ_ACCEL_ZL,
        ST_READ_GYRO_XH,
        ST_READ_GYRO_XL,
        ST_READ_GYRO_YH,
        ST_READ_GYRO_YL,
        ST_READ_GYRO_ZH,
        ST_READ_GYRO_ZL,
        ST_DONE
    } state_t;

    state_t state, next_state;

    logic [7:0]  tx_byte;
    logic [7:0]  rx_byte;
    logic [15:0] sclk_cnt;
    logic [3:0]  bit_cnt;
    logic        spi_active;
    logic [15:0] accel_x_raw, accel_y_raw, accel_z_raw;
    logic [15:0] gyro_x_raw,  gyro_y_raw,  gyro_z_raw;

    // SPI クロック生成（簡易版）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_cnt <= 0;
            spi_sclk <= 0;
        end else if (spi_active) begin
            if (sclk_cnt >= SCLK_DIV-1) begin
                sclk_cnt <= 0;
                spi_sclk <= ~spi_sclk;
            end else begin
                sclk_cnt <= sclk_cnt + 1;
            end
        end else begin
            sclk_cnt <= 0;
            spi_sclk <= 0;
        end
    end

    // SPI 送受信ビットカウンタ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 0;
            rx_byte <= 0;
        end else if (spi_active && sclk_cnt == SCLK_DIV-1 && spi_sclk == 0) begin
            // 立ち上がりで MISO サンプリング
            rx_byte <= {rx_byte[6:0], spi_miso};
            if (bit_cnt == 7) begin
                bit_cnt <= 0;
            end else begin
                bit_cnt <= bit_cnt + 1;
            end
        end else if (!spi_active) begin
            bit_cnt <= 0;
        end
    end

    // MOSI 出力
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_mosi <= 0;
        end else if (spi_active && sclk_cnt == SCLK_DIV-1 && spi_sclk == 1) begin
            spi_mosi <= tx_byte[7 - bit_cnt];
        end
    end

    // 状態遷移
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // 次状態ロジック
    always_comb begin
        next_state = state;
        case (state)
            ST_IDLE:       if (start) next_state = ST_READ_ACCEL_XH;
            ST_READ_ACCEL_XH: if (!spi_active) next_state = ST_READ_ACCEL_XL;
            ST_READ_ACCEL_XL: if (!spi_active) next_state = ST_READ_ACCEL_YH;
            ST_READ_ACCEL_YH: if (!spi_active) next_state = ST_READ_ACCEL_YL;
            ST_READ_ACCEL_YL: if (!spi_active) next_state = ST_READ_ACCEL_ZH;
            ST_READ_ACCEL_ZH: if (!spi_active) next_state = ST_READ_ACCEL_ZL;
            ST_READ_ACCEL_ZL: if (!spi_active) next_state = ST_READ_GYRO_XH;
            ST_READ_GYRO_XH:  if (!spi_active) next_state = ST_READ_GYRO_XL;
            ST_READ_GYRO_XL:  if (!spi_active) next_state = ST_READ_GYRO_YH;
            ST_READ_GYRO_YH:  if (!spi_active) next_state = ST_READ_GYRO_YL;
            ST_READ_GYRO_YL:  if (!spi_active) next_state = ST_READ_GYRO_ZH;
            ST_READ_GYRO_ZH:  if (!spi_active) next_state = ST_READ_GYRO_ZL;
            ST_READ_GYRO_ZL:  if (!spi_active) next_state = ST_DONE;
            ST_DONE:       next_state = ST_IDLE;
        endcase
    end

    // 出力ロジック
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_cs_n     <= 1;
            spi_active   <= 0;
            busy         <= 0;
            data_valid   <= 0;
            tx_byte      <= 0;
            accel_x_raw  <= 0; accel_y_raw <= 0; accel_z_raw <= 0;
            gyro_x_raw   <= 0;  gyro_y_raw  <= 0; gyro_z_raw  <= 0;
            accel_x      <= 0;  accel_y     <= 0; accel_z     <= 0;
            gyro_x       <= 0;  gyro_y      <= 0; gyro_z      <= 0;
        end else begin
            data_valid <= 0;
            case (next_state)
                ST_IDLE: begin
                    spi_cs_n   <= 1;
                    spi_active <= 0;
                    busy       <= 0;
                end
                ST_READ_ACCEL_XH: begin
                    busy       <= 1;
                    spi_cs_n   <= 0;
                    spi_active <= 1;
                    tx_byte    <= {IMU_REG_ACCEL_XOUT_H, 1'b1}; // 読み出し
                end
                ST_READ_ACCEL_XL: begin
                    if (!spi_active && state == ST_READ_ACCEL_XH) accel_x_raw[15:8] <= rx_byte;
                    tx_byte <= {IMU_REG_ACCEL_XOUT_H + 1, 1'b1};
                end
                ST_READ_ACCEL_YH: begin
                    if (!spi_active && state == ST_READ_ACCEL_XL) accel_x_raw[7:0] <= rx_byte;
                    tx_byte <= {IMU_REG_ACCEL_XOUT_H + 2, 1'b1};
                end
                ST_READ_ACCEL_YL: begin
                    if (!spi_active && state == ST_READ_ACCEL_YH) accel_y_raw[15:8] <= rx_byte;
                    tx_byte <= {IMU_REG_ACCEL_XOUT_H + 3, 1'b1};
                end
                ST_READ_ACCEL_ZH: begin
                    if (!spi_active && state == ST_READ_ACCEL_YL) accel_y_raw[7:0] <= rx_byte;
                    tx_byte <= {IMU_REG_ACCEL_XOUT_H + 4, 1'b1};
                end
                ST_READ_ACCEL_ZL: begin
                    if (!spi_active && state == ST_READ_ACCEL_ZH) accel_z_raw[15:8] <= rx_byte;
                    tx_byte <= {IMU_REG_GYRO_XOUT_H, 1'b1};
                end
                ST_READ_GYRO_XH: begin
                    if (!spi_active && state == ST_READ_ACCEL_ZL) accel_z_raw[7:0] <= rx_byte;
                    tx_byte <= {IMU_REG_GYRO_XOUT_H, 1'b1};
                end
                ST_READ_GYRO_XL: begin
                    if (!spi_active && state == ST_READ_GYRO_XH) gyro_x_raw[15:8] <= rx_byte;
                    tx_byte <= {IMU_REG_GYRO_XOUT_H + 1, 1'b1};
                end
                ST_READ_GYRO_YH: begin
                    if (!spi_active && state == ST_READ_GYRO_XL) gyro_x_raw[7:0] <= rx_byte;
                    tx_byte <= {IMU_REG_GYRO_XOUT_H + 2, 1'b1};
                end
                ST_READ_GYRO_YL: begin
                    if (!spi_active && state == ST_READ_GYRO_YH) gyro_y_raw[15:8] <= rx_byte;
                    tx_byte <= {IMU_REG_GYRO_XOUT_H + 3, 1'b1};
                end
                ST_READ_GYRO_ZH: begin
                    if (!spi_active && state == ST_READ_GYRO_YL) gyro_y_raw[7:0] <= rx_byte;
                    tx_byte <= {IMU_REG_GYRO_XOUT_H + 4, 1'b1};
                end
                ST_READ_GYRO_ZL: begin
                    if (!spi_active && state == ST_READ_GYRO_ZH) gyro_z_raw[15:8] <= rx_byte;
                    tx_byte <= {IMU_REG_GYRO_XOUT_H + 5, 1'b1};
                end
                ST_DONE: begin
                    if (!spi_active && state == ST_READ_GYRO_ZL) gyro_z_raw[7:0] <= rx_byte;
                    spi_cs_n   <= 1;
                    spi_active <= 0;
                    busy       <= 0;
                    data_valid <= 1;
                    accel_x    <= accel_x_raw;
                    accel_y    <= accel_y_raw;
                    accel_z    <= accel_z_raw;
                    gyro_x     <= gyro_x_raw;
                    gyro_y     <= gyro_y_raw;
                    gyro_z     <= gyro_z_raw;
                end
            endcase
        end
    end

endmodule