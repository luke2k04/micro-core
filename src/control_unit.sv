module control_unit (
	input wire [6:0] op,
	input wire [2:0] funct_3,
	input wire funct_7_bit_5,
	input wire zero_flag,
	input wire sign_flag,
	input wire overflow_flag,

	output wire halt,
	output wire [1:0] memory_write_mode,
	output wire [2:0] extend_mode,
	output logic [1:0] pc_source_select,
	output wire [2:0] result_source_select,
	output wire memory_we,
	output wire [3:0] alu_control,
	output wire alu_source_select,
	output wire [2:0] imm_source_select,
	output wire register_file_we
);

	wire jalr;
	wire branch_eq;
	wire branch_ne;
	wire branch_lt;
	wire branch_ge;
	wire branch_geu;
	wire branch_ltu;
	wire jump;
	wire [1:0] alu_operation;

	main_decoder u_main_decoder (
		.halt(halt),
		.op(op),
		.branch_eq(branch_eq),
		.branch_ne(branch_ne),
		.branch_lt(branch_lt),
		.branch_ge(branch_ge),
		.branch_ltu(branch_ltu),
		.branch_geu(branch_geu),
		.memory_write_mode(memory_write_mode),
		.funct_3(funct_3),
		.result_source_select(result_source_select),
		.memory_we(memory_we),
		.alu_source_select(alu_source_select),
		.imm_source_select(imm_source_select),
		.register_file_we(register_file_we),
		.alu_operation(alu_operation),
		.jalr(jalr),
		.jump(jump),
		.extend_mode(extend_mode)
	);
	
	alu_decoder u_alu_decoder (
		.funct_3(funct_3),
		.funct_7_bit_5(funct_7_bit_5),
		.op_bit_5(op[5]),
		.alu_op(alu_operation),
		.alu_control(alu_control)
	);

	always_comb begin
		pc_source_select = 0;
		if (branch_eq && zero_flag)
			pc_source_select = 1;
		if (branch_ne && ~zero_flag)
			pc_source_select = 1;
		if (branch_lt && sign_flag && ~zero_flag)
			pc_source_select = 1;
		if (branch_ge && ~sign_flag && ~zero_flag)
			pc_source_select = 1;
		if (branch_ltu && overflow_flag && ~zero_flag)
			pc_source_select = 1;
		if (branch_geu && ~overflow_flag && ~zero_flag)
			pc_source_select = 1;
		if (jump)
			pc_source_select = 1;
		if (jalr)
			pc_source_select = 2;
	end

endmodule
