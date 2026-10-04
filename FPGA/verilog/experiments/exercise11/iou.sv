module play_alu (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  op,
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [7:0]  result
);
    typedef enum logic [1:0] {
        OP_ADD = 2'b00,
        OP_XOR = 2'b01,
        OP_ROT = 2'b10,
        OP_REV = 2'b11
    } op_t;

    logic [7:0] reg_a, reg_b;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_a <= 8'h00;
            reg_b <= 8'h00;
        end else begin
            reg_a <= a;
            reg_b <= b;
        end
    end

    always_comb begin
        case (op)
            OP_ADD: result = reg_a + reg_b;
            OP_XOR: result = reg_a ^ reg_b;
            OP_ROT: result = {reg_a[0], reg_a[7:1]};  // 右ローテート
            OP_REV: result = {reg_a[0], reg_a[1], reg_a[2], reg_a[3],
                              reg_a[4], reg_a[5], reg_a[6], reg_a[7]};
            default: result = 8'h00;
        endcase
    end

endmodule