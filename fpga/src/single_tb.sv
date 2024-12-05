`timescale 10ns/1ns
// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 11/18/2024
//

module testbench_single();
    logic [11:0] p1data;
    logic [5:0] screen;

    single dut(p1data,screen);

    initial begin 
        p1data <= 0; #50;
        p1data <= 12'b000011100000; #50;
        p1data <= 12'b000111000000; #50;
        p1data <= 12'b001010100010; #50;
        p1data <= 12'b001110000100; #50;
        p1data <= 12'b010001100100; #50;
        p1data <= 12'b110100110010; #50;
        p1data <= 0;
    end

endmodule


module testbench_singledisplay();
    logic [5:0] screen;
    logic clk, reset;
    logic [5:0] rgb;
    logic oe, lat;
    logic [2:0] abc;
    logic outclk;

    singledisplay dut(screen,clk,reset,rgb,lat,oe,abc,outclk);

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
        screen <= 3; #50;
    end

endmodule