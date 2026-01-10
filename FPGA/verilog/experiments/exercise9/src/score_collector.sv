module score_collector #(
    parameter int NUM_AGENTS = 4,
    parameter int WIDTH      = 16
)(
    score_if.collector bus[NUM_AGENTS], // インターフェースの配列
    input  logic       rst_n,
    output logic [31:0] total_score
);

    always_ff @(posedge bus[0].clk or negedge rst_n) begin
        if (!rst_n) begin
            total_score <= 32'd0;
            for (int i=0; i<NUM_AGENTS; i++) bus[i].full <= 1'b0;
        end else begin
            // 簡易的なラウンドロビンまたは優先度集計
            // 同時に複数が送ってきた場合、今回は全エージェントの総和をとる
            logic [31:0] frame_sum;
            frame_sum = 32'd0;
            
            for (int i=0; i<NUM_AGENTS; i++) begin
                if (bus[i].valid) begin
                    frame_sum += bus[i].add_points;
                end
            end
            total_score <= total_score + frame_sum;
        end
    end
endmodule