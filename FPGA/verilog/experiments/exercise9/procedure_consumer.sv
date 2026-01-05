// --- Master: データを生成して送る側 ---
module producer (
    simple_bus_if.master bus, // インターフェースのmaster役割として接続
    input  logic         rst_n
);
    always_ff @(posedge bus.clk or negedge rst_n) begin
        if (!rst_n) begin
            bus.data  <= 8'h00;
            bus.valid <= 1'b0;
        end else begin
            // 相手が準備完了(ready)なら次のデータを送り、validを立てる
            if (bus.ready) begin
                bus.data  <= bus.data + 1'b1;
                bus.valid <= 1'b1;
            end else if (bus.valid && !bus.ready) begin
                // 送信中だが相手が受け取っていない場合は維持
                bus.valid <= 1'b1;
            end
        end
    end
endmodule

// --- Slave: データを受け取る側 ---
module consumer (
    simple_bus_if.slave bus, // インターフェースのslave役割として接続
    input  logic        rst_n
);
    always_ff @(posedge bus.clk or negedge rst_n) begin
        if (!rst_n) begin
            bus.ready <= 1'b0;
        end else begin
            // 送信側が有効(valid)なら、readyを返して受け取る
            // ここでは1クロックごとに必ず受け取れる状態にする例
            bus.ready <= bus.valid;
        end
    end
endmodule