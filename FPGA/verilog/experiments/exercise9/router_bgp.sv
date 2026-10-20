module bgp_message_parser (
    input  logic        clk,
    input  logic        rst_n,
    
    // AXI Stream Input (from MAC / TCP Offload Engine)
    input  logic [31:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    input  logic        s_axis_tlast,
    output logic        s_axis_tready,
    
    // Parsed Output Interface
    output logic [ 7:0] bgp_msg_type,     // 1: OPEN, 2: UPDATE, 3: NOTIFICATION, 4: KEEPALIVE
    output logic [15:0] bgp_msg_length,   // Message Length
    output logic        bgp_msg_valid     // Pulse when header is fully parsed
);

    // FSM States
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        MARKER = 2'b01,
        HEADER = 2'b10,
        PAYLOAD= 2'b11
    } state_t;

    state_t state, next_state;

    // Internal registers for parsing 16-byte marker + 2-byte length + 1-byte type
    logic [31:0] marker_count;
    logic [15:0] length_reg;
    logic [ 7:0] type_reg;

    assign s_axis_tready = (state != PAYLOAD) || s_axis_tlast;

    // Sequential Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= IDLE;
            marker_count   <= 0;
            length_reg     <= 0;
            type_reg       <= 0;
            bgp_msg_valid  <= 1'b0;
        end else begin
            bgp_msg_valid <= 1'b0;
            
            case (state)
                IDLE: begin
                    if (s_axis_tvalid) begin
                        // BGP marker starts with 16 bytes of all 1's
                        // Simplified check: assume first 4 bytes arrive here
                        marker_count <= 32'd4;
                        state        <= MARKER;
                    end
                end

                MARKER: begin
                    if (s_axis_tvalid) begin
                        marker_count <= marker_count + 4;
                        if (marker_count >= 16) begin
                            state <= HEADER;
                        end
                    end
                end

                HEADER: begin
                    if (s_axis_tvalid) begin
                        // Extract Length (16-bit) and Type (8-bit) from the word
                        length_reg    <= s_axis_tdata[31:16];
                        type_reg      <= s_axis_tdata[15:8];
                        bgp_msg_length <= s_axis_tdata[31:16];
                        bgp_msg_type   <= s_axis_tdata[15:8];
                        bgp_msg_valid  <= 1'b1;
                        state          <= PAYLOAD;
                    end
                end

                PAYLOAD: begin
                    if (s_axis_tvalid && s_axis_tlast) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule