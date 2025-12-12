module encoder3 (
    input  logic [2:0] in,       // in[2] > in[1] > in[0] の優先度
    output logic [1:0] encode,   // エンコード結果
    output logic       valid     // 入力が何かしら1であれば1
);

    always_comb begin
        // デフォルト値
        encode = 2'b00;
        valid  = 1'b0;

        unique case (1'b1)
            in[2]: begin
                encode = 2'b10;
                valid  = 1'b1;
            end
            in[1]: begin
                encode = 2'b01;
                valid  = 1'b1;
            end
            in[0]: begin
                encode = 2'b00;
                valid  = 1'b1;
            end
            default: begin
                encode = 2'b00;
                valid  = 1'b0;
            end
        endcase
    end

endmodule
