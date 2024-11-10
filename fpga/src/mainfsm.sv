// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 11/10/2024
//

module gamelogic(input logic p1data,
                input logic p2data,
                output logic display);

    logic [3:0] state, nextstate;

    always_ff @(posedge clk)
        if (!reset) state <= 0;
        else state <= nextstate;

    // nextstate logic
    always_comb
        case (state)
            0:
            default: nextstate <= 0;
        endcase
    
    // output logic
    always_comb
        case (state)
            0:
            default:
        endcase
endmodule