// Daniel Fajardo and Ellie Sundheim
// dfajardo@g.hmc.edu and esundheim.g.hmc.edu
// 11/10/2024

module spi_receive_only(input  logic sck, 
               input  logic sdi,
               output logic sdo,
               input  logic load,
               output logic [15:0] p1, p2
               );
        
    // assert load
    // apply 32 sclks to shift in p1 and p2, starting with MSB of P1
    // then deassert load, wait until done
    // then apply 128 sclks to shift out cyphertext, starting with cyphertext[127]
    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).
    always_ff @(posedge sck)
        if (load)  {p1, p2} = {p1[30:0], p2, sdi}; //shift in from right one bit at a time
        else       {p1, p2} = {p1, p2}; //hold the values while we're done
    
    // sdo should change on the negative edge of sck but we aren't trying to send anything back so we do nothing
    always_ff @(negedge sck) begin
       // wasdone = done;
       //sdodelayed = cyphertextcaptured[126];
    end
    
    assign sdo = 0;
endmodule


// for reference: the original aes_spi from lab 7 that inspired the above module
// aes_spi
//   SPI interface.  Shifts in key and plaintext
//   Captures ciphertext when done, then shifts it out
//   Tricky cases to properly change sdo on negedge clk
module aes_spi(input  logic sck, 
               input  logic sdi,
               output logic sdo,
               input  logic done,
               output logic [127:0] key, plaintext,
               input  logic [127:0] cyphertext);

    logic         sdodelayed, wasdone;
    logic [127:0] cyphertextcaptured;
               
    // assert load
    // apply 256 sclks to shift in key and plaintext, starting with plaintext[127]
    // then deassert load, wait until done
    // then apply 128 sclks to shift out cyphertext, starting with cyphertext[127]
    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).
    always_ff @(posedge sck)
        if (!wasdone)  {cyphertextcaptured, plaintext, key} = {cyphertext, plaintext[126:0], key, sdi};
        else           {cyphertextcaptured, plaintext, key} = {cyphertextcaptured[126:0], plaintext, key, sdi}; // get a head start on the next read in back to back
    
    // sdo should change on the negative edge of sck
    always_ff @(negedge sck) begin
        wasdone = done;
        sdodelayed = cyphertextcaptured[126];
    end
    
    // when done is first asserted, shift out msb before clock edge
    // need to havo sdo ready to go at all times so that when done is 
    // asserted on the posedge sdo can start sending cyphertext on the very next negedge
    assign sdo = (done & !wasdone) ? cyphertext[127] : sdodelayed;
endmodule
