module alu (
	input wire [31:0] src_a,
	input wire [31:0] src_b,
	output logic [31:0] result,
	output logic zero_flag,
	output logic overflow_flag,

	input wire [3:0] control
);

	always_comb begin
		case (control)
			0: result = src_a + src_b;
			1: result = src_a - src_b;
			2: result = src_a & src_b;
			3: result = src_a | src_b;
			4: result = src_a ^ src_b;
			5: result = ($signed(src_a) < $signed(src_b)) ? 1 : 0;
			6: result = src_a << src_b;
			7: result = src_a >> src_b[4:0]; // logical
			8: result = $unsigned($signed(src_a) >>> src_b[4:0]); // arithmetic
			9: result = ($unsigned(src_a) < $unsigned(src_b)) ? 1 : 0;
			default: result = 'x;
		endcase
		zero_flag = result == 0 ? 1 : 0;
		overflow_flag = ($unsigned(src_a) < $unsigned(src_b)) ? 1 : 0;
	end
endmodule
