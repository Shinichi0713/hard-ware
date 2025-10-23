module dff (
    input  logic clk,
    input  logic d,
    output logic q
);
    always_ff @(posedge clk)
        q <= d;  // 順序回路（状態を保持）
endmodule
