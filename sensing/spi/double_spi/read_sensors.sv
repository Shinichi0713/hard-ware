module multi_sensor_spi_master #(
    parameter int NUM_SENSORS = 2,       // 接続するセンサ（スレーブ）の数
    parameter int DATA_WIDTH  = 16,      // 1回の転送ビット数（コマンド＋データなど）
    parameter int CLK_DIV     = 4        // システムクロックに対するSCLKの分周比（偶数推奨）
)(
    input  logic                             clk,          // システムクロック
    input  logic                             rst_n,        // 非同期リセット（Lアクティブ）
    
    // 上位モジュールからの制御インターフェース
    input  logic                             start,        // 転送開始トリガー（1サイクルパルス）
    input  logic [$clog2(NUM_SENSORS)-1:0]   sensor_select,// アクセスするセンサのインデックス
    input  logic [DATA_WIDTH-1:0]            tx_data,      // 送信データ（コマンドやレジスタアドレス含む）
    output logic                             busy,         // 通信中フラグ
    output logic [DATA_WIDTH-1:0]            rx_data,      // センサから読み出したデータ
    output logic                             rx_valid,     // 読み出しデータ有効フラグ
    
    // SPI物理インターフェース
    output logic                             sclk,         // SPIクロック
    output logic                             mosi,         // Master Out Slave In
    input  logic                             miso,         // Master In Slave Out
    output logic [NUM_SENSORS-1:0]           cs_n          // チップセレクト（各センサ個別）
);

    // 内部状態定義 (FSM)
    typedef enum logic [1:0] {
        IDLE     = 2'b00,
        TRANSFER = 2'b01,
        DONE     = 2'b10
    } state_t;

    state_t current_state, next_state;

    // 内部信号
    logic [$clog2(CLK_DIV)-1:0] clk_cnt;
    logic                       sclk_en;
    logic                       sclk_edge_rising;
    logic                       sclk_edge_falling;
    
    logic [$clog2(DATA_WIDTH):0] bit_cnt;
    logic [DATA_WIDTH-1:0]       tx_shift_reg;
    logic [DATA_WIDTH-1:0]       rx_shift_reg;
    
    logic [$clog2(NUM_SENSORS)-1:0] active_sensor;

    // ==========================================
    // 1. クロック分周器とSCLK生成 (CPOL=0, CPHA=0 基調)
    // ==========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= '0;
            sclk_en <= 1'b0;
        end else if (current_state == TRANSFER) begin
            if (clk_cnt == (CLK_DIV / 2) - 1) begin
                clk_cnt <= '0;
                sclk_en <= ~sclk_en;
            end else begin
                clk_cnt <= clk_cnt + 1'b1;
            end
        end else begin
            clk_cnt <= '0;
            sclk_en <= 1'b0;
        end
    end

    // SCLKのエッジ検出
    assign sclk_edge_rising  = (current_state == TRANSFER) && (clk_cnt == '0) && (sclk_en == 1'b1);
    assign sclk_edge_falling = (current_state == TRANSFER) && (clk_cnt == '0) && (sclk_en == 1'b0);

    // 実際のSCLK出力（アイドル時はLow: CPOL=0）
    assign sclk = (current_state == TRANSFER) ? sclk_en : 1'b0;

    // ==========================================
    // 2. ステートマシン (FSM)
    // ==========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            active_sensor <= '0;
        end else begin
            current_state <= next_state;
            if (current_state == IDLE && start) begin
                active_sensor <= sensor_select;
            end
        end
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (start) begin
                    next_state = TRANSFER;
                end
            end
            TRANSFER: begin
                // 全ビット転送完了でDONEへ
                if ((bit_cnt == DATA_WIDTH) && sclk_edge_falling) begin
                    next_state = DONE;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        end case
    end

    // ==========================================
    // 3. データシフトレジスタと送受信制御
    // ==========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt      <= '0;
            tx_shift_reg <= '0;
            rx_shift_reg <= '0;
            rx_data      <= '0;
            rx_valid     <= 1'b0;
        end else begin
            rx_valid <= 1'b0; // 1サイクルパルス
            
            case (current_state)
                IDLE: begin
                    bit_cnt <= '0;
                    if (start) begin
                        tx_shift_reg <= tx_data; // 送信データをロード
                    end
                end

                TRANSFER: begin
                    // 立ち上がりエッジでMISOからサンプリング (CPHA=0)
                    if (sclk_edge_rising) begin
                        rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], miso};
                    end
                    
                    // 立ち下がりエッジでMOSIへシフト出力
                    if (sclk_edge_falling) begin
                        tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                        bit_cnt      <= bit_cnt + 1'b1;
                    end
                end

                DONE: begin
                    rx_data  <= rx_shift_reg; // 読み出し完了データを格納
                    rx_valid <= 1'b1;         // 有効信号をアサート
                end
            end case
        end
    end

    // MOSI出力（送信レジスタの最上位ビットを常に出力）
    assign mosi = tx_shift_reg[DATA_WIDTH-1];

    // ==========================================
    // 4. チップセレクト (CS_n) の制御
    // ==========================================
    // 指定されたセンサのCS_nのみをLアクティブ（0）にし、他はH（1）に維持する
    always_comb begin
        cs_n = '1; // すべて非選択（High）
        if (current_state == TRANSFER || current_state == DONE) begin
            cs_n[active_sensor] = 1'b0; // 選択されたセンサだけLにする
        end
    end

    // ビジー信号の出力
    assign busy = (current_state != IDLE);

endmodule