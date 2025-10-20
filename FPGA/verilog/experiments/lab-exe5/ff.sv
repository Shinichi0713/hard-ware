module ff(
    input logic clk,
    input logic aclr,
    input logic clken,
    input logic d,
    output logic q
)
always_ff @(posedge clk or negedge aclr) begin
    if (!aclr)
        q<=1'b0;    // クリア動作：aclr=0 のとき即リセット
    else if (clken)
        q <= d;     // クロック立ち上がりで clken=1 なら d を取り込む
end
endmodule