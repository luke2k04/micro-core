`default_nettype none
module core #(
	) (
	input wire clk,
	input wire reset,

	output logic halt
	);

	wire [31:0] pc;
	wire [31:0] pc_plus_4;
	wire [31:0] instr;
	logic [31:0] pc_next;
	logic stall;

	pc_register u_pc (
		.pc_next(pc_next),
		.stall(stall),
		.clk(clk),
		.pc(pc),
		.reset(reset)
	); 

	instruction_memory #(
		.DEPTH(1024)
	) u_instruction_memory (
		.a(pc),
		.rd(instr)
	);

	logic register_file_we_3;
	wire [31:0] extended_data, register_file_rd_1, write_data;
	logic [31:0] result;

	wire [2:0] result_source;
	logic register_write;

	register_file u_register_file (
		.clk(clk),
		.we_3(register_file_we_3),
		.a_1(instr[19:15]),
		.a_2(instr[24:20]),
		.a_3(instr[11:7]),
		.wd_3(result),
		.rd_1(register_file_rd_1),
		.rd_2(write_data)
	);

	wire [31:0] imm_extended;
	wire [2:0] imm_source_select;

	extend u_extend (
		.in(instr[31:7]),
		.out(imm_extended),
		.imm_source(imm_source_select)
	);

	wire [31:0] alu_result;
	wire [3:0] alu_control;
	wire alu_source_select;
	logic [31:0] alu_source_b;
	wire alu_zero_flag;
	wire alu_overflow_flag;

	alu u_alu (
		.src_a(register_file_rd_1),
		.src_b(alu_source_b),
		.result(alu_result),
		.control(alu_control),
		.overflow_flag(alu_overflow_flag),
		.zero_flag(alu_zero_flag)
	);

	logic memory_we;
	wire [31:0] read_data;
	wire [1:0] memory_write_mode;
	logic memory_write;

	data_memory #(.DEPTH(1024)) u_data_memory (
		.clk(clk),
		.a(alu_result),
		.write_mode(memory_write_mode),
		.rd(read_data),
		.wd(write_data),
		.we(memory_we)
	);

	wire [2:0] extend_mode;

	memory_read_extender u_memory_read_extender (
		.read_data(read_data),
		.address_lsb(alu_result[1:0]),
		.extend_mode(extend_mode),
		.extended_data(extended_data)
	);
	
	adder pc_plus_4_adder (
		.in_1(pc),
		.in_2(4),
		.out(pc_plus_4)
	);

	wire [31:0] pc_target;
	wire [1:0] pc_source_select;

	adder pc_target_adder (
		.in_1(pc),
		.in_2(imm_extended),
		.out(pc_target)
	);

	control_unit u_control_unit (
		.halt(halt),
		.memory_write_mode(memory_write_mode),
		.op(instr[6:0]),
		.funct_3(instr[14:12]),
		.funct_7_bit_5(instr[30]),
		.zero_flag(alu_zero_flag),
		.sign_flag(alu_result[31]),
		.overflow_flag(alu_overflow_flag),
		.pc_source_select(pc_source_select),
		.result_source_select(result_source),
		.memory_we(memory_write),
		.alu_control(alu_control),
		.alu_source_select(alu_source_select),
		.imm_source_select(imm_source_select),
		.extend_mode(extend_mode),
		.register_file_we(register_write)
	);
		

	always_comb begin
		result = 0;
		stall = 0;
		pc_next = pc_plus_4;
		alu_source_b = alu_source_select ? imm_extended : write_data;
		register_file_we_3 = register_write & ~stall;
		memory_we = memory_write & ~stall;

		case (result_source)
			0: result = alu_result;
			1: result = extended_data;
			2: result = pc_plus_4;
			3: result = imm_extended;
			4: result = pc_target;
		endcase

		case (pc_source_select)
			0: pc_next = pc_plus_4;
			1: pc_next = pc_target;
			2: pc_next = {alu_result[31:1], 1'b0};
		endcase
	end
endmodule
`default_nettype wire
