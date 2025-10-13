module tb_counter;
    logic clk;
    logic rst_n;
    logic [3:0] count;

    // DUT?Device Under Test????????
    counter dut (
        .clk   (clk),
        .rst_n (rst_n),
        .count (count)
    );

    // ???????10ns??
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ????????
    initial begin
        // ???
        rst_n = 0;
        #12;
        rst_n = 1;

        // ????????
        #100;

        // ??
        $finish;
    end

    // ????????????????
    initial begin
        $monitor("Time=%0t | rst_n=%b | count=%d", $time, rst_n, count);
    end

endmodule