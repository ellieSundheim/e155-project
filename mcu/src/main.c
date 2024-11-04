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
  pinMode(PA5, GPIO_ANALOG);

  //init peripherals
  initTIM(TIM15);
  //initSPI(int br, int cpol, int cpha);
  initADC();


  volatile float adc_ch_5_voltage = 0;
  while(1){
    adc_ch_5_voltage = readADC();
    printf("ADC Input 5: %f\n", adc_ch_5_voltage);

  };


}