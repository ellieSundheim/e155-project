// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim@g.hmc.edu
// 11/27/2024

// clock divider module
module clockdivider(
	input logic reset,
	output logic clk
);
	logic int_osc;
    logic [2:0] counter;

	// Internal high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
	// Simple clock divider
	always_ff @(posedge int_osc) begin
		if (!reset) 	counter <= 0;
		else 		counter <= counter + 1;
		end
	assign clk = counter[2];
endmodule