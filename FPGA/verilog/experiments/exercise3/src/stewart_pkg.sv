`ifndef STEWART_PKG_SV
`define STEWART_PKG_SV

package stewart_pkg;

    // 固定小数点 Q16.16
    localparam int FW = 16;
    localparam int IW = 16;
    localparam int DW = IW + FW;

    typedef logic signed [DW-1:0] fixed_t;
    typedef logic signed [2*DW-1:0] fixed_dbl_t;

    // 幾何学パラメータ（Q16.16、単位 mm）
    localparam fixed_t BASE_RADIUS     = 32'd9_830_400;   // 150.0 mm
    localparam fixed_t PLATFORM_RADIUS = 32'd6_553_600;   // 100.0 mm
    localparam fixed_t NEUTRAL_HEIGHT  = 32'd13_107_200;  // 200.0 mm
    localparam fixed_t ANGLE_OFFSET   = 32'd655_360;      // 10 deg

    // PI * 2^16 = 205887
    localparam fixed_t PI_FIXED = 32'd205887;
    // deg -> rad: π/180 * 2^16 ≈ 1143
    localparam fixed_t DEG2RAD  = 32'd1143;

    // PWM パラメータ（50MHz クロック想定）
    localparam int PWM_PERIOD_US = 20000;
    localparam int PWM_MIN_US    = 1000;
    localparam int PWM_MAX_US    = 2000;
    localparam int PWM_CLK_NS    = 20;
    localparam int PWM_PERIOD_CNT= PWM_PERIOD_US * 1000 / PWM_CLK_NS;
    localparam int PWM_MIN_CNT   = PWM_MIN_US   * 1000 / PWM_CLK_NS;
    localparam int PWM_MAX_CNT   = PWM_MAX_US   * 1000 / PWM_CLK_NS;

    // IMU SPI レジスタ（MPU-6500/9250）
    localparam logic [7:0] IMU_REG_ACCEL_XOUT_H = 8'h3B;
    localparam logic [7:0] IMU_REG_GYRO_XOUT_H  = 8'h43;
    localparam logic [7:0] IMU_REG_PWR_MGMT_1   = 8'h6B;

    // 6軸サーボ
    localparam int NUM_LEGS = 6;

endpackage

`endif