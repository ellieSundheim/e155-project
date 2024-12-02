`timescale 10ns/1ns
// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 11/20/2024
//

module testbench_creatematrix();
    logic [5:0] screen;
    logic clk;
    logic [31:0] matrix [15:0];

    creatematrix dut(screen,clk,matrix);

    always begin
        clk <= 0; #5;
        clk <= 1; #5;
    end

    initial begin 
        screen <= 6'b000000; #25;/*
        screen <= 6'b000001; #25;
        screen <= 6'b000010; #25;
        screen <= 6'b000011; #25;*/
        
    end

endmodule