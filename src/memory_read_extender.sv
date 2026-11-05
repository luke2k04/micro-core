module memory_read_extender (
	input wire [31:0] read_data,
	input wire [2:0] extend_mode,
	input wire [1:0] address_lsb,

	output logic [31:0] extended_data
);

	logic [15:0] h;
	logic [7:0] b;

	always_comb begin

		case (address_lsb)
			2'b00: begin
				h = read_data[15:0];
				b = read_data[7:0];
			end
			2'b01: begin
				h = read_data[15:0];
				b = read_data[15:8];
			end
			2'b10: begin
				h = read_data[31:16];
				b = read_data[23:16];
			end
			2'b11: begin
				h = read_data[31:16];
				b = read_data[31:24];
			end
		endcase

		case (extend_mode)
			0: extended_data = read_data; // lw
			1: extended_data = {{16{h[15]}}, h[15:0]}; // lh
			2: extended_data = {{24{b[7]}}, b[7:0]}; // lb
			3: extended_data = {16'b0, h}; // lhu
			4: extended_data = {24'b0, b}; // lbu
			default: extended_data = read_data;
		endcase
	end

endmodule

