// fir_filter.sv
// 1次FIRローパスフィルタ (Q1.15 固定小数点処理)
module fir_filter #(
    parameter int DATA_WIDTH = 16,  // 入出力データ幅 (16-bit 有効符号付き)
    parameter int COEFF_WIDTH = 16  // 係数データ幅 (16-bit Q1.15)
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic signed [DATA_WIDTH-1:0]  d_in,   // 入力信号 x[n]
    input  logic                          valid_in,
    output logic signed [DATA_WIDTH-1:0]  d_out,  // 出力信号 y[n]
    output logic                          valid_out
);

    // フィルター係数例 (b0 = 0.5, b1 = 0.5 -> Q1.15表現: 0.5 * 32768 = 16384)
    localparam logic signed [COEFF_WIDTH-1:0] B0 = 16'sd16384;
    localparam logic signed [COEFF_WIDTH-1:0] B1 = 16'sd16384;

    // 内部レジスタ
    logic signed [DATA_WIDTH-1:0] x_d1; // x[n-1] 遅延用パイプライン

    // 積算用 (16bit * 16bit = 32bit)
    logic signed [DATA_WIDTH+COEFF_WIDTH-1:0] mult0, mult1;
    
    // 加算用 (32bit + 32bit = 33bit)
    logic signed [DATA_WIDTH+COEFF_WIDTH:0] sum;

    // 1. パイプライン段：入力データの保持（x[n-1]の生成）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_d1      <= '0;
            valid_out <= '0;
        end else if (valid_in) begin
            x_d1      <= d_in;
            valid_out <= '1;
        end else begin
            valid_out <= '0;
        end
    end

    // 2. 演算処理（組合せ回路 / パイプライン化も可能）
    always_comb begin
        mult0 = d_in * B0;  // b0 * x[n]
        mult1 = x_d1 * B1;  // b1 * x[n-1]
        sum   = mult0 + mult1;
    end

    // 3. 出力フォーマットの調整（Q1.15の積を元のスケールへ戻すシフト処理）
    // 33-bit の結果から小数部15bitをシフトし、上部16bitを切り出し
    assign d_out = sum[DATA_WIDTH+COEFF_WIDTH-1 : COEFF_WIDTH-1];

endmodule


// fir_filter.sv
// 1次FIRローパスフィルタ (Q1.15 固定小数点処理)
module fir_filter #(
    parameter int DATA_WIDTH = 16,  // 入出力データ幅 (16-bit 有効符号付き)
    parameter int COEFF_WIDTH = 16  // 係数データ幅 (16-bit Q1.15)
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic signed [DATA_WIDTH-1:0]  d_in,   // 入力信号 x[n]
    input  logic                          valid_in,
    output logic signed [DATA_WIDTH-1:0]  d_out,  // 出力信号 y[n]
    output logic                          valid_out
);

    // フィルター係数例 (b0 = 0.5, b1 = 0.5 -> Q1.15表現: 0.5 * 32768 = 16384)
    localparam logic signed [COEFF_WIDTH-1:0] B0 = 16'sd16384;
    localparam logic signed [COEFF_WIDTH-1:0] B1 = 16'sd16384;

    // 内部レジスタ
    logic signed [DATA_WIDTH-1:0] x_d1; // x[n-1] 遅延用パイプライン

    // 積算用 (16bit * 16bit = 32bit)
    logic signed [DATA_WIDTH+COEFF_WIDTH-1:0] mult0, mult1;
    
    // 加算用 (32bit + 32bit = 33bit)
    logic signed [DATA_WIDTH+COEFF_WIDTH:0] sum;

    // 1. パイプライン段：入力データの保持（x[n-1]の生成）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_d1      <= '0;
            valid_out <= '0;
        end else if (valid_in) begin
            x_d1      <= d_in;
            valid_out <= '1;
        end else begin
            valid_out <= '0;
        end
    end

    // 2. 演算処理（組合せ回路 / パイプライン化も可能）
    always_comb begin
        mult0 = d_in * B0;  // b0 * x[n]
        mult1 = x_d1 * B1;  // b1 * x[n-1]
        sum   = mult0 + mult1;
    end

    // 3. 出力フォーマットの調整（Q1.15の積を元のスケールへ戻すシフト処理）
    // 33-bit の結果から小数部15bitをシフトし、上部16bitを切り出し
    assign d_out = sum[DATA_WIDTH+COEFF_WIDTH-1 : COEFF_WIDTH-1];

endmodule

// tb_fir_filter.sv
`timescale 1ns/1ps

module tb_fir_filter;

    localparam int DATA_WIDTH = 16;
    localparam time CLK_PERIOD = 10ns;

    logic clk;
    logic rst_n;
    logic signed [DATA_WIDTH-1:0] d_in;
    logic valid_in;
    logic signed [DATA_WIDTH-1:0] d_out;
    logic valid_out;

    // DUT (Device Under Test) インスタンス化
    fir_filter #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .d_in(d_in),
        .valid_in(valid_in),
        .d_out(d_out),
        .valid_out(valid_out)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // テストシナリオ
    initial begin
        // リセット処理
        rst_n    = 0;
        d_in     = 0;
        valid_in = 0;
        #(CLK_PERIOD * 2);
        rst_n    = 1;
        #(CLK_PERIOD);

        // 入力印加: ステップ入力 (値: 10000)
        $display("--- Test Start ---");
        
        send_data(16'sd10000);
        send_data(16'sd10000);
        send_data(16'sd10000);
        send_data(16'sd0);
        send_data(16'sd0);

        #(CLK_PERIOD * 5);
        $display("--- Test End ---");
        $finish;
    end

    // データ送信タスク
    task automatic send_data(input logic signed [DATA_WIDTH-1:0] data);
        @(posedge clk);
        d_in     <= data;
        valid_in <= 1'b1;
        @(posedge clk);
        valid_in <= 1'b0;
        $display("[Time %0t] IN: %d | OUT: %d", $time, data, d_out);
    endtask

endmodule