`timescale 1ns / 1ps

module seven_tb;

    // ????
    logic [2:0] inp;
    logic a, b, c, d, e, f, g;

    // DUT (Device Under Test) ???????
    seven uut (
        .inp(inp),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );

    // ????????
    initial begin
        // ??????
        $display("Time\tinp\ta b c d e f g");
        $display("----------------------------");

        // 0?7 ????????????
        for (int i = 0; i < 8; i++) begin
            inp = i;
            #10; // 10ns ????

            // ????
            $display("%0t\t%b\t%b %b %b %b %b %b %b", 
                      $time, inp, a, b, c, d, e, f, g);
        end

        $finish; // ??????????
    end

endmodule