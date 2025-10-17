//==================================================
// Testbench for mux4
//==================================================
`timescale 1ns/1ps

module mux4_tb;

    // ????
    logic [3:0] a;
    logic [3:0] b;
    logic sel;
    logic [3:0] y;

    // ??????????????????
    mux4 uut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    // ?????????
    initial begin
        $display("=== MUX4 Simulation Start ===");
        $display("Time\tSel\tA\tB\tY");

        // ???
        a = 4'b0000;
        b = 4'b1111;
        sel = 0;

        #10; $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, y);

        // sel=0 ? b???
        #10 sel = 0;
        a = 4'b1010;
        b = 4'b0101;
        #10; $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, y);

        // sel=1 ? a???
        #10 sel = 1;
        #10; $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, y);

        // sel????
        repeat (4) begin
            #10 sel = ~sel;
            a = a + 1;
            b = b - 1;
            #10; $display("%0t\t%b\t%b\t%b\t%b", $time, sel, a, b, y);
        end

        $display("=== Simulation End ===");
        $finish;
    end

endmodule
