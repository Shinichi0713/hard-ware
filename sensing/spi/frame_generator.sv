module scroll_controller #(
    parameter CLK_FREQ  = 50_000_000,
    parameter SCROLL_MS = 100,
    parameter BUF_LEN   = 32,
    parameter MAX_OFFSET = BUF_LEN * 6
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [$clog2(BUF_LEN+1)-1:0] text_len,
    input  logic update_flag,
    output logic [$clog2(MAX_OFFSET)-1:0] scroll_offset,
    output logic offset_changed
);
    localparam int SCROLL_CYCLES = CLK_FREQ / 1000 * SCROLL_MS;

    logic [$clog2(SCROLL_CYCLES)-1:0] timer;
    logic [$clog2(MAX_OFFSET)-1:0] max_offset;

    assign max_offset = text_len * 6;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer         <= '0;
            scroll_offset <= '0;
            offset_changed <= 1'b0;
        end else begin
            offset_changed <= 1'b0;

            if (update_flag) begin
                scroll_offset <= '0;
                timer         <= '0;
                offset_changed <= 1'b1;
            end else if (max_offset > 0 && timer >= SCROLL_CYCLES - 1) begin
                timer <= '0;
                if (scroll_offset >= max_offset - 1)
                    scroll_offset <= '0;
                else
                    scroll_offset <= scroll_offset + 1'b1;
                offset_changed <= 1'b1;
            end else begin
                timer <= timer + 1'b1;
            end
        end
    end
endmodule

module frame_generator #(
    parameter BUF_LEN = 32
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [7:0] char_buf [0:BUF_LEN-1],
    input  logic [$clog2(BUF_LEN+1)-1:0] text_len,
    input  logic [$clog2(BUF_LEN*6)-1:0] scroll_offset,
    output logic [7:0] frame [0:7]
);
    logic [6:0] col_ascii   [0:7];
    logic [2:0] col_font_col [0:7];
    logic [7:0] col_pattern [0:7];

    // 8列分のフォントROMを並列にインスタンス化
    genvar g;
    generate
        for (g = 0; g < 8; g++) begin : gen_font
            font_rom u_font (
                .ascii  (col_ascii[g]),
                .col    (col_font_col[g]),
                .pattern(col_pattern[g])
            );
        end
    endgenerate

    // 各列がどの文字・どの列を指すかを計算（組み合わせ）
    always_comb begin
        for (int c = 0; c < 8; c++) begin
            int global_col = int'(scroll_offset) + c;
            int char_idx   = global_col / 6;
            int font_col   = global_col % 6;

            if (char_idx < text_len && font_col < 5) begin
                col_ascii[c]   = char_buf[char_idx][6:0];
                col_font_col[c]= font_col[2:0];
            end else begin
                col_ascii[c]   = 7'h20; // space
                col_font_col[c]= 3'd0;
            end
        end
    end

    // 8×8 フレームを組み立て（row方向にビットを並べる）
    always_comb begin
        for (int row = 0; row < 8; row++) begin
            logic [7:0] row_data;
            for (int c = 0; c < 8; c++) begin
                row_data[7-c] = col_pattern[c][row];
            end
            frame[row] = row_data;
        end
    end
endmodule