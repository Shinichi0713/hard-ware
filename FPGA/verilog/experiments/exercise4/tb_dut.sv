`timescale 1ns/1ps

module encoder3_tb;

    logic [2:0] in;
    logic [1:0] encode;
    logic       valid;

    // DUT インスタンス
    encoder3 dut (
        .in(in),
        .encode(encode),
        .valid(valid)
    );

    // テストタスク
    task check(input logic [2:0] t_in,
               input logic [1:0] exp_encode,
               input logic       exp_valid);
        begin
            in = t_in;
            #1;  // 組み合わせ回路なので少し待つ
            if (encode !== exp_encode || valid !== exp_valid)
                $display("NG: in=%b exp_encode=%b got=%b exp_valid=%b got=%b",
                          t_in, exp_encode, encode, exp_valid, valid);
            else
                $display("OK: in=%b => encode=%b valid=%b",
                          t_in, encode, valid);
        end
    endtask

    initial begin
        $display("=== 3入力優先度付きエンコーダ TEST START ===");

        // 明示的テストパターン
        check(3'b000, 2'b00, 1'b0);  // valid=0
        check(3'b001, 2'b00, 1'b1);  // IN0
        check(3'b010, 2'b01, 1'b1);  // IN1
        check(3'b100, 2'b10, 1'b1);  // IN2（最優先）
        check(3'b011, 2'b01, 1'b1);  // IN1 優先
        check(3'b110, 2'b10, 1'b1);  // IN2 優先
        check(3'b101, 2'b10, 1'b1);  // IN2 優先
        check(3'b111, 2'b10, 1'b1);  // IN2 優先

        $display("=== TEST END ===");
        $finish;
    end

endmodule
