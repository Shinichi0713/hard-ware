module rgb_to_grayscale (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [23:0] rgb_in,     // 24bit RGB (R:7:0, G:15:8, B:23:16)
    input  logic        valid_in,   // 入力データ有効フラグ
    output logic [7:0]  gray_out,   // 8bit グレースケール出力
    output logic        valid_out   // 出力データ有効フラグ
);

    // -----------------------------------------------------
    // 信号の分割
    // -----------------------------------------------------
    localparam RED_WIDTH   = 8;
    localparam GREEN_WIDTH = 8;
    localparam BLUE_WIDTH  = 8;
    
    // RGB成分を抽出（SystemVerilogではビットスライスが容易）
    logic [RED_WIDTH-1:0]   r;
    logic [GREEN_WIDTH-1:0] g;
    logic [BLUE_WIDTH-1:0]  b;
    
    // 配線（組み合わせ回路）
    assign r = rgb_in[7:0];
    assign g = rgb_in[15:8];
    assign b = rgb_in[23:16];

    // -----------------------------------------------------
    // 処理ロジック (R + G + B) / 3
    // -----------------------------------------------------
    
    // 加算結果を保持するレジスタ (8bit + 8bit + 8bit = 最大24bit幅が必要)
    // 実際は最大 255 * 3 = 765 なので、10bitあれば十分
    logic [9:0] sum_reg;
    
    // グレースケール値 (Y = sum / 3)
    logic [7:0] gray_val;

    // パイプラインステージ 1: 加算
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg <= 10'd0;
        end else begin
            // 符号なし加算 (R + G + B)
            // r, g, b を10bitに拡張してから加算
            sum_reg <= {2'b0, r} + {2'b0, g} + {2'b0, b};
        end
    end
    
    // パイプラインステージ 2: 除算と出力
    // 除算は組み合わせ回路 (合成時はルックアップテーブルまたは専用回路)
    // sum_reg の出力が安定した後に、除算（>> 2 は /4 に近いが、ここでは /3 をそのまま使用）
    assign gray_val = sum_reg / 3;

    // 出力レジスタ (パイプラインレジスタ)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gray_out <= 8'h00;
            valid_out <= 1'b0;
        end else begin
            gray_out <= gray_val;
            // valid_inを1クロック遅延させて valid_out とする
            valid_out <= valid_in;
        end
    end

endmodule