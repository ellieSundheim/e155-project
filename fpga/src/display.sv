// Ellie Sundheim and Daniel Fajardo
// esundheim@hmc.edu and dfajardo@hmc.edu
// 11/18/24


// demo_display outputs the p1 value scaled to 8 LEDs for testing
// it should not be used with multifsm
module demo_display(input logic [5:0] screen,
                    output logic [7:0] led);

    always_comb begin
        case (screen)
            0:  led = 8'b0;
            1:  led = 8'b0; //no leds on
            2:  led = 8'b1;
            3:  led = 8'b1;
            4:  led = 8'b11;
            5:  led = 8'b11;
            6:  led = 8'b111;
            7:  led = 8'b111;
            8:  led = 8'b1111;
            9:  led = 8'b1111;
            10: led = 8'b11111;
            11: led = 8'b11111;
            12: led = 8'b111111;
            13: led = 8'b111111;
            14: led = 8'b111_1111;
            15: led = 8'b111_1111;
            default: led = 8'b1111_1111;
        endcase
    end

endmodule