// STM32L432KC_ADC.h
// Header for ADC functions


#ifndef STM32L4_ADC_H
#define STM32L4_ADC_H

#include <stdint.h>
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void configureADC(void);
void initADC(void);
int calibrateADC(void); 
void readADC(float*);
void readADCchar(char*);

#endif