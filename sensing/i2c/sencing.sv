`timescale 1ns / 1ps
//============================================================================
// I2C Sensor Reader & Controller
// Target: Generic I2C temperature sensor (LM75-compatible)
// Function: Reads temperature via I2C, outputs alert if threshold exceeded
//============================================================================

module i2c_sensor_controller #(
    parameter CLK_FREQ_HZ = 50_000_000,  // System clock: 50MHz
    parameter I2C_FREQ_HZ = 100_000,     // I2C clock: 100kHz (standard mode)
    parameter SENSOR_ADDR = 7'h48,       // I2C device address (LM75 default)
    parameter TEMP_REG_ADDR = 8'h00,     // Temperature register address
    parameter THRESHOLD = 8'd27          // Alert threshold: 27 degrees C (integer part)
)(
    input  wire clk,
    input  wire rst_n,                   // Active-low reset

    // I2C interface
    output reg  i2c_scl,
    inout  wire i2c_sda,

    // Control outputs
    output reg  alert,                   // High when temp > threshold
    output reg  valid,                   // High when reading is valid
    output reg  [15:0] raw_temp          // Raw temperature data (8-bit int + 8-bit frac)
);

    //------------------------------------------------------------------------
    // Timing parameters
    //------------------------------------------------------------------------
    localparam integer CLK_DIV = CLK_FREQ_HZ / (I2C_FREQ_HZ * 4); // Quarter-period ticks
    localparam [15:0] DELAY_COUNT = CLK_DIV[15:0];

    //------------------------------------------------------------------------
    // I2C bit states
    //------------------------------------------------------------------------
    localparam [3:0]
        IDLE        = 4'd0,
        START       = 4'd1,
        SEND_ADDR_W = 4'd2,  // Send device address + Write (0)
        ACK_ADDR_W  = 4'd3,
        SEND_REG    = 4'd4,  // Send register address to read
        ACK_REG     = 4'd5,
        REPEATED_START = 4'd6,
        SEND_ADDR_R = 4'd7,  // Send device address + Read (1)
        ACK_ADDR_R  = 4'd8,
        READ_HIGH   = 4'd9,  // Read MSB (integer part)
        ACK_HIGH    = 4'd10,
        READ_LOW    = 4'd11, // Read LSB (fractional part)
        NACK_LOW    = 4'd12,
        STOP        = 4'd13,
        WAIT        = 4'd14;  // Delay between readings

    //------------------------------------------------------------------------
    // Registers
    //------------------------------------------------------------------------
    reg [3:0]  state;
    reg [3:0]  bit_cnt;
    reg [15:0] wait_cnt;
    reg [7:0]  tx_byte;
    reg [7:0]  rx_high;      // Received MSB
    reg [7:0]  rx_low;       // Received LSB
    reg        sda_out;
    reg        sda_oe;       // SDA output enable

    //------------------------------------------------------------------------
    // Bidirectional SDA control
    //------------------------------------------------------------------------
    assign i2c_sda = sda_oe ? sda_out : 1'bz;
    wire sda_in = i2c_sda;

    //------------------------------------------------------------------------
    // Alert logic
    //------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alert <= 1'b0;
        end else if (state == STOP) begin
            // Compare integer part (MSB) with threshold
            alert <= (rx_high[7] == 1'b0) && (rx_high[6:0] > THRESHOLD[6:0]);
        end
    end

    //------------------------------------------------------------------------
    // Main state machine
    //------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            i2c_scl   <= 1'b1;
            sda_out   <= 1'b1;
            sda_oe    <= 1'b1;
            bit_cnt   <= 4'd0;
            wait_cnt  <= 16'd0;
            tx_byte   <= 8'd0;
            rx_high   <= 8'd0;
            rx_low    <= 8'd0;
            raw_temp  <= 16'd0;
            valid     <= 1'b0;
        end else begin
            case (state)
                //--------------------------------------------------------
                IDLE: begin
                    i2c_scl <= 1'b1;
                    sda_out <= 1'b1;
                    sda_oe  <= 1'b1;
                    valid   <= 1'b0;
                    wait_cnt <= 16'd0;
                    state   <= START;
                end

                //--------------------------------------------------------
                // Start condition: SDA goes low while SCL is high
                //--------------------------------------------------------
                START: begin
                    sda_out <= 1'b0;           // SDA low
                    tx_byte <= {SENSOR_ADDR, 1'b0}; // Address + Write
                    bit_cnt <= 4'd7;
                    state   <= SEND_ADDR_W;
                end

                //--------------------------------------------------------
                // Send device address (7 bits) + R/W (1 bit)
                //--------------------------------------------------------
                SEND_ADDR_W: begin
                    i2c_scl <= 1'b0;
                    sda_out <= tx_byte[bit_cnt];
                    // SCL pulse
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT && i2c_scl == 1'b1) begin
                            // Wait for high period
                            if (wait_cnt < DELAY_COUNT*2) begin
                                wait_cnt <= wait_cnt + 1'b1;
                            end else begin
                                wait_cnt <= 16'd0;
                                if (bit_cnt == 4'd0) begin
                                    state <= ACK_ADDR_W;
                                    sda_oe <= 1'b0; // Release SDA for ACK
                                end else begin
                                    bit_cnt <= bit_cnt - 1'b1;
                                end
                            end
                        end
                    end
                end

                //--------------------------------------------------------
                // Wait for ACK from slave
                //--------------------------------------------------------
                ACK_ADDR_W: begin
                    i2c_scl <= 1'b0;
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        // Check ACK (SDA should be low)
                        if (wait_cnt >= DELAY_COUNT) begin
                            i2c_scl <= 1'b0;
                            tx_byte <= TEMP_REG_ADDR;
                            bit_cnt <= 4'd7;
                            sda_oe  <= 1'b1;
                            state   <= SEND_REG;
                        end
                    end
                end

                //--------------------------------------------------------
                // Send register address
                //--------------------------------------------------------
                SEND_REG: begin
                    i2c_scl <= 1'b0;
                    sda_out <= tx_byte[bit_cnt];
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            i2c_scl <= 1'b0;
                            if (bit_cnt == 4'd0) begin
                                state <= ACK_REG;
                                sda_oe <= 1'b0;
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end
                end

                //--------------------------------------------------------
                ACK_REG: begin
                    i2c_scl <= 1'b0;
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            i2c_scl <= 1'b0;
                            state   <= REPEATED_START;
                            sda_oe  <= 1'b1;
                            sda_out <= 1'b1; // SDA high before repeated start
                        end
                    end
                end

                //--------------------------------------------------------
                // Repeated Start for read operation
                //--------------------------------------------------------
                REPEATED_START: begin
                    sda_out <= 1'b0;           // SDA low (start condition)
                    tx_byte <= {SENSOR_ADDR, 1'b1}; // Address + Read
                    bit_cnt <= 4'd7;
                    state   <= SEND_ADDR_R;
                end

                //--------------------------------------------------------
                // Send device address + Read
                //--------------------------------------------------------
                SEND_ADDR_R: begin
                    i2c_scl <= 1'b0;
                    sda_out <= tx_byte[bit_cnt];
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            i2c_scl <= 1'b0;
                            if (bit_cnt == 4'd0) begin
                                state <= ACK_ADDR_R;
                                sda_oe <= 1'b0;
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end
                end

                //--------------------------------------------------------
                // ACK for read address
                //--------------------------------------------------------
                ACK_ADDR_R: begin
                    i2c_scl <= 1'b0;
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            i2c_scl <= 1'b0;
                            bit_cnt <= 4'd7;
                            state   <= READ_HIGH;
                            sda_oe  <= 1'b0; // Input mode
                        end
                    end
                end

                //--------------------------------------------------------
                // Read MSB (integer part of temperature)
                //--------------------------------------------------------
                READ_HIGH: begin
                    i2c_scl <= 1'b0;
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            rx_high[bit_cnt] <= sda_in;
                            i2c_scl <= 1'b0;
                            if (bit_cnt == 4'd0) begin
                                state <= ACK_HIGH;
                                sda_oe <= 1'b1;
                                sda_out <= 1'b0; // ACK to slave
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end
                end

                //--------------------------------------------------------
                // Send ACK, prepare to read LSB
                //--------------------------------------------------------
                ACK_HIGH: begin
                    i2c_scl <= 1'b0;
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            i2c_scl <= 1'b0;
                            bit_cnt <= 4'd7;
                            state   <= READ_LOW;
                            sda_oe  <= 1'b0; // Input mode
                        end
                    end
                end

                //--------------------------------------------------------
                // Read LSB (fractional part)
                //--------------------------------------------------------
                READ_LOW: begin
                    i2c_scl <= 1'b0;
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            rx_low[bit_cnt] <= sda_in;
                            i2c_scl <= 1'b0;
                            if (bit_cnt == 4'd0) begin
                                state <= NACK_LOW;
                                sda_oe <= 1'b1;
                                sda_out <= 1'b1; // NACK (last byte)
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end
                        end
                    end
                end

                //--------------------------------------------------------
                // Send NACK for last byte
                //--------------------------------------------------------
                NACK_LOW: begin
                    i2c_scl <= 1'b0;
                    if (wait_cnt < DELAY_COUNT) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        i2c_scl <= 1'b1;
                        if (wait_cnt >= DELAY_COUNT) begin
                            i2c_scl <= 1'b0;
                            raw_temp <= {rx_high, rx_low};
                            valid    <= 1'b1;
                            state    <= STOP;
                            sda_oe   <= 1'b1;
                            sda_out  <= 1'b0; // SDA low before stop
                        end
                    end
                end

                //--------------------------------------------------------
                // Stop condition: SDA goes high while SCL is high
                //--------------------------------------------------------
                STOP: begin
                    i2c_scl <= 1'b1;
                    sda_out <= 1'b1; // SDA high = stop condition
                    if (wait_cnt < DELAY_COUNT * 4) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        state    <= WAIT;
                    end
                end

                //--------------------------------------------------------
                // Wait before next reading (e.g., 1 second interval)
                //--------------------------------------------------------
                WAIT: begin
                    valid <= 1'b0;
                    if (wait_cnt < CLK_FREQ_HZ[23:0]) begin // ~1 second at 50MHz
                        wait_cnt <= wait_cnt + 1'b1;
                    end else begin
                        wait_cnt <= 16'd0;
                        state    <= IDLE;
                    end
                end

                //--------------------------------------------------------
                default: state <= IDLE;
                //--------------------------------------------------------
            endcase
        end
    end

endmodule
