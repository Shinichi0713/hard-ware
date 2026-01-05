`timescale 1ns/1ps

module tb_handshake;
    logic clk = 0;
    logic rst_n;

    // クロック生成
    always #5 clk = ~clk;

    // 1. インターフェースのインスタンス化
    simple_bus_if my_bus (clk);

    // 2. 各モジュールのインスタンス化
    producer u_producer (
        .bus   (my_bus), // インターフェースをそのまま渡す
        .rst_n (rst_n)
    );

    consumer u_consumer (
        .bus   (my_bus),
        .rst_n (rst_n)
    );

    // テストシナリオ
    initial begin
        rst_n = 0;
        #20 rst_n = 1;

        // しばらく動かす
        repeat (10) @(posedge clk);

        $display("Final Data: %h", my_bus.data);
        $finish;
    end

    // 波形観測用
    initial begin
        $monitor("Time: %0t | Data: %h | Valid: %b | Ready: %b", 
                 $time, my_bus.data, my_bus.valid, my_bus.ready);
    end
endmodule