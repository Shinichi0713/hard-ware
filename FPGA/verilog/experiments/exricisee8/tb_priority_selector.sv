`timescale 1ns/1ps

module tb_priority_selector;
    // テスト用の設定
    localparam int N = 8;
    localparam int W = $clog2(N);

    logic [N-1:0] req;
    logic [W-1:0] idx;
    logic         active;

    // インスタンス化：8入力、LSB優先に設定
    priority_selector #(
        .NUM_INPUTS(N),
        .PRIORITY_HIGH_TO_LOW(0) 
    ) dut (
        .request_vector(req),
        .selected_index(idx),
        .active(active)
    );

    initial begin
        $display("Starting Priority Selector Test (LSB Priority)");
        
        // ケース1: リクエストなし
        req = 8'b0000_0000; #10;
        $display("Req:%b | Active:%b | Index:%d", req, active, idx);

        // ケース2: 単一リクエスト (Bit 3)
        req = 8'b0000_1000; #10;
        $display("Req:%b | Active:%b | Index:%d", req, active, idx);

        // ケース3: 複数リクエスト (Bit 2 と Bit 5)
        // LSB優先なので、小さい方の「2」が選ばれるはず
        req = 8'b0010_0100; #10;
        $display("Req:%b | Active:%b | Index:%d (Expect 2)", req, active, idx);

        // ケース4: 全リクエスト
        // LSB優先なので「0」が選ばれるはず
        req = 8'b1111_1111; #10;
        $display("Req:%b | Active:%b | Index:%d (Expect 0)", req, active, idx);

        $finish;
    end
endmodule