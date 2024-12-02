`timescale 10ns/1ns
// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 11/25/2024
//

module testbench_displayinterface();
    logic [31:0] matrix [15:0];
    logic clk, reset;
    logic [5:0] rgb;
    logic lat, oe;
    logic [2:0] abc;

    displayinterface dut(matrix,clk,reset,rgb,lat,oe,abc);

    always begin
        clk <= 0; #5;
        clk <= 1; #5;
    end

    initial begin 
        reset <= 1; #5;
        reset <= 0; #5;
        matrix[0] <= 16'b1111_1111_1111_1111;
        matrix[1] <= 16'b1000_0000_0000_0001;
        matrix[2] <= 16'b1000_0000_0000_0001;
        matrix[3] <= 16'b1000_0000_0000_0001;
        matrix[4] <= 16'b1000_0000_0000_0001;
        matrix[5] <= 16'b1000_0000_0000_0001;
        matrix[6] <= 16'b1000_0000_0000_0001;
        matrix[7] <= 16'b1000_0000_0000_0001;
        matrix[8] <= 16'b1000_0000_0000_0001;
        matrix[9] <= 16'b1000_0000_0000_0001;
        matrix[10] <= 16'b1000_0000_0000_0001;
        matrix[11] <= 16'b1000_0000_0000_0001;
        matrix[12] <= 16'b1000_0000_0000_0001;
        matrix[13] <= 16'b1000_0000_0000_0001;
        matrix[14] <= 16'b1000_0000_0000_0001;
        matrix[15] <= 16'b1000_0000_0000_0001;
        matrix[16] <= 16'b1000_0000_0000_0001;
        matrix[17] <= 16'b1000_0000_0000_0001;
        matrix[18] <= 16'b1000_0000_0000_0001;
        matrix[19] <= 16'b1000_0000_0000_0001;
        matrix[20] <= 16'b1000_0000_0000_0001;
        matrix[21] <= 16'b1000_0000_0000_0001;
        matrix[22] <= 16'b1000_0000_0000_0001;
        matrix[23] <= 16'b1000_0000_0000_0001;
        matrix[24] <= 16'b1000_0000_0000_0001;
        matrix[25] <= 16'b1000_0000_0000_0001;
        matrix[26] <= 16'b1000_0000_0000_0001;
        matrix[27] <= 16'b1000_0000_0000_0001;
        matrix[28] <= 16'b1000_0000_0000_0001;
        matrix[29] <= 16'b1000_0000_0000_0001;
        matrix[30] <= 16'b1000_0000_0000_0001;
        matrix[31] <= 16'b1111_1111_1111_1111;
        #5;

    end

endmodule

module testbench_test();
    logic clk, reset;
    logic [5:0] rgb;
    logic lat, oe;
    logic [2:0] abc;
    logic outclk;

    test dut(clk,reset,rgb,lat,oe,abc,outclk);

    always begin
        clk <= 0; #5;
        clk <= 1; #5;
    end

    initial begin
        reset <= 1; #5;
        reset <= 0; #5;
    end

endmodule