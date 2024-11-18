// STM32L432KC_SPI.c
// Ellie Sundheim
// esundheim@hmc.edu
// 10-19-24
// Source code for SPI functions

#include "STM32L432KC.h"
#include "STM32L432KC_SPI.h"

void initSPI(int br, int cpol, int cpha){

  //disable spi
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_SPE, 0);

  //set baud rate
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_BR , br);
  
  //set clock phase, polarity
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPOL, cpol);
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPHA, cpha);

  //configure lsbfirst bit (optional)
  SPI1->CR1 &= ~(SPI_CR1_LSBFIRST);

  //configure ssm and ssi
  SPI1->CR1 &= ~(SPI_CR1_SSM); //set to 1 to manage via software, 0 to manage via hardware
  //SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSI, 0); //set chip select to 0 to start

  //configure mstr bit
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_MSTR, 1); //set up mcu as master

  //configure ds[3:0] to select data length
  SPI1->CR2 |= _VAL2FLD(SPI_CR2_DS, 0b0111); //default to 8 bit data

  // 8 bit data so adjust fifo
  SPI1->CR2 |= _VAL2FLD(SPI_CR2_FRXTH, 1);

  //configure ss output enable
  SPI1->CR2 |= _VAL2FLD(SPI_CR2_SSOE, 1); //enable ss output

  //re-enable spi
  SPI1->CR1 |= _VAL2FLD(SPI_CR1_SPE, 1);

}


char spiSendReceive(char send){
  //turn on cs
  //SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSI , 1);
  //digitalWrite(PB0, 1);

  //wait until we can transmit (transmit buffer empty when 1)
  while( !( (SPI1->SR & SPI_SR_TXE_Msk) >> SPI_SR_TXE_Pos));

  //in order to send 8 bits without pre-pending with 8 zeros, we need to get an 8 bit pointer to the DR register (which is 16 bits)
  //volatile uint16_t* DR16 = (uint16_t *) &SPI1->DR;
  //volatile uint8_t* DR8 = (uint8_t *) DR16;

  //send char (SPI1->DR = send;)
  //*DR8 = send;

  //SPI1->DR = send;
  *(volatile char *) (&SPI1->DR) = send;
  
  //wait until we're done transmitting and receive buffer is empty (receive buffer not empty when 1)
  //while( (SPI1->SR | SPI_CR2_RXNEIE_Msk) & 1);
  while ( !( (SPI1->SR & SPI_SR_RXNE_Msk) >> SPI_SR_RXNE_Pos) );

  //turn off cs
  //SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSI, 0);
 // digitalWrite(PB0, 0);

  //return received char
  return *(volatile char *) (&SPI1->DR);


};


// function to send 24 bits to FPGA
void sendPlayerData(char* playerDataChar) {
  int i;

  // Write LOAD high
  digitalWrite(LOAD, 1);

  // Send data in order MSB 1, LSB 1, MSB 2, LSB 2
  for(i = 0; i < 4; i++) {
    digitalWrite(CS, 1); // Arificial CE high
    spiSendReceive(playerDataChar[i]);
    digitalWrite(CS, 0); // Arificial CE low
  }

  while(SPI1->SR & SPI_SR_BSY); // Confirm all SPI transactions are completed
  digitalWrite(LOAD, 0); // Write LOAD low

  // Wait for DONE signal to be asserted by FPGA signifying that the data is ready to be read out.
  while(!digitalRead(DONE));
}

