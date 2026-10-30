//////////////////////////////////////////////////////////////////////////////
// I2C Noise-Filtered Control Value Acquisition System
// - Synchronizes and debounces SDA/SCL lines
// - Reads N-bytes from I2C slave
// - Applies moving average filter to output control value
//////////////////////////////////////////////////////////////////////////////

module i2c_noise_filter #(
    parameter CLK_FREQ_MHZ = 50,          // System clock frequency in MHz
    parameter GLITCH_NS  = 50           // Glitch width to filter in ns
)(
    input  logic clk,
    input  logic rst_n,
    input  logic sda_in,
    input  logic scl_in,
    output logic sda_clean,
    output logic scl_clean
);

    // Calculate debounce count: (CLK_FREQ_MHZ * GLITCH_NS) / 1000 ticks
    localparam int DEBOUNCE_CNT = (CLK_FREQ_MHZ * GLITCH_NS) / 1000;
    localparam int CNT_WIDTH    = $clog2(DEBOUNCE_CNT + 1);

    // Synchronizer flip-flops (metastability mitigation)
    logic [1:0] sda_sync, scl_sync;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_sync <= 2'b11; // I2C idle is high
            scl_sync <= 2'b11;
        end else begin
            sda_sync <= {sda_sync[0], sda_in};
            scl_sync <= {scl_sync[0], scl_in};
        end
    end

    // Debounce logic for SDA
    logic [CNT_WIDTH-1:0] sda_cnt;
    logic sda_stable;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_cnt   <= '0;
            sda_stable <= 1'b1;
        end else begin
            if (sda_sync[1] != sda_stable) begin
                if (sda_cnt < DEBOUNCE_CNT)
                    sda_cnt <= sda_cnt + 1'b1;
                else
                    sda_stable <= sda_sync[1];
            end else begin
                sda_cnt <= '0;
            end
        end
    end

    // Debounce logic for SCL
    logic [CNT_WIDTH-1:0] scl_cnt;
    logic scl_stable;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl_cnt   <= '0;
            scl_stable <= 1'b1;
        end else begin
            if (scl_sync[1] != scl_stable) begin
                if (scl_cnt < DEBOUNCE_CNT)
                    scl_cnt <= scl_cnt + 1'b1;
                else
                    scl_stable <= scl_sync[1];
            end else begin
                scl_cnt <= '0;
            end
        end
    end

    assign sda_clean = sda_stable;
    assign scl_clean = scl_stable;

endmodule


//////////////////////////////////////////////////////////////////////////////
// Simple I2C Master
// - Supports: Start, Stop, Tx 1 byte + Ack, Rx N bytes + Ack/Nack
// - Open-drain output style (sda_oe, scl_oe)
//////////////////////////////////////////////////////////////////////////////

module i2c_master #(
    parameter CLK_FREQ_MHZ = 50,
    parameter I2C_KHZ      = 400  // 400kHz Fast-mode
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,           // Trigger transaction
    input  logic [6:0] slave_addr,
    input  logic [7:0] reg_addr,  // Register address to write before read
    input  logic read_mode,       // 1 = read, 0 = write
    input  logic [2:0] rx_len,    // Number of bytes to receive (1-4)
    output logic [7:0] rx_data [0:3], // Received byte array
    output logic busy,
    output logic done,
    output logic error,           // NACK detected
    input  logic sda_clean,
    input  logic scl_clean,
    output logic sda_oe,
    output logic scl_oe,
    output logic sda_out,
    output logic scl_out
);

    // I2C timing: half-bit period in clock cycles
    localparam int HALF_BIT = (CLK_FREQ_MHZ * 1000) / (I2C_KHZ * 2);
    localparam int TIMER_W  = $clog2(HALF_BIT + 1);

    // State definitions
    typedef enum logic [4:0] {
        ST_IDLE,
        ST_START_A, ST_START_B, ST_START_C,
        ST_TX_BYTE,
        ST_WAIT_ACK,
        ST_RX_BYTE,
        ST_SEND_ACK,
        ST_STOP_A, ST_STOP_B, ST_STOP_C, ST_STOP_D,
        ST_DONE,
        ST_ERROR
    } state_t;

    state_t state, next_state;

    logic [TIMER_W-1:0] timer;
    logic [3:0] bit_cnt;      // 0-7 for byte, 8 for ACK
    logic [7:0] tx_shift;     // Byte to transmit
    logic [2:0] rx_idx;       // Current receive byte index
    logic [7:0] rx_shift;     // Receive shift register
    logic nack;

    // Timer control
    logic timer_rst;
    logic timer_expired;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            timer <= '0;
        else if (timer_rst)
            timer <= '0;
        else if (!timer_expired)
            timer <= timer + 1'b1;
    end

    assign timer_expired = (timer >= HALF_BIT - 1);

    // SCL/SDA output defaults (open-drain: oe=0 means high-Z/pull-up)
    // We drive low by enabling output and driving 0.
    assign scl_out = 1'b0;
    assign sda_out = 1'b0;

    // State machine sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= ST_IDLE;
            bit_cnt <= '0;
            rx_idx  <= '0;
            rx_shift <= '0;
            nack    <= 1'b0;
            for (int i = 0; i < 4; i++) rx_data[i] <= '0;
        end else begin
            if (timer_expired) begin
                state <= next_state;

                case (state)
                    ST_IDLE: begin
                        if (start) begin
                            bit_cnt <= 4'd8;
                            rx_idx  <= '0;
                            nack    <= 1'b0;
                            if (read_mode)
                                tx_shift <= {slave_addr, 1'b1}; // Read
                            else
                                tx_shift <= {slave_addr, 1'b0}; // Write
                        end
                    end

                    ST_START_C: begin
                        // After sending slave+RW, prepare reg_addr for write phase
                        if (!read_mode)
                            tx_shift <= reg_addr;
                    end

                    ST_TX_BYTE: begin
                        tx_shift <= tx_shift << 1;
                        if (bit_cnt == 4'd1)
                            bit_cnt <= 4'd9; // Move to ACK phase
                        else
                            bit_cnt <= bit_cnt - 1'b1;
                    end

                    ST_WAIT_ACK: begin
                        if (!read_mode && next_state == ST_TX_BYTE) begin
                            // Second TX: register address sent, now repeated start for read
                            tx_shift <= {slave_addr, 1'b1};
                            bit_cnt  <= 4'd8;
                        end else if (read_mode && next_state == ST_RX_BYTE) begin
                            bit_cnt <= 4'd8;
                        end
                    end

                    ST_RX_BYTE: begin
                        rx_shift <= {rx_shift[6:0], sda_clean};
                        if (bit_cnt == 4'd1) begin
                            bit_cnt <= 4'd9;
                        end else begin
                            bit_cnt <= bit_cnt - 1'b1;
                        end
                    end

                    ST_SEND_ACK: begin
                        rx_data[rx_idx] <= rx_shift;
                        if (rx_idx < rx_len - 1) begin
                            rx_idx <= rx_idx + 1'b1;
                            bit_cnt <= 4'd8;
                        end
                    end

                    default: ;
                endcase
            end
        end
    end

    // Output logic and next state decoding
    always_comb begin
        next_state  = state;
        timer_rst   = 1'b0;
        scl_oe      = 1'b0; // 0 = release (high via pull-up), 1 = drive low
        sda_oe      = 1'b0;
        busy        = 1'b1;
        done        = 1'b0;
        error       = 1'b0;

        case (state)
            ST_IDLE: begin
                busy = 1'b0;
                scl_oe = 1'b0;
                sda_oe = 1'b0;
                if (start) begin
                    next_state = ST_START_A;
                    timer_rst  = 1'b1;
                end
            end

            // Start condition: SDA high->low while SCL high
            ST_START_A: begin
                sda_oe = 1'b0; // SDA released (high)
                scl_oe = 1'b0; // SCL released (high)
                if (timer_expired) begin
                    next_state = ST_START_B;
                    timer_rst  = 1'b1;
                end
            end

            ST_START_B: begin
                sda_oe = 1'b1; // Drive SDA low
                scl_oe = 1'b0; // SCL still high
                if (timer_expired) begin
                    next_state = ST_START_C;
                    timer_rst  = 1'b1;
                end
            end

            ST_START_C: begin
                sda_oe = 1'b1; // Keep SDA low
                scl_oe = 1'b1; // Drive SCL low
                if (timer_expired) begin
                    next_state = ST_TX_BYTE;
                    timer_rst  = 1'b1;
                end
            end

            // Transmit byte (MSB first)
            ST_TX_BYTE: begin
                scl_oe = 1'b1; // SCL low during data setup
                // SDA = tx_shift[7], drive if low, release if high
                sda_oe = tx_shift[7] ? 1'b0 : 1'b1;
                if (timer_expired) begin
                    next_state = ST_WAIT_ACK;
                    timer_rst  = 1'b1;
                end
            end

            // Wait for ACK during SCL high
            ST_WAIT_ACK: begin
                scl_oe = 1'b0; // Release SCL (slave drives if clock stretching, but we assume none here)
                sda_oe = 1'b0; // Release SDA
                nack   = sda_clean; // ACK = 0, NACK = 1
                if (timer_expired) begin
                    if (nack && bit_cnt != 4'd9) begin // NACK detection after byte complete
                        next_state = ST_ERROR;
                        timer_rst  = 1'b1;
                    end else if (bit_cnt == 4'd9) begin // ACK phase done
                        if (!read_mode && tx_shift == {slave_addr, 1'b0}) begin
                            // Just sent slave addr + W, next send reg_addr
                            next_state = ST_TX_BYTE;
                            timer_rst  = 1'b1;
                        end else if (!read_mode && tx_shift == reg_addr) begin
                            // Register address sent, now repeated start for read
                            next_state = ST_START_A;
                            timer_rst  = 1'b1;
                        end else if (read_mode) begin
                            next_state = ST_RX_BYTE;
                            timer_rst  = 1'b1;
                        end else begin
                            next_state = ST_STOP_A;
                            timer_rst  = 1'b1;
                        end
                    end else begin
                        // Continue shifting
                        next_state = ST_TX_BYTE;
                        timer_rst  = 1'b1;
                    end
                end
            end

            // Receive byte
            ST_RX_BYTE: begin
                scl_oe = 1'b0; // Release SCL
                sda_oe = 1'b0; // Release SDA (input)
                if (timer_expired) begin
                    if (bit_cnt == 4'd9) begin
                        next_state = ST_SEND_ACK;
                        timer_rst  = 1'b1;
                    end else begin
                        next_state = ST_RX_BYTE;
                        timer_rst  = 1'b1; // Continue receiving
                    end
                end
            end

            // Send ACK (0) or NACK (1) to slave
            ST_SEND_ACK: begin
                scl_oe = 1'b1; // Drive SCL low
                // Send ACK (drive low) if more bytes to read, else NACK
                sda_oe = (rx_idx < rx_len - 1) ? 1'b1 : 1'b0;
                if (timer_expired) begin
                    if (rx_idx < rx_len - 1) begin
                        next_state = ST_RX_BYTE;
                        timer_rst  = 1'b1;
                    end else begin
                        next_state = ST_STOP_A;
                        timer_rst  = 1'b1;
                    end
                end
            end

            // Stop condition: SCL high, SDA low->high
            ST_STOP_A: begin
                scl_oe = 1'b1; // SCL low
                sda_oe = 1'b1; // SDA low
                if (timer_expired) begin
                    next_state = ST_STOP_B;
                    timer_rst  = 1'b1;
                end
            end

            ST_STOP_B: begin
                scl_oe = 1'b0; // Release SCL (high)
                sda_oe = 1'b1; // Keep SDA low
                if (timer_expired) begin
                    next_state = ST_STOP_C;
                    timer_rst  = 1'b1;
                end
            end

            ST_STOP_C: begin
                scl_oe = 1'b0; // SCL high
                sda_oe = 1'b0; // Release SDA (high)
                if (timer_expired) begin
                    next_state = ST_DONE;
                    timer_rst  = 1'b1;
                end
            end

            ST_DONE: begin
                busy = 1'b0;
                done = 1'b1;
                next_state = ST_IDLE;
            end

            ST_ERROR: begin
                busy  = 1'b0;
                error = 1'b1;
                next_state = ST_IDLE;
            end

            default: next_state = ST_IDLE;
        endcase
    end

endmodule


//////////////////////////////////////////////////////////////////////////////
// Moving Average Filter (16 samples)
// For smoothing acquired control values
//////////////////////////////////////////////////////////////////////////////

module moving_avg_filter #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    input  logic signed [DATA_WIDTH-1:0] data_in,
    output logic signed [DATA_WIDTH-1:0] data_out,
    output logic valid_out
);

    logic signed [DATA_WIDTH-1:0] buffer [0:DEPTH-1];
    logic [$clog2(DEPTH)-1:0] ptr;
    logic signed [DATA_WIDTH+$clog2(DEPTH)-1:0] sum;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++) buffer[i] <= '0;
            ptr       <= '0;
            sum       <= '0;
            data_out  <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0;
            if (valid_in) begin
                // Subtract oldest, add newest
                sum <= sum - buffer[ptr] + data_in;
                buffer[ptr] <= data_in;
                ptr <= ptr + 1'b1;

                // After filling buffer, output valid every sample
                // For simplicity, we output every cycle with running average
                data_out  <= (sum - buffer[ptr] + data_in) >>> $clog2(DEPTH);
                valid_out <= 1'b1;
            end
        end
    end

endmodule


//////////////////////////////////////////////////////////////////////////////
// Top Module: I2C Control Acquisition System
// Example: Reads 2 bytes from slave, combines to 16-bit signed, filters.
//////////////////////////////////////////////////////////////////////////////

module i2c_control_acquisition #(
    parameter CLK_FREQ_MHZ = 50,
    parameter I2C_KHZ      = 400,
    parameter SLAVE_ADDR   = 7'h36,   // Example sensor address
    parameter REG_ADDR     = 8'h00    // Example register address
)(
    input  logic clk,
    input  logic rst_n,
    // Physical I2C lines (external open-drain, pulled up)
    input  logic sda_in,
    input  logic scl_in,
    output logic sda_oe,
    output logic scl_oe,
    // Control output
    output logic signed [15:0] control_value,
    output logic control_valid,
    output logic busy,
    output logic error
);

    // Clean signals
    logic sda_clean, scl_clean;

    // I2C master signals
    logic [7:0] rx_data [0:3];
    logic i2c_start;
    logic i2c_done;
    logic i2c_busy;
    logic i2c_error;

    // Combine two bytes to signed 16-bit (big-endian assumption)
    logic signed [15:0] raw_value;
    logic raw_valid;

    // Auto-trigger I2C read periodically (every ~1ms at 50MHz example)
    localparam int TRIGGER_CNT = CLK_FREQ_MHZ * 1000;
    logic [$clog2(TRIGGER_CNT)-1:0] trig_timer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trig_timer <= '0;
            i2c_start  <= 1'b0;
        end else begin
            i2c_start <= 1'b0;
            if (!i2c_busy && trig_timer >= TRIGGER_CNT-1) begin
                trig_timer <= '0;
                i2c_start  <= 1'b1;
            end else if (!i2c_busy) begin
                trig_timer <= trig_timer + 1'b1;
            end
        end
    end

    // Assemble received bytes when I2C done
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            raw_value <= '0;
            raw_valid <= 1'b0;
        end else begin
            raw_valid <= 1'b0;
            if (i2c_done && !i2c_error) begin
                // Assuming MSB first from sensor
                raw_value <= $signed({rx_data[0], rx_data[1]});
                raw_valid <= 1'b1;
            end
        end
    end

    // Noise filter instance
    i2c_noise_filter #(
        .CLK_FREQ_MHZ(CLK_FREQ_MHZ),
        .GLITCH_NS   (50)
    ) u_filter (
        .clk        (clk),
        .rst_n      (rst_n),
        .sda_in     (sda_in),
        .scl_in     (scl_in),
        .sda_clean  (sda_clean),
        .scl_clean  (scl_clean)
    );

    // I2C master instance
    i2c_master #(
        .CLK_FREQ_MHZ(CLK_FREQ_MHZ),
        .I2C_KHZ     (I2C_KHZ)
    ) u_i2c_master (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (i2c_start),
        .slave_addr (SLAVE_ADDR),
        .reg_addr   (REG_ADDR),
        .read_mode  (1'b1),         // Always read in this example
        .rx_len     (3'd2),          // Read 2 bytes
        .rx_data    (rx_data),
        .busy       (i2c_busy),
        .done       (i2c_done),
        .error      (i2c_error),
        .sda_clean  (sda_clean),
        .scl_clean  (scl_clean),
        .sda_oe     (sda_oe),
        .scl_oe     (scl_oe),
        .sda_out    (),             // Internal drive low only
        .scl_out    ()
    );

    // Moving average filter instance
    moving_avg_filter #(
        .DATA_WIDTH(16),
        .DEPTH     (16)
    ) u_avg_filter (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (raw_valid),
        .data_in   (raw_value),
        .data_out  (control_value),
        .valid_out (control_valid)
    );

    assign busy  = i2c_busy;
    assign error = i2c_error;

endmodule