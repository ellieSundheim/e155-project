`timescale 10ns/1ns
// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 12/4/2024
//

module testbench_multi();
    logic [11:0] p1data, p2data;
    logic clk, reset;
    logic [5:0] screen;

    multi dut(p1data,p2data,clk,reset,screen);

    initial begin 
        reset <= 0; #5;
        reset <= 1; #5;
        reset <= 0; #5;
    end

    always begin
        clk <= 0; #5;
        clk <= 1; #5;
    end

    initial begin 
        p1data <= 0; 
        p2data <= 1;
        #250;
        p1data <= 1;
        p2data <= 0;
        #200;
        p1data <= 0;
        p2data <= 1;
        #50;
        p1data <= 1;
        p2data <= 0;
        #500;
    end

endmodule

module testbench_multidisplay();
    logic [5:0] screen;
    logic clk, reset;
    logic [5:0] rgb;
    logic oe, lat;
    logic [2:0] abc;
    logic outclk;

    multidisplay dut(screen,clk,reset,rgb,lat,oe,abc,outclk);

    initial begin 
        reset <= 0; #5;
        reset <= 1; #5;
        reset <= 0; #5;
    end

    always begin
        clk <= 0; #5;
        clk <= 1; #5;
    end

    initial begin
        screen <= 28; #50;
    end

endmodule