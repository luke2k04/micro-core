module data_memory #(
	parameter int DEPTH = 1024
	) (
	input wire clk,
	input wire we,
	input wire [31:0] a,
	input wire [31:0] wd,
	input wire valid,
	input wire [1:0] write_mode, // 0 = word, 1 = half, 2 = byte
	input wire [31:0] instruction_address,

	output logic [31:0] rd,
	output logic ready,
	output logic [31:0] read_instruction
);

	logic [31:0] data [DEPTH-1:0];

	localparam int INDEX_BITS = $clog2(DEPTH);
	

	always_ff @(posedge clk) begin
		// reading instruction
		read_instruction = data[instruction_address[INDEX_BITS+1:2]];
		
		if (ready)
			ready = 0;
		// reading data
		if (valid) begin
			rd = data[a[INDEX_BITS+1:2]];
			ready = 1;
		end

		// writing
		if (we) begin
			if (write_mode == 0)
				data[a[INDEX_BITS+1:2]] <= wd;
			if (write_mode == 1) begin
				if (a[1] == 0)
					data[a[INDEX_BITS+1:2]][15:0] <= wd[15:0];
				else
					data[a[INDEX_BITS+1:2]][31:16] <= wd[15:0];
			end
			if (write_mode == 2) begin
				if (a[1:0] == 2'b00)
					data[a[INDEX_BITS+1:2]][7:0] <= wd[7:0];
				else if (a[1:0] == 2'b01)
					data[a[INDEX_BITS+1:2]][15:8] <= wd[7:0];
				else if (a[1:0] == 2'b10)
					data[a[INDEX_BITS+1:2]][23:16] <= wd[7:0];
				else if (a[1:0] == 2'b11)
					data[a[INDEX_BITS+1:2]][31:24] <= wd[7:0];
			end

		end
	end

endmodule
