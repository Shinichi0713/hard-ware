//============================================================
// Testbench for mult4x4
//============================================================
`timescale 1ns/1ps

module tb_mult4x4;

    // 信号宣言
    logic [3:0] a, b;
    logic [7:0] product;

    // DUT（Device Under Test）インスタンス
    mult4x4 dut (
        .a(a),
        .b(b),
        .product(product)
    );

    // テストパターン
    initial begin
        $display("=== 4x4 Multiplier Test Start ===");
        $display("Time |   A  |   B  | Product");

        a = 4'd0; b = 4'd0; #10;
        $display("%4t | %2d | %2d | %3d", $time, a, b, product);

        a = 4'd3; b = 4'd5; #10;
        $display("%4t | %2d | %2d | %3d", $time, a, b, product);

        a = 4'd7; b = 4'd9; #10;
        $display("%4t | %2d | %2d | %3d", $time, a, b, product);

        a = 4'd15; b = 4'd15; #10;
        $display("%4t | %2d | %2d | %3d", $time, a, b, product);

        $display("=== Test Complete ===");
        $finish;
    end

endmodule
