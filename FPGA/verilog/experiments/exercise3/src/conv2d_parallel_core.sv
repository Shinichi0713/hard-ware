`timescale 1ns/1ps

module conv2d_parallel_core #(
    parameter int DATA_W      = 8,
    parameter int ACC_W       = 32,
    parameter int OUT_W       = 8,
    parameter int KERNEL_SIZE = 3,
    parameter int NUM_FILTERS = 4,
    parameter int SHIFT_BITS  = 8
) (
    input  logic                                                clk,
    input  logic                                                rst_n,
    input  logic                                                valid_in,
    input  logic                                                acc_clear,
    input  logic signed [KERNEL_SIZE*KERNEL_SIZE*DATA_W-1:0]    win_flat,     // K*K ウィンドウ入力
    input  logic signed [NUM_FILTERS*KERNEL_SIZE*KERNEL_SIZE*DATA_W-1:0] weights_flat, // 全フィルタ重み
    input  logic signed [NUM_FILTERS*ACC_W-1:0]                 bias_flat,    // バイアス
    output logic                                                valid_out,
    output logic signed [NUM_FILTERS*OUT_W-1:0]                 y_out_flat
);

    localparam int TAPS = KERNEL_SIZE * KERNEL_SIZE;

    // ウィンドウを配列へ展開
    logic signed [DATA_W-1:0] win_arr [0:TAPS-1];
    always_comb begin
        for (int t = 0; t < TAPS; t++) begin
            win_arr[t] = win_flat[t*DATA_W +: DATA_W];
        end
    end

    // パイプライン有効信号の遅延同期（乗算1段 + 加算ツリー2段 = 3段）
    logic [2:0] v_pipe;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            v_pipe <= '0;
        end else begin
            v_pipe <= {v_pipe[1:0], valid_in};
        end
    end
    assign valid_out = v_pipe[2];

    // 各出力フィルタごとの並列乗算・パイプライン加算・量子化＋ReLU
    genvar f;
    generate
        for (f = 0; f < NUM_FILTERS; f++) begin : gen_filters
            logic signed [2*DATA_W-1:0] prod [0:TAPS-1];
            logic signed [ACC_W-1:0]    sum_s1 [0:4];
            logic signed [ACC_W-1:0]    sum_s2 [0:1];
            logic signed [ACC_W-1:0]    sum_s3;
            logic signed [ACC_W-1:0]    acc_reg;
            logic signed [ACC_W-1:0]    bias_val;

            assign bias_val = bias_flat[f*ACC_W +: ACC_W];

            // Stage 1: 全タップ並列乗算
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    for (int t = 0; t < TAPS; t++) prod[t] <= '0;
                end else if (valid_in) begin
                    for (int t = 0; t < TAPS; t++) begin
                        logic signed [DATA_W-1:0] w_val;
                        w_val = weights_flat[(f*TAPS + t)*DATA_W +: DATA_W];
                        prod[t] <= win_arr[t] * w_val;
                    end
                end
            end

            // Stage 2: 2個ずつ部分和（9タップ -> 5要素に集約）
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    for (int i = 0; i < 5; i++) sum_s1[i] <= '0;
                end else if (v_pipe[0]) begin
                    sum_s1[0] <= {{(ACC_W-2*DATA_W){prod[0][2*DATA_W-1]}}, prod[0]} +
                                 {{(ACC_W-2*DATA_W){prod[1][2*DATA_W-1]}}, prod[1]};
                    sum_s1[1] <= {{(ACC_W-2*DATA_W){prod[2][2*DATA_W-1]}}, prod[2]} +
                                 {{(ACC_W-2*DATA_W){prod[3][2*DATA_W-1]}}, prod[3]};
                    sum_s1[2] <= {{(ACC_W-2*DATA_W){prod[4][2*DATA_W-1]}}, prod[4]} +
                                 {{(ACC_W-2*DATA_W){prod[5][2*DATA_W-1]}}, prod[5]};
                    sum_s1[3] <= {{(ACC_W-2*DATA_W){prod[6][2*DATA_W-1]}}, prod[6]} +
                                 {{(ACC_W-2*DATA_W){prod[7][2*DATA_W-1]}}, prod[7]};
                    sum_s1[4] <= {{(ACC_W-2*DATA_W){prod[8][2*DATA_W-1]}}, prod[8]};
                end
            end

            // Stage 3: ツリー加算 + バイアス + ReLU + 飽和クリップ
            logic signed [ACC_W-1:0] total_sum;
            logic signed [ACC_W-1:0] relu_val;
            logic signed [ACC_W-1:0] scaled_val;
            logic signed [OUT_W-1:0]  clamped_val;

            always_comb begin
                total_sum = sum_s1[0] + sum_s1[1] + sum_s1[2] + sum_s1[3] + sum_s1[4] + bias_val;
                // ReLU（負値を 0 にクリップ）
                relu_val = (total_sum > 0) ? total_sum : '0;
                // 固定小数点スケーリング
                scaled_val = relu_val >>> SHIFT_BITS;
                // 出力ビット幅への飽和処理（符号あり/なしに合わせて調整）
                if (scaled_val > ((1 << (OUT_W - 1)) - 1)) begin
                    clamped_val = (1 << (OUT_W - 1)) - 1;
                end else begin
                    clamped_val = scaled_val[OUT_W-1:0];
                end
            end

            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    acc_reg <= '0;
                    y_out_flat[f*OUT_W +: OUT_W] <= '0;
                end else if (v_pipe[1]) begin
                    acc_reg <= total_sum;
                    y_out_flat[f*OUT_W +: OUT_W] <= clamped_val;
                end
            end
        end
    endgenerate

endmodule


`timescale 1ns/1ps

module line_buffer_3x3 #(
    parameter int DATA_W = 8,
    parameter int IMG_W  = 32,
    parameter int IMG_H  = 32
) (
    input  logic                                clk,
    input  logic                                rst_n,
    input  logic                                pixel_valid,
    input  logic signed [DATA_W-1:0]            pixel_in,
    output logic                                win_valid,
    output logic signed [9*DATA_W-1:0]          win_3x3_flat
);

    // 2行分のラインバッファ（現在行と合わせて3行保持）
    logic signed [DATA_W-1:0] line0 [0:IMG_W-1];
    logic signed [DATA_W-1:0] line1 [0:IMG_W-1];

    // 3x3 シフトレジスタウィンドウ
    logic signed [DATA_W-1:0] w00, w01, w02;
    logic signed [DATA_W-1:0] w10, w11, w12;
    logic signed [DATA_W-1:0] w20, w21, w22;

    int col_cnt, row_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_cnt   <= 0;
            row_cnt   <= 0;
            win_valid <= 1'b0;
            w00 <= '0; w01 <= '0; w02 <= '0;
            w10 <= '0; w11 <= '0; w12 <= '0;
            w20 <= '0; w21 <= '0; w22 <= '0;
        end else begin
            win_valid <= 1'b0;

            if (pixel_valid) begin
                logic signed [DATA_W-1:0] from_l1, from_l0;
                from_l1 = line1[col_cnt];
                from_l0 = line0[col_cnt];

                // ラインバッファ更新
                line1[col_cnt] <= line0[col_cnt];
                line0[col_cnt] <= pixel_in;

                // 3x3 ウィンドウシフト
                w00 <= w01; w01 <= w02; w02 <= from_l1;
                w10 <= w11; w11 <= w12; w12 <= from_l0;
                w20 <= w21; w21 <= w22; w22 <= pixel_in;

                // 行・列が 2 以上に達した位置から有効な 3x3 ウィンドウを生成
                if (row_cnt >= 2 && col_cnt >= 2) begin
                    win_valid <= 1'b1;
                end

                if (col_cnt == IMG_W - 1) begin
                    col_cnt <= 0;
                    if (row_cnt == IMG_H - 1) begin
                        row_cnt <= 0;
                    end else begin
                        row_cnt <= row_cnt + 1;
                    end
                end else begin
                    col_cnt <= col_cnt + 1;
                end
            end
        end
    end

    // [w00, w01, w02, w10, w11, w12, w20, w21, w22] の順にパック
    assign win_3x3_flat = {w22, w21, w20, w12, w11, w10, w02, w01, w00};

endmodule