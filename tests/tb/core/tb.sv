`timescale 1ns/1ps
module tb ();

	logic clk, reset, halt;

	core dut (
		.clk(clk),
		.reset(reset),
		.halt(halt)
	);

	always #5 clk = ~clk;

	string program_file = "program.hex";
	string memory_file = "memory.hex";
	string memory_dump_file = "memory_dump.hex";

	initial begin
		$value$plusargs("program=%s", program_file);
		$value$plusargs("memory=%s", memory_file);
		$value$plusargs("dump=%s", memory_dump_file);

		$readmemh(program_file, dut.u_instruction_memory.data);
		$readmemh(memory_file, dut.u_data_memory.data);
		clk = 0;
		reset = 1;
		#10 reset = 0;
		
		do
			#10;
		while (~halt);

		$writememh(memory_dump_file, dut.u_data_memory.data, 0, 15);
		$display("Exit code (a0) = %h", dut.u_register_file.registers[10]);
		$finish();
	end
endmodule
