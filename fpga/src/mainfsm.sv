// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim@g.hmc.edu
// 11/10/2024
//


module single(input logic [11:0] p1data,
            output logic [5:0] screen);
    logic [11:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15; //threshold voltages for display

    assign t0 = 12'b000000000000; // 0 decimal
    assign t1 = 12'b000011100001; // 0.22 decimal
    assign t2 = 12'b000111000010; // 0.44
    assign t3 = 12'b001010100011; // 0.66
    assign t4 = 12'b001110000101; // 0.88
    assign t5 = 12'b010001100110; // 1.10
    assign t6 = 12'b010101000111; // 1.32
    assign t7 = 12'b011000101000; // 1.54
    assign t8 = 12'b011100010100; // 1.76
    assign t9 = 12'b011111101011; // 1.98
    assign t10 = 12'b100011001100; // 2.20
    assign t11 = 12'b100110101110; // 2.42
    assign t12 = 12'b101010001111; // 2.64
    assign t13 = 12'b101101110000; // 2.86
    assign t14 = 12'b110001010001; // 3.08
    assign t15 = 12'b110100110011; // 3.30
    
    always_comb begin
        if ((p1data>t0)&&(p1data<t1)) screen <= 0;
        else if ((p1data>t1)&&(p1data<t2)) screen <= 1;
        else if ((p1data>t2)&&(p1data<t3)) screen <= 2;
        else if ((p1data>t3)&&(p1data<t4)) screen <= 3;
        else if ((p1data>t4)&&(p1data<t5)) screen <= 4;
        else if ((p1data>t5)&&(p1data<t6)) screen <= 5;
        else if ((p1data>t6)&&(p1data<t7)) screen <= 6;
        else if ((p1data>t7)&&(p1data<t8)) screen <= 7;
        else if ((p1data>t8)&&(p1data<t9)) screen <= 8;
        else if ((p1data>t9)&&(p1data<t10)) screen <= 9;
        else if ((p1data>t10)&&(p1data<t11)) screen <= 10;
        else if ((p1data>t11)&&(p1data<t12)) screen <= 11;
        else if ((p1data>t12)&&(p1data<t13)) screen <= 12;
        else if ((p1data>t13)&&(p1data<t14)) screen <= 13;
        else if ((p1data>t14)&&(p1data<t15)) screen <= 14;
        else screen <= 15;
    end
endmodule

module multi(input logic [11:0] p1data,
            input logic [11:0] p1data,
            input logic clk,
            input logic reset,
            output logic [5:0] screen);
    logic [3:0] state, nextstate;
    logic [11:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15;

    always_ff @(posedge clk)
        if (reset) state <= 7;
        else state <= nextstate;

    // nextstate logic
    always_comb
        case (state)
            0: nextstate <= 0; // player 2 wins, wait for reset
            1: if (p1data>p2data) nextstate <= 2;
                else nextstate <= 0;
            2: if (p1data>p2data) nextstate <= 3;
                else nextstate <= 1;
            3: if (p1data>p2data) nextstate <= 4;
                else nextstate <= 2;
            4: if (p1data>p2data) nextstate <= 5;
                else nextstate <= 3;
            5: if (p1data>p2data) nextstate <= 6;
                else nextstate <= 4;
            6: if (p1data>p2data) nextstate <= 7;
                else nextstate <= 5;
            7: if (p1data>p2data) nextstate <= 8; // start
                else nextstate <= 6;
            8: if (p1data>p2data) nextstate <= 9;
                else nextstate <= 7;
            9: if (p1data>p2data) nextstate <= 10;
                else nextstate <= 8;
            10: if (p1data>p2data) nextstate <= 11;
                else nextstate <= 9;
            11: if (p1data>p2data) nextstate <= 12;
                else nextstate <= 10;
            12: if (p1data>p2data) nextstate <= 13;
                else nextstate <= 11;
            13: if (p1data>p2data) nextstate <= 14;
                else nextstate <= 12;
            14: nextstate <= 14; // player 1 wins, wait for reset
            default: nextstate <= 0;
        endcase
    
    // output logic
    always_comb
        case (state)
            0: screen <= 16;
            1: screen <= 17;
            2: screen <= 18;
            3: screen <= 19;
            4: screen <= 20;
            5: screen <= 21;
            6: screen <= 22;
            7: screen <= 23;
            8: screen <= 24;
            9: screen <= 25;
            10: screen <= 26;
            11: screen <= 27;
            12: screen <= 28;
            13: screen <= 29;
            14: screen <= 30;
            default: screen <= 31;
        endcase
endmodule

module screen(input logic [4:0] screen,
            input logic clk,
            output logic coordinates);

endmodule