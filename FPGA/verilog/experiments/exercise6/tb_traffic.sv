`timescale 1s/100ms  // 1Hz想定のため単位を秒に設定

module tb_traffic_light;
    logic clk;
    logic rst_n;
    logic red, green, yellow;

    // インスタンス化
    traffic_light dut (.*);

    // クロック生成 (1Hz = 1秒周期)
    always #0.5s clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        
        #1.2s rst_n = 1; // リセット解除

        // サイクルを2周分確認
        #20s;
        
        $finish;
    end

    // ログ表示
    initial begin
        $monitor("Time: %0t | State: %s | R:%b G:%b Y:%b", 
                 $time, dut.current_state.name(), red, green, yellow);
    end
endmodule