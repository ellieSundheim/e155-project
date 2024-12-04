// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim@g.hmc.edu
// 11/18/2024


/*module test_top(input logic areset,
            output logic outclk,
            output logic [5:0] rgb, // R1,G1,B1,R2,G2,B2
            output logic lat, oe,
            output logic [2:0] abc); // ABC
            logic clk,reset;

        assign reset = ~areset;
        assign screen = 6'b100001;

        oscillator myOsc(clk);
        //clockdivider clkdivider(reset,clk);

        test test(clk,reset,rgb,lat,oe,abc,outclk);
        //displayinterface testdisplay(screen,clk,reset,rgb,lat,oe,abc,outclk);
        //multidisplayinterface multidisplay(screen,clk,reset,rgb,lat,oe,abc,outclk);
        

endmodule*/

module demo_top(input logic sck, 
            input  logic sdi,
            input logic areset,
            output logic sdo,
            input  logic load,
            input logic mode,
            //input logic clk, // comment out for testing on hardware
            output logic outclk,
            output logic [5:0] rgb, // R1,G1,B1,R2,G2,B2
            output logic lat, oe,
            output logic [2:0] abc // ABC
            );
            logic clk, reset;
            logic [5:0] mrgb, srgb;
            logic mlat, moe, moutclk, slat, soe, soutclk;
            logic [2:0] mabc, sabc;

            /////////////// internal signals
            logic [15:0] p1, p2;
            logic [11:0] p1data, p2data; //12 bit voltages for Daniel's modules
            logic [5:0] single_screen, multi_screen, screen; //inputs to, output from screen mux

            assign p1data = p1[11:0];
            assign p2data = p2[11:0];
            assign reset = ~areset;
            assign screen = 6'b100010; // hard code for testing

            //////////////// modules

            oscillator myOsc(clk); //uncomment out for testing on hardware

            spi_receive_only mySPI(sck, sdi, sdo, load, p1, p2); // read adc values from mcu
            single mySingle(p1data, single_screen); //
            multi myMulti(p1data, p2data, clk, reset, multi_screen);
            //mux2 #(6) screenMux(mode, single_screen, multi_screen, screen);
            //demo_display myDisplay (screen, led);
            singledisplay singledisplay(single_screen,clk,reset,srgb,slat,soe,sabc,soutclk);
            multidisplay multidisplay(multi_screen,clk,reset,mrgb,mlat,moe,mabc,moutclk);

            // outputs multiplexed depending on if in single or multi player mode
            assign rgb = mode ? mrgb : srgb;
            assign lat = mode ? mlat : slat;
            assign oe = mode ? moe : soe;
            assign abc = mode ? mabc : sabc;
            assign outclk = mode ? moutclk : soutclk;
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
