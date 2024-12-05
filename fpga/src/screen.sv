// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 11/14/2024
//
/*
// test module to manually output rows and columns
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
            if (counter>0 && counter <=30) begin
                if (abcstate==7) begin
                    rgbtopnext <= 3'b001;
                    rgbbotnext <= 3'b001;
                end
                else begin
                    rgbtopnext <= 3'b010;
                    rgbbotnext <= 3'b010;
                end
            end
            else if (counter==0) begin
                rgbtopnext <= 3'b100;
                rgbbotnext <= 3'b100;
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
        assign lat = (counter==maxcount-5);
        assign oe = (counter<maxcount-1);
        assign outclk = clk;
endmodule*/


// module for display interface in single player mode
module singledisplay(input logic [5:0] screen,
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
                barrier[5:1] <= screen[4:0]; // screen will be 0-14 and so barrier should be double that
                barrier[0] <= 1'b0;
            end
            else if (counter==maxcount) begin
                counter <= 0;
                abcstate <= abcnextstate;
                barrier[5:1] <= screen[4:0]; // screen will be 0-14 and so barrier should be double that
                barrier[0] <= 1'b0;
            end
            else begin
                counter <= counter +1;
                abcstate <= abcnextstate;
                barrier[5:1] <= screen[4:0]; // screen will be 0-14 and so barrier should be double that
                barrier[0] <= 1'b0;
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
            else if (counter>0 && counter<31) begin
                if (abcstate==0) begin// light up entire top row green
                    rgbtopnext <= 3'b010;
                    rgbbotnext[2] <= (counter<=barrier); // set pixel in matrix to red
                    rgbbotnext[1:0] <= 2'b00;
                end
                else if (abcstate==7) begin // light up entire bottom row green
                    rgbtopnext[2] <= (counter<=barrier); // set pixel in matrix to red
                    rgbtopnext[1:0] <= 2'b00;
                    rgbbotnext <= 3'b010;
                end
                else if (abcstate==1) begin
                    rgbtopnext <= 3'b000; // keep buffer row 0
                    rgbbotnext[2] <= (counter<=barrier); // set pixel in matrix to red
                    rgbbotnext[1:0] <= 2'b00;
                end
                else if (abcstate==6) begin
                    rgbtopnext[2] <= (counter<=barrier); // set pixel in matrix to red
                    rgbtopnext[1:0] <= 2'b00;
                    rgbbotnext <= 3'b000; // keep buffer row 0
                end
                else begin
                    rgbtopnext[2] <= (counter<=barrier); // set pixel in matrix to red
                    rgbtopnext[1:0] <= 2'b00;
                    rgbbotnext[2] <= (counter<=barrier); // set pixel in matrix to red
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
        assign lat = (counter==maxcount-5);
        assign oe = (counter<maxcount-1);
        assign outclk = clk;
endmodule

// module for display interface in multiplayer mode
module multidisplay(input logic [5:0] screen,
            input logic clk,
            input logic reset,
            output logic [5:0] rgb, // R1,G1,B1,R2,G2,B2
            output logic lat, oe,
            output logic [2:0] abc,
            output logic outclk); // ABC
        logic [2:0] abcstate, abcnextstate;
        logic [2:0] rgbtop,rgbbot,rgbtopnext,rgbbotnext; 
        logic [5:0] counter, barrier;
        logic [31:0] p1wins [15:0], p2wins [15:0], one [15:0], two [15:0], three [15:0], go [15:0];
        logic [20:0] div; // to reduce output frequencies
        parameter maxcount = 36;

        // read text files to memory for preset screens
        initial $readmemb("p1wins.txt",p1wins); // win screen for p1
        initial $readmemb("p2wins.txt",p2wins); // win screen for p2
        initial $readmemb("1.txt",one); // start screen "1"
        initial $readmemb("2.txt",two); // start screen "2"
        initial $readmemb("3.txt",three); // start screen "3"
        initial $readmemb("go.txt",go); // start screen "go"

        // state register
        always_ff @(posedge clk,posedge reset)
            if (reset) begin
                counter <= 0;
                div <= 0;
                abcstate <= 0;
                barrier[4:1] <= screen[3:0]; // screen will be 17-29 and so barrier should be 2(x-16)
                barrier[0] <= 1'b1;
            end
            else if (counter==maxcount) begin
                counter <= 0;
                div <= div +1;
                abcstate <= abcnextstate;
                barrier[4:1] <= screen[3:0]; // screen will be 17-29 and so barrier should be 2(x-16)
                barrier[0] <= 1'b1;
            end
            else begin
                counter <= counter +1;
                div <= div +1;
                abcstate <= abcnextstate;
                barrier[4:1] <= screen[3:0]; // screen will be 17-29 and so barrier should be 2(x-16)
                barrier[0] <= 1'b1;
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
            if (screen>16 && screen<30) begin
                if (counter==0) begin // light up entire first column green
                    rgbtopnext <= 3'b010;
                    rgbbotnext <= 3'b010;
                end
                else if (counter==31) begin // light up entire final column green
                    rgbtopnext <= 3'b010;
                    rgbbotnext <= 3'b010;
                end
                else if (counter>0 && counter<31) begin
                    if (abcstate==0) begin // light up entire top row green
                        rgbtopnext <= 3'b010;
                        rgbbotnext[2] <= (counter<=barrier); // set player 1 red
                        rgbbotnext[1] <= 1'b0;
                        rgbbotnext[0] <= (counter>barrier); // set player 2 blue
                    end
                    else if (abcstate==7) begin // light up entire bottom row green
                        rgbtopnext[2] <= (counter<=barrier); // set player 1 red
                        rgbtopnext[1] <= 1'b0;
                        rgbtopnext[0] <= (counter>barrier); // set player 2 blue
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
                        rgbtopnext[0] <= (counter>barrier); // set player 2 blue
                        rgbbotnext <= 3'b000; // keep buffer row 0
                    end
                    else begin
                        rgbtopnext[2] <= (counter<=barrier); // set player 1 red
                        rgbtopnext[1] <= 1'b0;
                        rgbtopnext[0] <= (counter>barrier); // set player 2 blue
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
            else if (screen==16) begin // alternates flashing p2 win screen top and bottom text at 0.72Hz
                rgbtopnext[0] <= (p2wins[abcstate][31-counter])&(div[20]); // text matrices are inverted until counter is inverted
                rgbtopnext[2:1] <= 2'b00;
                rgbbotnext[0] <= (p2wins[(abcstate+8)][31-counter])&(~div[20]);
                rgbbotnext[2:1] <= 2'b00;
            end
            else if (screen==30) begin // alternates flashing p1 win screen top and bottom text at 0.72Hz
                rgbtopnext[2] <= (p1wins[abcstate][31-counter])&(div[20]);
                rgbtopnext[1:0] <= 2'b00;
                rgbbotnext[2] <= (p1wins[(abcstate+8)][31-counter])&(~div[20]);
                rgbbotnext[1:0] <= 2'b00;
            end
            else if (screen==31) begin // display "go"
                rgbtopnext[2] <= 2'b00;
                rgbtopnext[1] <= (go[abcstate][31-counter]); // text matrices are inverted until counter is inverted
                rgbtopnext[0] <= 2'b00;
                rgbbotnext[2] <= 2'b00;
                rgbbotnext[1] <= (go[(abcstate+8)][31-counter]);
                rgbbotnext[0] <= 2'b00;
            end
            else if (screen==32) begin // display "1"
                rgbtopnext[2] <= (one[abcstate][31-counter]); // text matrices are inverted until counter is inverted
                rgbtopnext[1:0] <= 2'b00;
                rgbbotnext[2] <= (one[(abcstate+8)][31-counter]);
                rgbbotnext[1:0] <= 2'b00;
            end
            else if (screen==33) begin // display "2"
                rgbtopnext[2] <= (two[abcstate][31-counter]); // text matrices are inverted until counter is inverted
                rgbtopnext[1:0] <= 2'b00;
                rgbbotnext[2] <= (two[(abcstate+8)][31-counter]);
                rgbbotnext[1:0] <= 2'b00;
            end
            else if (screen==34) begin // display "3"
                rgbtopnext[2] <= (three[abcstate][31-counter]); // text matrices are inverted until counter is inverted
                rgbtopnext[1:0] <= 2'b00;
                rgbbotnext[2] <= (three[(abcstate+8)][31-counter]);
                rgbbotnext[1:0] <= 2'b00;
            end
            else begin
                rgbtopnext <= 3'b000;
                rgbbotnext <= 3'b000;
            end
        end

        // output logic
        assign abc = abcstate;
        assign rgb = {rgbtop,rgbbot};
        assign lat = (counter==maxcount-5);
        assign oe = (counter<maxcount-1);
        assign outclk = clk;
endmodule