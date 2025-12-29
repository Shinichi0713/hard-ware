module priority_selector #(
    parameter int NUM_INPUTS           = 4, // 入力の数
    parameter bit PRIORITY_HIGH_TO_LOW = 1  // 1:MSB優先, 0:LSB優先
)(
    input  logic [NUM_INPUTS-1:0]      request_vector,
    output logic [$clog2(NUM_INPUTS)-1:0] selected_index,
    output logic                       active
);

    // インデックスのビット幅を計算
    localparam int INDEX_WIDTH = $clog2(NUM_INPUTS);

    always_comb begin
        // デフォルト値（リクエストがない場合）
        selected_index = {INDEX_WIDTH{1'b0}};
        active         = |request_vector; // ORリダクション演算（いずれかが1なら1）

        if (active) begin
            if (PRIORITY_HIGH_TO_LOW) begin
                // --- MSB優先 (ビット番号が大きい方を優先) ---
                for (int i = NUM_INPUTS - 1; i >= 0; i--) begin
                    if (request_vector[i]) begin
                        selected_index = INDEX_WIDTH'(i);
                        break; // 最初に見つけた高いビットで確定
                    end
                end
            end else begin
                // --- LSB優先 (ビット番号が小さい方を優先) ---
                for (int i = 0; i < NUM_INPUTS; i++) begin
                    if (request_vector[i]) begin
                        selected_index = INDEX_WIDTH'(i);
                        break; // 最初に見つけた低いビットで確定
                    end
                end
            end
        end
    end

endmodule