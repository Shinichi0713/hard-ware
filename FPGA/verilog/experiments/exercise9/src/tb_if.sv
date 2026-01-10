`timescale 1ns/1ps

module tb_top_system;
    parameter int NUM = 4;
    logic clk = 0;
    logic rst_n;
    logic [31:0] total;

    top_system #(.AGENT_COUNT(NUM)) dut (.*);

    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        #25 rst_n = 1;
        
        repeat (20) @(posedge clk);
        
        $display("Final Global Score: %d", total);
        $finish;
    end
endmodule