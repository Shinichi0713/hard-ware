
module seven (
    input  logic [2:0] inp,   // 3-bit input
    output logic a,
    output logic b,
    output logic c,
    output logic d,
    output logic e,
    output logic f,
    output logic g
);

always_comb begin
	// ?????????
        a = 1'b0;
        b = 1'b0;
        c = 1'b0;
        d = 1'b0;
        e = 1'b0;
        f = 1'b0;
        g = 1'b0;

	case(inp)
	    3'b000: begin a=1; b=1; c=1; d=1; e=1; f=1; g=0; end // 0
            3'b001: begin a=0; b=1; c=1; d=0; e=0; f=0; g=0; end // 1
            3'b010: begin a=1; b=1; c=0; d=1; e=1; f=0; g=1; end // 2
            3'b011: begin a=1; b=1; c=1; d=1; e=0; f=0; g=1; end // 3
            3'b100: begin a=0; b=1; c=1; d=0; e=0; f=1; g=1; end // 4
            3'b101: begin a=1; b=0; c=1; d=1; e=0; f=1; g=1; end // 5
            3'b110: begin a=1; b=0; c=1; d=1; e=1; f=1; g=1; end // 6
            3'b111: begin a=1; b=1; c=1; d=0; e=0; f=0; g=0; end // 7
            default: begin a=0; b=0; c=0; d=0; e=0; f=0; g=0; end
	endcase
end
endmodule