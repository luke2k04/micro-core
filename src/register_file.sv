module register_file (
	input wire clk,
	input wire we_3,

	input wire [4:0] a_1,
	input wire [4:0] a_2,
	input wire [4:0] a_3,

	input wire [31:0] wd_3,

	output wire [31:0] rd_1,
	output wire [31:0] rd_2
);

	logic [31:0] registers [31:1];

	assign rd_1 = a_1 == 0 ? 0 : registers[a_1];
	assign rd_2 = a_2 == 0 ? 0 : registers[a_2];
	
	always_ff @(posedge clk) begin
		if (we_3 && a_3 != 5'b00000)
			registers[a_3] <= wd_3;
	end
endmodule
