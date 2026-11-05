module main_decoder (
	input wire [6:0] op,
	input wire [2:0] funct_3,

	output logic [1:0] memory_write_mode,
	output logic branch_eq,
	output logic halt,
	output logic branch_ne,
	output logic branch_lt,
	output logic branch_ge,
	output logic branch_ltu,
	output logic branch_geu,
	output logic jump,
	output logic jalr,
	output logic [2:0] result_source_select,
	output logic memory_we,
	output logic alu_source_select,
	output logic [2:0] imm_source_select,
	output logic register_file_we,
	output logic [2:0] extend_mode,
	output logic [1:0] alu_operation
);

	always_comb begin
		// avoid latches
		register_file_we = 0;
		imm_source_select = 'x;
		alu_source_select = 'x;
		memory_we = 0;
		result_source_select = 'x;
		branch_eq = 0;
		branch_ne = 0;
		branch_lt = 0;
		branch_ge = 0;
		branch_ltu = 0;
		branch_geu = 0;
		jump = 0;
		alu_operation = 2'bxx;
		jalr = 0;
		halt = 0;
		extend_mode = 'x;
		memory_write_mode = 'x;
		
		if (op == 7'b1110011) // system (ebreak, ecall)
			halt = 1;
		if (op == 7'b0001111) begin // fence, fence.tso, pause
			// explicitly treated as nop
		end
		if (op == 7'b0110111) begin // lui
			register_file_we = 1;
			imm_source_select = 4;
			result_source_select = 3;
		end
		if (op == 7'b0010111) begin // auipc
			register_file_we = 1;
			imm_source_select = 4;
			result_source_select = 4;
		end
		if (op == 7'b0000011) begin // load
			register_file_we = 1;
			imm_source_select = 0;
			alu_source_select = 1;
			result_source_select = 1;
			alu_operation = 2'b00;
			case (funct_3)
				0: extend_mode = 2; // lb
				1: extend_mode = 1; // lh
				2: extend_mode = 0; // lw
				4: extend_mode = 4; // lbu
				5: extend_mode = 3; // lhu
			endcase
		end
		if (op == 7'b0100011) begin // store
			register_file_we = 0;
			imm_source_select = 1;
			alu_source_select = 1;
			memory_we = 1;
			result_source_select = 'x;
			alu_operation = 2'b00;
			case (funct_3)
				0: memory_write_mode = 2;
				1: memory_write_mode = 1;
				2: memory_write_mode = 0;
			endcase
		end
		if (op == 7'b0110011) begin
			register_file_we = 1;
			alu_source_select = 0;
			memory_we = 0;
			result_source_select = 0;
			alu_operation = 2'b10;
		end
		if (op == 7'b1100011) begin // op-branch
			register_file_we = 0;
			imm_source_select = 2;
			alu_source_select = 0;
			memory_we = 0;
			result_source_select = 0;
			alu_operation = 2'b01;
			if (funct_3 == 3'b000)
				branch_eq = 1;
			if (funct_3 == 3'b001)
				branch_ne = 1;
			if (funct_3 == 3'b100)
				branch_lt = 1;
			if (funct_3 == 3'b101)
				branch_ge = 1;
			if (funct_3 == 3'b110)
				branch_ltu = 1;
			if (funct_3 == 3'b111)
				branch_geu = 1;
		end
		if (op == 7'b0010011) begin // op-imm
			register_file_we = 1;
			imm_source_select = 0;
			alu_source_select = 1;
			memory_we = 0;
			result_source_select = 0;
			alu_operation = 2'b10;
		end
		if (op == 7'b1101111) begin // op-jal
			register_file_we = 1;
			imm_source_select = 3;
			alu_source_select = 1;
			memory_we = 0;
			result_source_select = 2;
			jump = 1;
		end
		if (op == 7'b1100111) begin // op-jalr
			imm_source_select = 0;
			alu_source_select = '1;
			memory_we = 0;
			jump = 1;
			alu_operation = 2'b00;
			register_file_we = 1;
			result_source_select = 2;
			jalr = 1;
		end
	end
endmodule
