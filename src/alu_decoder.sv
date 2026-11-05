module alu_decoder (
	input wire [2:0] funct_3,
	input wire funct_7_bit_5,
	input wire op_bit_5,
	input wire [1:0] alu_op,

	output logic [3:0] alu_control
);

	always_comb begin
		alu_control = 0;
		if (alu_op == 2'b00)
			alu_control = 0;
		if (alu_op == 2'b01)
			alu_control = 1;
		if (alu_op == 2'b10) begin
			if (funct_3 == 3'b000) begin
				if ({op_bit_5, funct_7_bit_5} == 2'b11)
					alu_control = 1;
				else
					alu_control = 0;
			end
			if (funct_3 == 3'b010)
				alu_control = 5;
			if (funct_3 == 3'b110)
				alu_control = 3;
			if (funct_3 == 3'b111)
				alu_control = 2;
			if (funct_3 == 3'b100)
				alu_control = 4; // xor
			if (funct_3 == 3'b001)
				alu_control = 6; // sll
			if (funct_3 == 3'b011)
				alu_control = 9; // sltu
			if (funct_3 == 3'b101) begin
				if (funct_7_bit_5 == 1) begin
					alu_control = 8;
				end else begin
					alu_control = 7;
				end
			end
		end
	end
endmodule
