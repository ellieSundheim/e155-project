// STM32L432KC_ADC.c
// Source code for ADC functions

#include <stm32l432xx.h>
#include <math.h>
#include <stdio.h>
#include "STM32L432KC_ADC.h"
#include "STM32L432KC_TIM.h"
#include "STM32L432KC_GPIO.h"

float dcOffsets[2] = {0,0};

void initADC(void){
  
  // set up clocks
  RCC->CCIPR |= _VAL2FLD(RCC_CCIPR_ADCSEL, 0b11); //11 -> system clock is selected as ADC clock
  RCC->CFGR &= ~(RCC_CFGR_HPRE); // must use AHB prescaler = 1
  
  // select ADC clock and prescale
  // CKMODE to 0b00 -> ADC uses system clock of 80 MHz
  ADC1_COMMON->CCR |= _VAL2FLD(ADC_CCR_CKMODE, 0b00);
  ADC1_COMMON->CCR | _VAL2FLD(ADC_CCR_PRESC, 4); //divides by 2^value


  // calibrate ADC
  //calibrateADC();
  
  // disable ADC
  ADC1->CR &= ~ADC_CR_ADEN;
  //deep pwr save mode off and adc voltage regulator on (must wait for t_adcvreg_setup)
  ADC1->CR &= ~ADC_CR_DEEPPWD;
  ADC1->CR |= ADC_CR_ADVREGEN; // must happen before enabling adc or calibration
  delay_millis(TIM15, 1);

  //enable vrefint in ccr to have internal voltage reference
  ADC1_COMMON->CCR |= ADC_CCR_VREFEN;

  // can choose resolution by setting RES[1:0] 00 = 12 bit, 01 = 10 bit, 10 = 8 bit
  ADC1->CFGR &= ~(ADC_CFGR_RES);
  // turn off continuous conversion mode CONT = 0
  ADC1->CFGR &= ~ADC_CFGR_CONT;
  // right align data ALIGN = 0
  ADC1->CFGR &= ~ADC_CFGR_ALIGN;

  
  // set up conversion sequence 
  ADC1->SQR1 |= _VAL2FLD(ADC_SQR1_L, 2); // set length of sequence to 2
  ADC1->SQR1 |= _VAL2FLD(ADC_SQR1_SQ1, 10); // set to read channel 10 (PA5)
  ADC1->SQR1 |= _VAL2FLD(ADC_SQR1_SQ2, 11); // set to read channel 11 (PA6)

  // sample channels for 24.5 ADC clock cycles
  // slow channels need 0.2 microseconds to read -> 
  // at systemclock freq of 16 MHz, a clock cycle is 0.06 microseconds 
  // which is 3.2 clock cycles
  ADC1->SMPR2 |= _VAL2FLD(ADC_SMPR2_SMP10, 3);
  ADC1->SMPR2 |= _VAL2FLD(ADC_SMPR2_SMP11, 3);

  // interrupts

  // clear ready bit by writing 1
  ADC1->ISR |= (ADC_ISR_ADRDY);
  //enable
  ADC1->CR |= ADC_CR_ADEN;
  //wait until ADC is ready
  while( !(ADC1->ISR & ADC_ISR_ADRDY) );
  // clear ready bit by writing 1
  ADC1->ISR |= (ADC_ISR_ADRDY);


}


// calibrateADC 
int calibrateADC(void){
  
  //deep pwr save mode off and v ref internal on (must wait for t_adcvreg_setup)
  ADC1->CR &= ~ADC_CR_DEEPPWD;
  ADC1->CR |= ADC_CR_ADVREGEN;
  delay_millis(TIM15, 1);

  // disable ADC
  ADC1->CR &= ~ADC_CR_ADEN;

  // single sided input -> set ALCALDIF = 0
  ADC1->CR &= ~ADC_CR_ADCALDIF;

  // start calibration
  ADC1->CR |= ADC_CR_ADCAL;

  // wait for device to finish calibration (wait for ADCAL to go to 0)
  while ( ((ADC1->CR & ADC_CR_ADCAL_Msk) >> ADC_CR_ADCAL_Pos) & 1);

  // read calibration factor
  volatile int cf = (ADC1->CALFACT & ADC_CALFACT_CALFACT_S);

  int cf1 = cf +1; //prevent optimization away

  return cf;



}


void readADC(float* playerData){
  // float is 32 bits so can store our 12 bit max res readings

  // start the conversion
  ADC1->CR |= ADC_CR_ADSTART;

  // wait for end of first conversion (EOC will be 1, cleared by software or reading ADC->DR)
  while ( !(ADC1->ISR & ADC_ISR_EOC) );

  // read first channel, clear the EOC bit and allows us to read next channel
  volatile float ch10 = ADC1->DR;
  //printf("ADC Input 10: %f\n", ch10); 
  playerData[0] = ch10; 

  // wait to read next
  while ( !(ADC1->ISR & ADC_ISR_EOC) );
  // read ch6
  volatile float ch11 = ADC1->DR;
  //printf("ADC Input 11: %f\n", ch11);
  playerData[1] = ch11;

  // clear end of sequence bit
  ADC1->ISR |= ADC_ISR_EOS;

  volatile float ch_v = ch10 * 3.3 / pow(2, 12);

  //return nothing because pointer modifies in place

}


void calculateOffsets(void){
  // read for 20 cycles
  float ch10offset = 0;
  float ch11offset = 0;

  for (int i = 0; i <20; i++){
      readADC(dcOffsets);
      ch10offset += dcOffsets[0];
      ch11offset += dcOffsets[1];
  }

  // set offset as 20 cycle average
  dcOffsets[0] = ch10offset/10.0;
  dcOffsets[1] = ch11offset/20.0;
}

void readADCchar(char* playerDataChar){
  // float is 32 bits so can store our 12 bit max res readings

  // start the conversion
  ADC1->CR |= ADC_CR_ADSTART;

  // wait for end of first conversion (EOC will be 1, cleared by software or reading ADC->DR)
  while ( !(ADC1->ISR & ADC_ISR_EOC) );



  // read first channel, clear the EOC bit and allows us to read next channel
  volatile uint16_t ch10 = ADC1->DR;

  // wait to read next
  while ( !(ADC1->ISR & ADC_ISR_EOC) );

  // read ch6
  volatile uint16_t ch11 = ADC1->DR;

  // clear end of sequence bit
  ADC1->ISR |= ADC_ISR_EOS;

  // adjust raw values by subtracting offsets
  //ch10 -= dcOffsets[0];
  //ch11 -= dcOffsets[1];

  // convert each int to 2 chars and store in char array
  playerDataChar[0] = (char) ((ch10 >> 8) & 0xFF); // upper 8 bits 
  playerDataChar[1] = (char) (ch10 & 0xFF); // lower 8 bits
  playerDataChar[2] = (char) ((ch11 >> 8) & 0xFF); // upper 8 bits 
  playerDataChar[3] = (char) (ch11 & 0xFF); // lower 8 bits
  
  //printf("p2 upper: %d\n", playerDataChar[2]);
  //printf("p2 lower: %d\n", playerDataChar[3]);


  //return nothing because pointer modifies in place
}

void ADC1_IRQnHandler(void){
  
}

