module traffic_light (
    input  logic clk,    // 1Hz を想定
    input  logic rst_n,  // 負論理リセット
    output logic red,
    output logic green,
    output logic yellow
);

    // --- 1. 状態の定義 (enum) ---
    typedef enum logic [1:0] {
        S_RED    = 2'b00,
        S_GREEN  = 2'b01,
        S_YELLOW = 2'b10
    } state_t;

    state_t current_state, next_state;

    // --- 2. カウンタ変数の定義 ---
    // 最大3秒なので2ビットでも足りますが、拡張性を考慮し4ビット用意
    logic [3:0] timer;

    // --- 3. カウンタと状態レジスタ (always_ff) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_RED;
            timer         <= 4'd0;
        end else begin
            if (current_state != next_state) begin
                // 状態が遷移する時にカウンタをリセット
                timer <= 4'd0;
            end else begin
                timer <= timer + 4'd1;
            end
            current_state <= next_state;
        end
    end

    // --- 4. 次状態ロジック (always_comb) ---
    always_comb begin
        // デフォルト値
        next_state = current_state;

        unique case (current_state)
            S_RED: begin
                // 3秒経過したら(0,1,2と数えて3秒目に遷移)
                if (timer >= 4'd2) next_state = S_GREEN;
            end
            S_GREEN: begin
                if (timer >= 4'd2) next_state = S_YELLOW;
            end
            S_YELLOW: begin
                // 1秒経過したら(0秒経過後すぐに遷移)
                if (timer >= 4'd0) next_state = S_RED;
            end
            default: next_state = S_RED;
        endcase
    end

    // --- 5. 出力ロジック (always_comb) ---
    always_comb begin
        red    = (current_state == S_RED);
        green  = (current_state == S_GREEN);
        yellow = (current_state == S_YELLOW);
    end

endmodule