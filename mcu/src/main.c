// main.c
// Ellie Sundheim esundheim@hmc.edu and Daniel Fajardo dfajardo@hmc.edu
// 10/24/24


#include <stm32l432xx.h>
#include "../lib/STM32L432KC.h"


int main(void){
  // config flash
  configureFlash();
  // config system clock
  configureClock();

  // turn on peripheral clocks (GPIO, ADC, TIM SPI, ...)
  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  RCC->AHB2ENR |= RCC_AHB2ENR_ADCEN;
  RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
  RCC->APB2ENR |= (RCC_APB2ENR_SPI1EN);
  // SPI clock is in SPI init function

  // ADC1_IN10 is the additional function for PA5
  pinMode(PA5, GPIO_ANALOG); // player 1
  pinMode(PA6, GPIO_ANALOG); // player 2

  // Load and done pins
  pinMode(LOAD, GPIO_OUTPUT); //LOAD
  digitalWrite(LOAD, 0);
  pinMode(DONE, GPIO_INPUT); //DONE

  // Artificial chip select signal to allow 8-bit CE-based SPI decoding on the logic analyzers.
  pinMode(PA11, GPIO_OUTPUT);
  digitalWrite(PA11, 1);

  //rest of SPI pins
  pinMode(PB4, GPIO_ALT);
  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL4, 0b0101); //MISO

  pinMode(PB5, GPIO_ALT);
  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL5, 0b0101); //MOSI
  
  pinMode(PB3, GPIO_ALT);
  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL3, 0b0101); //SCK


  //init peripherals
  initTIM(TIM15);
  initSPI(4, 0, 0);
  initADC();

  char* playerDataChar = (char*)malloc(4 * sizeof(char));

  while(1){
  // TODO: modify so that we read the ADC on a timer update event
    readADCchar(playerDataChar);
    
    //digitalWrite(CS, 0);
    //spiSendReceive((char) 0x65);
    //digitalWrite(CS, 1);

    sendPlayerData(playerDataChar);
    delay_millis(TIM15, 1000);

  };


}