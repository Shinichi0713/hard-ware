module sar_adc_controller #(
    parameter int BITS = 12 // 分解能 (例: 12ビット)
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             start,         // 変換開始トリガー
    input  logic             comp_in,       // コンパレータ出力 (1: Vin > Vdac, 0: Vin < Vdac)
    output logic [BITS-1:0]  dac_out,       // DACへの出力値
    output logic [BITS-1:0]  data_out,      // 変換完了後のデジタル出力
    output logic             busy,          // 変換中フラグ
    output logic             done           // 変換完了パルス
);

    // ステート定義
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        CONV   = 2'b01,
        FINISH = 2'b10
    } state_t;

    state_t state, next_state;
    
    // 内部レジスタ
    logic [$clog2(BITS)-1:0] bit_idx;
    logic [BITS-1:0]         sar_reg;

    // FSM 順序回路
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            bit_idx  <= '0;
            sar_reg  <= '0;
            data_out <= '0;
            busy     <= 1'b0;
            done     <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        busy    <= 1'b1;
                        bit_idx <= BITS - 1;
                        sar_reg <= '0;
                        sar_reg[BITS - 1] <= 1'b1; // MSBを仮に1にセット
                    end
                end

                CONV: begin
                    // 1つ前のコンパレータ結果を反映
                    if (comp_in) begin
                        sar_reg[bit_idx] <= 1'b1; // Vin >= Vdac なら 1 を維持
                    end else begin
                        sar_reg[bit_idx] <= 1'b0; // Vin < Vdac なら 0 にクリア
                    end

                    if (bit_idx == 0) begin
                        busy <= 1'b0;
                        done <= 1'b1;
                    end else begin
                        bit_idx <= bit_idx - 1;
                        // 次のビットを仮に1にセット
                        sar_reg[bit_idx - 1] <= 1'b1;
                    end
                end

                FINISH: begin
                    done     <= 1'b0;
                    data_out <= sar_reg;
                end
            end case
        end
    end

    // 次状態遷移ロジック
    always_comb begin
        next_state = state;
        case (state)
            IDLE:   if (start) next_state = CONV;
            CONV:   if (bit_idx == 0) next_state = FINISH;
            FINISH: next_state = IDLE;
        end case
    end

    // DACへの出力値は常時SARレジスタと直結
    assign dac_out = sar_reg;

endmodule