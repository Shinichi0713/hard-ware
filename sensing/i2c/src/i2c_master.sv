`timescale 1us / 1ns

//------------------------------------------------------------
// I2C Master Module
//  - Open-drain SDA/SCL with tri-state emulation
//  - Supports: Write, Read, Repeated START
//------------------------------------------------------------
module i2c_master #(
    parameter CLK_FREQ = 1_000_000,  // Module clock [Hz]
    parameter I2C_FREQ = 100_000    // I2C SCL [Hz] (Standard mode)
)(
    input  logic clk,
    input  logic rst_n,

    // I2C bus (open-drain, tri-state)
    inout  wire  sda,
    inout  wire  scl,

    // Control interface
    input  logic        start_tx,      // Pulse to start transaction
    input  logic [6:0]  slave_addr,    // 7-bit slave address
    input  logic        rw,            // 0=Write, 1=Read
    input  logic [7:0]  reg_addr,      // Register address to write first
    input  logic [4:0]  read_len,      // Number of bytes to read
    output logic [7:0]  read_data [0:7], // Read data buffer (max 8 bytes)
    output logic [4:0]  read_count,    // Actual bytes read
    output logic        busy,          // High during transaction
    output logic        done,          // Pulse when transaction complete
    output logic        nack_detected   // High if NACK received
);

    // Timing calculations
    localparam int HALF_PERIOD = CLK_FREQ / I2C_FREQ / 2;
    localparam int QUARTER     = HALF_PERIOD / 2;

    // Tri-state control for SDA and SCL
    logic sda_oe, sda_out;
    logic scl_oe, scl_out;

    assign sda = sda_oe ? sda_out : 1'bz;
    assign scl = scl_oe ? scl_out : 1'bz;

    // FSM states
    typedef enum logic [4:0] {
        IDLE,
        START_SDA_LOW,
        START_SCL_LOW,
        WRITE_ADDR,
        CHECK_ADDR_ACK,
        WRITE_REG,
        CHECK_REG_ACK,
        REP_START_SDA_HIGH,
        REP_START_SDA_LOW,
        WRITE_ADDR_R,
        CHECK_ADDR_R_ACK,
        READ_BYTE,
        SEND_ACK,
        SEND_NACK,
        STOP_SCL_HIGH,
        STOP_SDA_HIGH,
        WAIT_HALF
    } state_t;

    state_t state, next_state;

    logic [4:0]  bit_cnt;
    logic [7:0]  shift_reg;
    logic [4:0]  byte_cnt;
    logic [31:0] wait_cnt;
    logic [7:0]  read_buf [0:7];

    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            busy <= 1'b0;
            done <= 1'b0;
            nack_detected <= 1'b0;
            sda_oe <= 1'b0;
            sda_out <= 1'b1;
            scl_oe <= 1'b0;
            scl_out <= 1'b1;
            bit_cnt <= 0;
            shift_reg <= 0;
            byte_cnt <= 0;
            wait_cnt <= 0;
            read_count <= 0;
            for (int i = 0; i < 8; i++) read_data[i] <= 0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    if (start_tx) begin
                        busy <= 1'b1;
                        done <= 1'b0;
                        nack_detected <= 1'b0;
                        byte_cnt <= 0;
                        read_count <= 0;
                        // Load slave address + R/W
                        shift_reg <= {slave_addr, rw};
                        state <= START_SDA_LOW;
                    end
                end

                //--- START condition: SDA goes LOW while SCL is HIGH ---
                START_SDA_LOW: begin
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b0;      // SDA LOW
                    wait_cnt <= HALF_PERIOD;
                    state <= WAIT_HALF;
                    next_state <= START_SCL_LOW;
                end

                START_SCL_LOW: begin
                    scl_oe  <= 1'b1;
                    scl_out <= 1'b0;      // SCL LOW
                    bit_cnt <= 7;         // Start from MSB
                    wait_cnt <= HALF_PERIOD;
                    state <= WAIT_HALF;
                    next_state <= WRITE_ADDR;
                end

                //--- Write byte (address or data) ---
                WRITE_ADDR, WRITE_REG: begin
                    scl_out <= 1'b0;
                    sda_oe  <= 1'b1;
                    sda_out <= shift_reg[bit_cnt];
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= (state == WRITE_ADDR) ? CHECK_ADDR_ACK : CHECK_REG_ACK;
                    // After sending bit, raise SCL
                end

                // SCL HIGH for data sampling
                CHECK_ADDR_ACK, CHECK_REG_ACK: begin
                    scl_out <= 1'b1;
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    if (bit_cnt == 0) begin
                        // Last bit sent, next is ACK phase
                        next_state <= (state == CHECK_ADDR_ACK) ?
                                      ((rw == 1'b0) ? CHECK_ACK_REG : REP_START_SDA_HIGH) :
                                      CHECK_ACK_REG;
                    end else begin
                        next_state <= (state == CHECK_ADDR_ACK) ? WRITE_ADDR : WRITE_REG;
                    end
                    bit_cnt <= bit_cnt - 1'b1;
                end

                // ACK phase (9th clock)
                CHECK_ACK_REG: begin
                    scl_out <= 1'b0;
                    sda_oe  <= 1'b0;      // Release SDA for slave ACK
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= SAMPLE_ACK_REG;
                end

                SAMPLE_ACK_REG: begin
                    scl_out <= 1'b1;
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= AFTER_ACK_REG;
                end

                AFTER_ACK_REG: begin
                    scl_out <= 1'b0;
                    wait_cnt <= QUARTER;
                    if (sda == 1'b1) begin  // NACK detected
                        nack_detected <= 1'b1;
                        state <= STOP_SCL_HIGH;
                    end else begin
                        // ACK received
                        if (rw == 1'b0) begin
                            // Write mode: send register address next
                            shift_reg <= reg_addr;
                            bit_cnt <= 7;
                            state <= WRITE_REG;
                        end else begin
                            // Read mode: start reading
                            state <= READ_BYTE;
                            bit_cnt <= 7;
                        end
                    end
                end

                //--- Repeated START for read ---
                REP_START_SDA_HIGH: begin
                    sda_oe  <= 1'b0;      // Release SDA
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= REP_START_SDA_LOW;
                end

                REP_START_SDA_LOW: begin
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b0;      // SDA LOW while SCL HIGH
                    shift_reg <= {slave_addr, 1'b1}; // Read mode
                    bit_cnt <= 7;
                    wait_cnt <= HALF_PERIOD;
                    state <= WAIT_HALF;
                    next_state <= WRITE_ADDR_R;
                end

                WRITE_ADDR_R: begin
                    scl_out <= 1'b0;
                    sda_oe  <= 1'b1;
                    sda_out <= shift_reg[bit_cnt];
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= CHECK_ADDR_R_ACK;
                end

                CHECK_ADDR_R_ACK: begin
                    scl_out <= 1'b1;
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    if (bit_cnt == 0) begin
                        next_state <= SAMPLE_ADDR_R_ACK;
                    end else begin
                        next_state <= WRITE_ADDR_R;
                    end
                    bit_cnt <= bit_cnt - 1'b1;
                end

                SAMPLE_ADDR_R_ACK: begin
                    scl_out <= 1'b0;
                    sda_oe  <= 1'b0;      // Release SDA for ACK
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= AFTER_ADDR_R_ACK;
                end

                AFTER_ADDR_R_ACK: begin
                    scl_out <= 1'b1;
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    if (sda == 1'b1) begin
                        nack_detected <= 1'b1;
                        next_state <= STOP_SCL_HIGH;
                    end else begin
                        next_state <= READ_BYTE;
                        bit_cnt <= 7;
                    end
                end

                //--- Read byte from slave ---
                READ_BYTE: begin
                    scl_out <= 1'b0;
                    sda_oe  <= 1'b0;      // Input mode
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= SAMPLE_BIT;
                end

                SAMPLE_BIT: begin
                    scl_out <= 1'b1;
                    shift_reg[bit_cnt] <= sda;
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    if (bit_cnt == 0) begin
                        next_state <= (byte_cnt + 1 == read_len) ? SEND_NACK : SEND_ACK;
                    end else begin
                        next_state <= READ_BYTE;
                    end
                    bit_cnt <= bit_cnt - 1'b1;
                end

                //--- Send ACK to slave (more bytes to read) ---
                SEND_ACK: begin
                    scl_out <= 1'b0;
                    read_buf[byte_cnt] <= shift_reg;
                    byte_cnt <= byte_cnt + 1'b1;
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b0;      // ACK = LOW
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= READ_BYTE;
                    bit_cnt <= 7;
                end

                //--- Send NACK to slave (last byte) ---
                SEND_NACK: begin
                    scl_out <= 1'b0;
                    read_buf[byte_cnt] <= shift_reg;
                    byte_cnt <= byte_cnt + 1'b1;
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b1;      // NACK = HIGH
                    wait_cnt <= QUARTER;
                    state <= WAIT_HALF;
                    next_state <= STOP_SCL_HIGH;
                end

                //--- STOP condition ---
                STOP_SCL_HIGH: begin
                    scl_out <= 1'b1;      // SCL HIGH
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b0;      // SDA still LOW
                    wait_cnt <= HALF_PERIOD;
                    state <= WAIT_HALF;
                    next_state <= STOP_SDA_HIGH;
                end

                STOP_SDA_HIGH: begin
                    sda_out <= 1'b1;      // SDA goes HIGH while SCL HIGH
                    wait_cnt <= HALF_PERIOD;
                    state <= WAIT_HALF;
                    next_state <= IDLE_DONE;
                end

                IDLE_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    read_count <= byte_cnt;
                    for (int i = 0; i < 8; i++) read_data[i] <= read_buf[i];
                    state <= IDLE;
                end

                //--- Wait state ---
                WAIT_HALF: begin
                    if (wait_cnt > 0) begin
                        wait_cnt <= wait_cnt - 1'b1;
                    end else begin
                        state <= next_state;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    // Helper state for ACK branching (not in main enum to simplify)
    state_t ack_next_state;
    always_comb begin
        ack_next_state = IDLE;
    end

endmodule