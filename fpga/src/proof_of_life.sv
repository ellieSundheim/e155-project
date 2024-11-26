module proof_of_life(//input logic clk, 
					input logic areset,
                    output logic r1, g1, b1, r2, g2, b2,
                    output logic [2:0] abc,
                    output logic oclk, lat, oe);
					
		logic reset;
		assign reset = ~areset;
		logic clk;
		oscillator myOSC(clk);
		
		
        assign oclk = clk;
        assign r1 = abc[2];
        assign g1 = abc[1];
        assign b1 = abc[0];
        assign r2 = abc[2];
        assign g2 = abc[1];
        assign b2 = abc[0];


        logic [7:0] counter;

        typedef enum logic [4:0] {loadRow, enableRow, error } statetype;
        statetype state, nextstate;

        //flops
        always_ff @(posedge clk) begin
			if (reset) begin
				counter <= 0;
				state <= loadRow;
				abc <= 3'b110;
			end
			else if (state == enableRow) begin
				counter <= 0;
				state <= nextstate;
				abc <= abc + 1;
				
			end
			else begin
				counter <= counter + 1;
				state <= nextstate;
			end
		end
        

        // next state logic
        always_comb begin
        case (state)
            loadRow: if (counter < 32) nextstate = state;
                    else nextstate = enableRow;
            enableRow: nextstate = loadRow;
            error: nextstate = error;
            default: nextstate = error;
        endcase
        end

        // output logic
        always_comb begin
            oe = (state == enableRow);
            lat = (state == loadRow);
         end


    

endmodule


module proof_of_life_tb();
    logic clk, reset;
    logic r1, g1, b1, r2, g2, b2;
    logic [2:0] abc;
    logic oclk, lat, oe;

    proof_of_life dut(clk, reset, r1, g1, b1, r2, g2, b2, abc, oclk, lat, oe);

    always begin
            clk = 1'b0; #5;
            clk = 1'b1; #5;
    end

    initial begin
        reset = 1; #10; reset = 0;
        #500;
    end




endmodule