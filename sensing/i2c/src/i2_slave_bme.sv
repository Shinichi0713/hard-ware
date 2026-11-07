`timescale 1us / 1ns

//------------------------------------------------------------
// I2C Slave: BME280 Emulator
//  - Responds to address 0x76
//  - Temperature register 0xFA-0xFC returns 24-bit value
//------------------------------------------------------------
module i2c_slave_bme280 #(
    parameter [6:0] SLAVE_ADDR = 7'h76
)(
    inout wire sda,
    inout wire scl
);

    // Tri-state control
    logic sda_oe;
    logic sda_out;
    assign sda = sda_oe ? sda_out : 1'bz;

    // Internal state
    typedef enum logic [3:0] {
        IDLE,
        GET_ADDR,
        ACK_ADDR,
        GET_REG,
        ACK_REG,
        GET_DATA,
        ACK_DATA,
        SEND_DATA,
        WAIT_ACK
    } state_t;

    state_t state;
    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;
    logic [6:0] rcvd_addr;
    logic [7:0] reg_ptr;
    logic       rw_bit;
    logic [7:0] memory [0:255];  // Register space

    // Temperature value: 0x018B00 (24.85 degC equivalent raw)
    // Stored in registers 0xFA, 0xFB, 0xFC
    initial begin
        foreach (memory[i]) memory[i] = 8'h00;
        memory[8'hFA] = 8'h01;  // MSB
        memory[8'hFB] = 8'h8B;  // LSB
        memory[8'hFC] = 8'h00;  // XLSB
        memory[8'hF4] = 8'h27;  // ctrl_meas register
        memory[8'hD0] = 8'h60;  // chip_id
    end

    // SCL edge detection
    logic scl_dly;
    always @(scl) scl_dly <= scl;

    wire scl_rising  = (scl_dly == 0 && scl == 1);
    wire scl_falling = (scl_dly == 1 && scl == 0);

    // START/STOP detection
    logic sda_dly;
    always @(sda) sda_dly <= sda;

    wire start_cond  = (scl == 1 && sda_dly == 1 && sda == 0);  // SDA falls while SCL high
    wire stop_cond   = (scl == 1 && sda_dly == 0 && sda == 1);  // SDA rises while SCL high

    always @(negedge scl or posedge start_cond) begin
        if (start_cond) begin
            state <= GET_ADDR;
            bit_cnt <= 3'd6;
            sda_oe <= 1'b0;
        end else begin
            case (state)
                GET_ADDR: begin
                    rcvd_addr[bit_cnt] <= sda;
                    if (bit_cnt == 0) begin
                        rw_bit <= sda;
                        state <= ACK_ADDR;
                    end else begin
                        bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                ACK_ADDR: begin
                    if (rcvd_addr == SLAVE_ADDR) begin
                        sda_oe  <= 1'b1;
                        sda_out <= 1'b0;  // ACK
                        if (rw_bit == 1'b0) begin
                            state <= GET_REG;
                            bit_cnt <= 3'd7;
                        end else begin
                            state <= SEND_DATA;
                            bit_cnt <= 3'd7;
                            shift_reg <= memory[reg_ptr];
                        end
                    end else begin
                        state <= IDLE;
                    end
                end

                GET_REG: begin
                    reg_ptr[bit_cnt] <= sda;
                    if (bit_cnt == 0) begin
                        state <= ACK_REG;
                    end else begin
                        bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                ACK_REG: begin
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b0;  // ACK
                    state <= GET_DATA;  // Wait for repeated START
                    bit_cnt <= 3'd7;
                end

                SEND_DATA: begin
                    sda_oe  <= 1'b1;
                    sda_out <= shift_reg[bit_cnt];
                    if (bit_cnt == 0) begin
                        state <= WAIT_ACK;
                    end else begin
                        bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                WAIT_ACK: begin
                    sda_oe <= 1'b0;  // Release SDA for master ACK/NACK
                    if (sda == 1'b1) begin  // NACK
                        state <= IDLE;
                    end else begin  // ACK, send next byte
                        reg_ptr <= reg_ptr + 1'b1;
                        shift_reg <= memory[reg_ptr + 1'b1];
                        state <= SEND_DATA;
                        bit_cnt <= 3'd7;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    // On STOP, return to IDLE
    always @(posedge stop_cond) begin
        state <= IDLE;
        sda_oe <= 1'b0;
    end

endmodule