// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 11/14/2024
//

module test(input logic clk,
            input logic reset,
            output logic [5:0] rgb, // R1,G1,B1,R2,G2,B2
            output logic lat, oe,
            output logic [2:0] abc,
            output logic outclk); // ABC
        logic [2:0] abcstate, abcnextstate;
        logic [2:0] rgbtop,rgbbot,rgbtopnext,rgbbotnext; 
        logic [5:0] counter;
        parameter maxcount = 36;

        // state register
        always_ff @(posedge clk,posedge reset)
            if (reset) begin
                counter <= 0;
                abcstate <= 0;
            end
            else if (counter==maxcount) begin
                counter <= 0;
                abcstate <= abcnextstate;
            end
            else begin
                counter <= counter + 1;
                abcstate <= abcnextstate;
            end
        always_ff @(negedge clk,posedge reset)
            if (reset) begin
                rgbtop <= 0;
                rgbbot <= 0;
            end
            else begin
                rgbtop <= rgbtopnext;
                rgbbot <= rgbbotnext;
            end
    
        // nextstate logic
        assign abcnextstate = (counter==maxcount) ? abcstate+1 : abcstate;

        always_comb
            if (counter>=0 && counter <=30) begin
                rgbtopnext <= 3'b010;
                rgbbotnext <= 3'b010;
            end
            else if (counter==31) begin
                rgbtopnext <= 3'b100;
                rgbbotnext <= 3'b100;
            end
            else begin
                rgbtopnext <= 3'b000;
                rgbbotnext <= 3'b000;
            end

        // output logic
        assign abc = abcstate;
        assign rgb = {rgbtop,rgbbot};
        assign lat = (counter==maxcount-3);
        assign oe = (counter<maxcount-4);
        assign outclk = clk;
/*        assign lat = (counter==maxcount-2);
        assign oe = (counter==maxcount-1);*/
endmodule

module test_single_row(input logic clk,
                       input logic reset,
                       output logic [5:0] rgb, 
                       output logic lat, oe, 
                       output logic [2:0] abc, 
                       output logic outclk);
    logic [5:0] counter;

    always_ff @(posedge clk or posedge reset)
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;

    assign rgb = (counter < 10) ? 6'b111111 : 6'b000000; // Turn on all colors briefly
    assign lat = (counter == 10); // Latch row
    assign oe = ~(counter < 20); // Enable output
    assign abc = 3'b000;         // Row 0
    assign outclk = clk;
endmodule

/*
module creatematrix(input logic [5:0] screen,
            input logic clk,
            output logic [31:0] matrix [15:0]);
        logic [31:0] screen0 [15:0],screen1 [15:0],screen2 [15:0],screen3 [15:0],
                    screen4 [15:0],screen5 [15:0],screen6 [15:0],screen7 [15:0],
                    screen8 [15:0],screen9 [15:0],screen10 [15:0],screen11 [15:0],
                    screen12 [15:0],screen13 [15:0],screen14 [15:0],screen15 [15:0];
        
        initial $readmemb("screen0",screen0);
        initial $readmemb("screen1",screen1);
        initial $readmemb("screen2",screen2);
        initial $readmemb("screen3",screen3);
        initial $readmemb("screen4",screen4);
        initial $readmemb("screen5",screen5);
        initial $readmemb("screen6",screen6);
        initial $readmemb("screen7",screen7);
        initial $readmemb("screen8",screen8);
        initial $readmemb("screen9",screen9);
        initial $readmemb("screen10",screen10);
        initial $readmemb("screen11",screen11);
        initial $readmemb("screen12",screen12);
        initial $readmemb("screen13",screen13);
        initial $readmemb("screen14",screen14);
        initial $readmemb("screen15",screen15);

        always_comb
            case (screen)
                0: matrix <= screen0;
                1: matrix <= screen1;
                2: matrix <= screen2;
                3: matrix <= screen3;
                4: matrix <= screen4;
                5: matrix <= screen5;
                6: matrix <= screen6;
                7: matrix <= screen7;
                8: matrix <= screen8;
                9: matrix <= screen9;
                10: matrix <= screen10;
                11: matrix <= screen11;
                12: matrix <= screen12;
                13: matrix <= screen13;
                14: matrix <= screen14;
                15: matrix <= screen15;
                default: matrix <= '{default: 0};

            endcase

endmodule*/

/*
module displayinterface(input logic [5:0] screen,
            input logic clk,
            input logic reset,
            output logic [5:0] rgb, // R1,G1,B1,R2,G2,B2
            output logic lat, oe,
            output logic [2:0] abc, // ABC
            output logic outclk);
        logic [2:0] abcstate, abcnextstate;
        logic [2:0] rgbtop,rgbbot,rgbtopnext,rgbbotnext; 
        logic [5:0] counter, barrier;
        parameter maxcount = 36;

        // state register
        always_ff @(posedge clk,posedge reset)
            if (reset) begin
                counter <= 0;
                abcstate <= 0;
                barrier[5:1] <= screen[4:0]; // screen will be 0-15 and so barrier should be double that
                barrier[0] <= 1'b0;
            end
            else if (counter==maxcount) begin
                counter <= 0;
                abcstate <= abcnextstate;
            end
            else begin
                counter <= counter +1;
                abcstate <= abcnextstate;
            end
        always_ff @(negedge clk,posedge reset)
            if (reset) begin
                rgbtop <= 0;
                rgbbot <= 0;
            end
            else begin
                rgbtop <= rgbtopnext;
                rgbbot <= rgbbotnext;
            end

        // nextstate logic
        assign abcnextstate = (counter==maxcount) ? abcstate+1 : abcstate;

        always_comb begin
            if (counter==0) begin// light up entire first column green
                rgbtopnext <= 3'b010;
                rgbbotnext <= 3'b010;
            end
            else if (counter==31) begin// light up entire final column green
                rgbtopnext <= 3'b010;
                rgbbotnext <= 3'b010;
            end
            else if (counter>0 && counter <31) begin
                if (abcstate==0) begin// light up entire top row green
                    rgbtopnext <= 3'b010;
                    rgbbotnext[2] <= (counter<barrier); // set pixel in matrix to red
                    rgbbotnext[1:0] <= 2'b00;
                end
                else if (abcstate==7) begin // light up entire bottom row green
                    rgbtopnext[2] <= (counter<barrier); // set pixel in matrix to red
                    rgbtopnext[1:0] <= 2'b00;
                    rgbbotnext <= 3'b010;
                end
                else if (abcstate==1) begin
                    rgbtopnext <= 3'b000; // keep buffer row 0
                    rgbbotnext[2] <= (counter<barrier); // set pixel in matrix to red
                    rgbbotnext[1:0] <= 2'b00;
                end
                else if (abcstate==6) begin
                    rgbtopnext[2] <= (counter<barrier); // set pixel in matrix to red
                    rgbtopnext[1:0] <= 2'b00;
                    rgbbotnext <= 3'b000; // keep buffer row 0
                end
                else begin
                    rgbtopnext[2] <= (counter<barrier); // set pixel in matrix to red
                    rgbtopnext[1:0] <= 2'b00;
                    rgbbotnext[2] <= (counter<barrier); // set pixel in matrix to red
                    rgbbotnext[1:0] <= 2'b00;
                end
            end
            else begin
                rgbtopnext <= 3'b000;
                rgbbotnext <= 3'b000;
            end
        end

        // output logic
        assign abc = abcstate;
        assign rgb = {rgbtop,rgbbot};
        assign lat = (counter==maxcount-2);
        assign oe = (counter==maxcount-1);
        assign outclk = clk;


endmodule

module multidisplayinterface(input logic [5:0] screen,
            input logic clk,
            input logic reset,
            output logic [5:0] rgb, // R1,G1,B1,R2,G2,B2
            output logic lat, oe,
            output logic [2:0] abc); // ABC
        logic [2:0] abcstate, abcnextstate;
        logic [2:0] rgbtop,rgbbot,rgbtopnext,rgbbotnext; 
        logic [5:0] counter, barrier;
        parameter maxcount = 36;

        // state register
        always_ff @(posedge clk,posedge reset)
            if (reset) begin
                counter <= 0;
                abcstate <= 0;
                barrier[5:1] <= screen[4:0]; // screen will be 16-31 and so barrier should be 2(x-16)
                barrier[0] <= 1'b0;
            end
            else if (counter==maxcount) begin
                counter <= 0;
                abcstate <= abcnextstate;
            end
            else begin
                counter <= counter +1;
                abcstate <= abcnextstate;
            end
        always_ff @(negedge clk,posedge reset)
            if (reset) begin
                rgbtop <= 0;
                rgbbot <= 0;
            end
            else begin
                rgbtop <= rgbtopnext;
                rgbbot <= rgbbotnext;
            end

        // nextstate logic
        assign abcnextstate = (counter==maxcount) ? abcstate+1 : abcstate;
        always_comb begin
            if (counter==0) begin // light up entire first column green
                rgbtopnext <= 3'b010;
                rgbbotnext <= 3'b010;
            end
            else if (counter==31) begin // light up entire final column green
                rgbtopnext <= 3'b010;
                rgbbotnext <= 3'b010;
            end
            else if (counter>1 && counter<30) begin
                if (abcstate==0) begin // light up entire top row green
                    rgbtopnext <= 3'b010;
                    rgbbotnext[2] <= (counter<=barrier); // set player 1 red
                    rgbbotnext[1] <= 1'b0;
                    rgbbotnext[0] <= (counter>barrier); // set player 2 blue
                end
                else if (abcstate==7) begin // light up entire bottom row green
                    rgbtopnext[2] <= (counter<=barrier); // set player 1 red
                    rgbtopnext[1] <= 1'b0;
                    rgbtopnext[0] <= (cointer>barrier); // set player 2 blue
                    rgbbotnext <= 3'b010;
                end
                else if (abcstate==1) begin
                    rgbtopnext <= 3'b000; // keep buffer row 0
                    rgbbotnext[2] <= (counter<=barrier); // set player 1 red
                    rgbbotnext[1] <= 1'b0;
                    rgbbotnext[0] <= (counter>barrier); // set player 2 blue
                end
                else if (abcstate==6) begin
                    rgbtopnext[2] <= (counter<=barrier); // set player 1 red
                    rgbtopnext[1] <= 1'b0;
                    rgbtopnext[0] <= (cointer>barrier); // set player 2 blue
                    rgbbotnext <= 3'b000; // keep buffer row 0
                end
                else begin
                    rgbtopnext[2] <= (counter<=barrier); // set player 1 red
                    rgbtopnext[1] <= 1'b0;
                    rgbtopnext[0] <= (cointer>barrier); // set player 2 blue
                    rgbbotnext[2] <= (counter<=barrier); // set player 1 red
                    rgbbotnext[1] <= 1'b0;
                    rgbbotnext[0] <= (counter>barrier); // set player 2 blue
                end
            end
            else begin
                rgbtopnext <= 3'b000;
                rgbbotnext <= 3'b000;
            end
        end

        // output logic
        assign abc = abcstate;
        assign rgb = {rgbtop,rgbbot};
        assign lat = (counter==maxcount-2);
        assign oe = (counter==maxcount-1);
endmodule*/