// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim@g.hmc.edu
// 11/18/2024


module demo_top(input logic sck, 
            input  logic sdi,
            output logic sdo,
            input  logic load,
            input logic mode,
            //input logic clk, // comment out for testing on hardware
            output logic [7:0] led
            );

            /////////////// internal signals
            logic [15:0] p1, p2;
            logic [11:0] p1data, p2data; //12 bit voltages for Daniel's modules
            logic [5:0] single_screen, multi_screen, screen; //inputs to, output from screen mux

            assign p1data = p1[11:0];
            assign p2data = p2[11:0];

            //////////////// modules

            oscillator myOsc(clk); //uncomment out for testing on hardware

            spi_receive_only mySPI(sck, sdi, sdo, load, p1, p2);
            single mySingle(p1data, single_screen);
            multi myMulti(p1data, p2data, clk, reset, multi_screen);
            mux2 #(6) screenMux(mode, single_screen, multi_screen, screen);
            demo_display myDisplay (screen, led);

endmodule

/*
module real_top(input  logic sck, 
            input  logic sdi,
            output logic sdo,
            input  logic load,
            input logic mode,
            input logic clk, // comment out for testing on hardware
            output logic r1, g1, b1, r1, g2, b2,
            output logic A, B, C, D,
            output logic LAT, OEN, OCLK
            );

            /////////////// internal signals
            logic [15:0] p1, p2;
            logic [11:0] p1data, p2data; //12 bit voltages for Daniel's modules
            logic [5:0] single_screen, multi_screen, screen; //inputs to, output from screen mux

            assign p1data = p1[11:0];
            assign p2data = p2[11:0];

            //////////////// modules

            //oscillator myOsc(clk); //uncomment out for testing on hardware

            spi_receive_only mySPI(sck, sdi, sdo, load, p1, p2);
            single mySingle(p1data, single_screen);
            multi myMulti(p1data, p2data, clk, reset, multi_screen);
            mux2 #(6) screenMux(mode, single_screen, multi_screen, screen);
            display myDisplay (screen, r1, g1, b1, r1, g2, b2, A, B, C, D, LAT, OEN, OCLK);

endmodule*/
