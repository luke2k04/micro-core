module pc_register (
	input wire [31:0] pc_next,
	input wire stall,
	input wire clk,
	output logic [31:0] pc,
	input wire reset
);

always @(posedge clk or posedge reset) begin
	if (reset) 
		pc <= 0;
	else 
		pc <= stall ? pc : pc_next;
end

endmodule
