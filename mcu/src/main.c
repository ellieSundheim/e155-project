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
  RCC->AHB2ENR |= RCC_AHB2ENR_ADCEN;
  RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
  // SPI clock is in SPI init function

  // ADC1_IN10 is the additional function for PA5
  pinMode(PA5, GPIO_ANALOG); // player 1
  pinMode(PA6, GPIO_ANALOG); // player 2

  // Load and done pins
  pinMode(LOAD, GPIO_OUTPUT); //LOAD
  pinMode(DONE, GPIO_INPUT); //DONE

  // Artificial chip select signal to allow 8-bit CE-based SPI decoding on the logic analyzers.
  pinMode(PA11, GPIO_OUTPUT);
  digitalWrite(PA11, 1);

  //init peripherals
  initTIM(TIM15);
  initSPI(1, 0, 0);
  initADC();

  float* playerData = (float*)malloc(2 * sizeof(float));

  while(1){
    readADC(playerData);
    printf("player 1 %f\n", playerData[0]);
    printf("player 2 %f\n", playerData[1]);
    printf("----------------------\n");

  };


}