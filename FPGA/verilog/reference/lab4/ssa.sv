// ============================================================================
// 1. アナログセンサー・シミュレータ (A0ピンの模擬入力)
// ============================================================================
module analog_sensor_sim (
    input  logic        clk,
    input  logic        rst_n,
    output logic [11:0] analog_voltage_out // 12bit 模擬アナログ値 (0 ~ 4095)
);
    // 緩やかに変動する三角波状のセンサー出力を生成
    logic [23:0] counter;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;
            analog_voltage_out <= 12'd2048; // 初期値（中点）
        end else begin
            counter <= counter + 1'b1;
            // 周期的なセンサー値の変化をシミュレート
            analog_voltage_out <= 12'd1000 + {4'b0, counter[23:16]}; 
        end
    end
endmodule

// ============================================================================
// 2. 10ビット SAR (逐次比較型) ADC コア
// ============================================================================
module sar_adc_10bit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [11:0] analog_in,      // 入力電圧
    output logic [9:0]  adc_value,      // 変換結果 (0 ~ 1023)
    output logic        conv_done       // 変換完了パルス
);
    typedef enum logic [1:0] { IDLE, CONVERTING, DONE } state_t;
    state_t state;

    logic [3:0]  bit_index;
    logic [9:0]  approximation;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            adc_value     <= '0;
            conv_done     <= 1'b0;
            bit_index     <= 4'd9;
            approximation <= '0;
        end else begin
            case (state)
                IDLE: begin
                    conv_done <= 1'b0;
                    if (start) begin
                        approximation <= 10'h200; // MSB (512) から開始
                        bit_index     <= 4'd9;
                        state         <= CONVERTING;
                    end
                end

                CONVERTING: begin
                    // 模擬コンパレータ比較 (入力電圧 vs 近似値の比較)
                    // 注: 12bit入力を10bitスケール (>> 2) に合わせる
                    if ({2'b0, approximation} <= (analog_in >> 2)) begin
                        approximation[bit_index] <= 1'b1;
                    end else begin
                        approximation[bit_index] <= 1'b0;
                    end

                    if (bit_index == 0) begin
                        state <= DONE;
                    end else begin
                        bit_index <= bit_index - 1'b1;
                        // 次のビットの仮置き
                        approximation[bit_index - 1] <= 1'b1; 
                    end
                end

                DONE: begin
                    adc_value <= approximation;
                    conv_done <= 1'b1;
                    state     <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

// ============================================================================
// 3. UART 送信機 (9600 ボーレート / シリアル出力)
// ============================================================================
module uart_tx #(
    parameter int CLK_FREQ  = 50_000_000, // システムクロック 50MHz
    parameter int BAUD_RATE = 9600        // ボーレート
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_serial,
    output logic       tx_busy
);
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] { IDLE, START_BIT, DATA_BITS, STOP_BIT } state_t;
    state_t state;

    logic [15:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  shadow_data;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            tx_serial   <= 1'b1; // UARTアイドル時はHigh
            tx_busy     <= 1'b0;
            clk_count   <= '0;
            bit_index   <= '0;
            shadow_data <= '0;
        end else begin
            case (state)
                IDLE: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    if (tx_start) begin
                    	shadow_data <= tx_data;
                        tx_busy     <= 1'b1;
                        clk_count   <= '0;
                        state       <= START_BIT;
                    end
                end

                START_BIT: begin
                    tx_serial <= 1'b0; // スタートビット (Low)
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= '0;
                        bit_index <= '0;
                        state     <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    tx_serial <= shadow_data[bit_index]; // データビット送信 (LSB first)
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= '0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx_serial <= 1'b1; // ストップビット (High)
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= '0;
                        tx_busy   <= 1'b0;
                        state     <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

// ============================================================================
// 4. トップモジュール (センサー・ADC・シリアル通信の統合)
// ============================================================================
module sensor_system_top (
    input  logic clk,       // 50MHz システムクロック
    input  logic rst_n,     // リセット
    output logic tx_serial  // PCへ向かうシリアル出力ピン (TX)
);
    // 内部信号
    logic [11:0] analog_val;
    logic [9:0]  adc_val;
    logic        adc_start;
    logic        adc_done;
    
    // サンプリング間隔タイマー (約0.5秒ごとにADC起動)
    logic [24:0] sample_timer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_timer <= '0;
            adc_start    <= 1'b0;
        end else begin
            if (sample_timer >= 25_000_000) begin // 50MHz * 0.5s = 25,000,000サイクル
                sample_timer <= '0;
                adc_start    <= 1'b1; // 変換トリガー
            end else begin
                sample_timer <= sample_timer + 1'b1;
                adc_start    <= 1'b0;
            end
        end
    end

    // サブモジュールのインスタンス化
    analog_sensor_sim u_sensor (
        .clk(clk),
        .rst_n(rst_n),
        .analog_voltage_out(analog_val)
    );

    sar_adc_10bit u_adc (
        .clk(clk),
        .rst_n(rst_n),
        .start(adc_start),
        .analog_in(analog_val),
        .adc_value(adc_val),
        .conv_done(adc_done)
    );

    // 文字列送信コントローラ（ADC値の変化を検知してUARTで送信）
    // 簡易的にADC完了時に固定フォーマットの文字データを送信するステートマシンを接続可能
    logic        uart_start;
    logic [7:0]  uart_data;
    logic        uart_busy;

    uart_tx #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(9600)
    ) u_uart (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(uart_start),
        .tx_data(uart_data),
        .tx_serial(tx_serial),
        .tx_busy(uart_busy)
    );

    // 簡易制御ロジック
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_start <= 1'b0;
            uart_data  <= 8'h00;
        end else begin
            // ADC変換完了時に改行コードやステータスを送信するなどの制御をここに記述
            if (adc_done && !uart_busy) begin
                uart_start <= 1'b1;
                uart_data  <= 8'h41; // 例: ASCII 'A' を送信
            end else begin
                uart_start <= 1'b0;
            end
        end
    end

endmodule