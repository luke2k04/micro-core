module instruction_memory #(
	parameter int DEPTH = 32
) (
	input wire [31:0] a,
	output wire [31:0] rd
);

	localparam int INDEX_BITS = $clog2(DEPTH);
	logic [31:0] data [DEPTH-1:0]; 

	assign rd = data[a[INDEX_BITS+1:2]];

endmodule
