// --- エージェント単体の動き ---
module agent_logic (
    score_if.agent bus,
    input logic rst_n,
    input logic [3:0] id
);
    always_ff @(posedge bus.clk or negedge rst_n) begin
        if (!rst_n) begin
            bus.add_points <= 0;
            bus.valid      <= 0;
        end else begin
            // 自分のIDに応じたタイミングでランダムにポイントを発生させる模擬ロジック
            bus.valid <= (id == 4'd1); // ID 1のエージェントだけ常に送る例
            bus.add_points <= 16'd10;
        end
    end
endmodule

// --- 最上位階層 ---
module top_system #(
    parameter int AGENT_COUNT = 4
)(
    input  logic clk,
    input  logic rst_n,
    output logic [31:0] global_score
);

    // インターフェースの配列をインスタンス化
    score_if #(.WIDTH(16)) s_if[AGENT_COUNT](clk);

    // コレクターのインスタンス
    score_collector #(.NUM_AGENTS(AGENT_COUNT)) u_collector (
        .bus         (s_if),
        .rst_n       (rst_n),
        .total_score (global_score)
    );

    // generate文によるエージェントの自動生成
    genvar i;
    generate
        for (i = 0; i < AGENT_COUNT; i++) begin : gen_agents
            agent_logic u_agent (
                .bus   (s_if[i]),
                .rst_n (rst_n),
                .id    (i[3:0])
            );
        end
    endgenerate

endmodule