module extend (
	input wire [31:7] in,
	output logic [31:0] out,
	input wire [2:0] imm_source
	);

	always_comb begin
		case (imm_source)
			0: out = {{20{in[31]}}, in[31:20]}; // I-type
			1: out = {{20{in[31]}}, in[31:25], in[11:7]}; // S-type
			2: out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0}; // B-type
			3: out = {{12{in[31]}}, in[19:12], in[20], in[30:25], in[24:21], 1'b0}; // J-type 
			4: out = {in[31:12], 12'b0 };
			default: out = 'x;
		endcase
	end
endmodule
