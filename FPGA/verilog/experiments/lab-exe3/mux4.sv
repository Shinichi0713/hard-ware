module mux4
(
	input logic [3:0] a,
	input logic [3:0] b,
	input logic sel,
	output logic [3:0] y
);

	always_comb begin
	if (sel)
		y = a;
	else
		y = b;
	end
endmodule