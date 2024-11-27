// internal oscillator
module hsoscillator(output logic clk);

	logic int_osc;
  
	// Internal high-speed oscillator (div 2'b00 makes it oscillate at 48Mhz, )
	HSOSC #(.CLKHF_DIV(2'b00)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    assign clk = int_osc;
  
endmodule

module lsoscillator(output logic clk);

	logic int_osc;
  
	// Internal low-speed oscillator oscillates at 10 kHz
	LSOSC lf_osc (.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(int_osc));

    assign clk = int_osc;
  
endmodule



module mux2 #(parameter WIDTH = 32)
            (input logic select,
            input logic [WIDTH-1:0] s1, s2,
            output logic [WIDTH-1:0] out);

    assign out = select ? s2 : s1;

endmodule


module flopenr #(parameter WIDTH = 32)
                (input logic clk, en, reset,
                input logic [WIDTH-1:0] q,
                output logic [WIDTH-1:0] d);

always_ff @(posedge clk) begin
  if (reset) d <= 0;
  else if (en) d <= q;
end
endmodule
