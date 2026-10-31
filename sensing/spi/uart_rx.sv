module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  logic clk,
    input  logic rst_n,
    input  logic rxd,
    output logic [7:0] rx_data,
    output logic rx_valid,
    output logic rx_error
);
    localparam int BIT_CYCLES = CLK_FREQ / BAUD_RATE;

    typedef enum logic [2:0] {IDLE, START, DATA, STOP, DONE} state_t;
    state_t state;
    logic [$clog2(BIT_CYCLES)-1:0] bit_timer;
    logic [2:0] bit_cnt;
    logic [7:0] shift_reg;
    logic [1:0] rxd_sync;

    // メタステビリティ対策（2段FF）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) rxd_sync <= 2'b11;
        else        rxd_sync <= {rxd_sync[0], rxd};
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            bit_timer <= '0;
            bit_cnt   <= '0;
            rx_valid  <= 1'b0;
            rx_error  <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            rx_error <= 1'b0;

            case (state)
                IDLE: begin
                    bit_timer <= '0;
                    if (rxd_sync[1] == 1'b0) state <= START;
                end

                START: begin
                    if (bit_timer == BIT_CYCLES/2 - 1) begin
                        bit_timer <= '0;
                        if (rxd_sync[1] == 1'b0) state <= DATA;
                        else                     state <= IDLE;
                    end else begin
                        bit_timer <= bit_timer + 1'b1;
                    end
                end

                DATA: begin
                    if (bit_timer == BIT_CYCLES - 1) begin
                        bit_timer <= '0;
                        shift_reg <= {rxd_sync[1], shift_reg[7:1]};
                        if (bit_cnt == 3'd7) begin
                            bit_cnt <= '0;
                            state   <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end else begin
                        bit_timer <= bit_timer + 1'b1;
                    end
                end

                STOP: begin
                    if (bit_timer == BIT_CYCLES - 1) begin
                        bit_timer <= '0;
                        rx_data   <= shift_reg;
                        if (rxd_sync[1] == 1'b1) begin
                            rx_valid <= 1'b1;
                            state    <= DONE;
                        end else begin
                            rx_error <= 1'b1;
                            state    <= IDLE;
                        end
                    end else begin
                        bit_timer <= bit_timer + 1'b1;
                    end
                end

                DONE: state <= IDLE;

                default: state <= IDLE;
            endcase
        end
    end
endmodule


module char_buffer #(
    parameter BUF_LEN = 32
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [7:0] rx_data,
    input  logic rx_valid,
    output logic [7:0] char_buf [0:BUF_LEN-1],
    output logic [$clog2(BUF_LEN+1)-1:0] text_len,
    output logic update_flag
);
    logic [$clog2(BUF_LEN)-1:0] wr_ptr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr    <= '0;
            text_len  <= '0;
            update_flag <= 1'b0;
            for (int i = 0; i < BUF_LEN; i++) char_buf[i] <= 8'h20;
        end else begin
            update_flag <= 1'b0;

            if (rx_valid) begin
                if (rx_data == 8'h0D || rx_data == 8'h0A) begin
                    text_len  <= wr_ptr;
                    wr_ptr    <= '0;
                    update_flag <= 1'b1;
                end else if (wr_ptr < BUF_LEN) begin
                    char_buf[wr_ptr] <= rx_data;
                    wr_ptr <= wr_ptr + 1'b1;
                end
            end
        end
    end
endmodule