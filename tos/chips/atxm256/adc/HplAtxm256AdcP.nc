/*
 * HplAtxm256AdcP.nc
 *
 * Copied from the atm128 ADC code base and slightly modified.
 * Read the copyright notice below.
 *
 * Copyright 2011 Dius Computing Pty Ltd. All rights reserved.
 */

/// $Id: HplAtm128AdcP.nc,v 1.9 2010-06-29 22:07:43 scipio Exp $
/*
 * Copyright (c) 2004-2005 Crossbow Technology, Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of Crossbow Technology nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * HPL for the Atmega128 A/D conversion susbsystem.
 *
 * @author Martin Turon <mturon@xbow.com>
 * @author Hu Siquan <husq@xbow.com>
 * @author David Gay
 */

#include "Atxm256Adc.h"

#define REFERENCE_UV (500L*1000)

module HplAtxm256AdcP @safe() 
{
  provides interface HplAtxm256Adc;
  uses interface McuPowerState;
}

implementation 
{ 
  static uint16_t doReferenceConversionUnsigned();

  /* This function takes a Atxmega256 virtual ADC channel and returns
   * the value in that virtual channel's result register. */
  async command int16_t HplAtxm256Adc.getValue(uint8_t channel) 
  { 
    atomic {
      switch (channel) {
        case 0: return ADCA.CH0RES; break;
        case 1: return ADCA.CH1RES; break;
        case 2: return ADCA.CH2RES; break;
        case 3: return ADCA.CH3RES; break;
        default: return 0; break;
       }
    }         
  }

  /* This function sets the Atxmega256 ADC clock prescaler to 4. */
  async command void HplAtxm256Adc.setPrescaler4()
  {
    ADC_PRESCALER = 1 << ADC_PRESCALER_DIV4_gc;
  }

  /* This function sets the Atxmega256 ADC reference to the 
   * internal 1.00V bandgap. */
  async command void HplAtxm256Adc.setReference1V()
  {
    /* Hard-coded to internal 1.00V reference. */
    ADC_REFCTRL = 1 << ADC_REFCTRL_BANDGAP;
  }

  /* This function enables the ADC. */
 async command void HplAtxm256Adc.enableAdc() 
 {
    /* Set the ENABLE bit in the CTRLA register and flush the queue. */
    ADC_CTRLA = 1 << ADC_CTRLA_ENABLE;
    ADC_CTRLB = 0;
    ADC_EVCTRL = 0;
    ADC_PRESCALER = 0;
    ADC_INTFLAGS = 0;
    ADC_CMPL = 0;
    ADC_CMPH = 0;

    ADC_CHANNEL_0_CTRL = 0;
    ADC_CHANNEL_0_MUXCTRL = 0;
    ADC_CHANNEL_0_INTCTRL = 0;
    ADC_CHANNEL_0_INTFLAGS = 0;
      
    ADC_CHANNEL_1_CTRL = 0;
    ADC_CHANNEL_1_MUXCTRL = 0;
    ADC_CHANNEL_1_INTCTRL = 0;
    ADC_CHANNEL_1_INTFLAGS = 0;
      
    ADC_CHANNEL_2_CTRL = 0;
    ADC_CHANNEL_2_MUXCTRL = 0;
    ADC_CHANNEL_2_INTCTRL = 0;
    ADC_CHANNEL_2_INTFLAGS = 0;
      
    ADC_CHANNEL_3_CTRL = 0;
    ADC_CHANNEL_3_MUXCTRL = 0;
    ADC_CHANNEL_3_INTCTRL = 0;
    ADC_CHANNEL_3_INTFLAGS = 0;

    /* Update the MCU's power state. */
    call McuPowerState.update();

    /* flush anything in queue */
    SET_BIT(ADC_CTRLA, ADC_CTRLA_FLUSH);

    /* Read in the calibration data to the registers. */
    call HplAtxm256Adc.loadCalibration();

    /* Set the conversion mode to unsigned. */
    call HplAtxm256Adc.setConversionModeSigned();

    /* Set the resolution to 12 bits, right adjusted. */
    call HplAtxm256Adc.setResolution(ATXM256_ADC_12_BIT_RIGHT_ADJ);

    /* Set the voltage reference. */
    call HplAtxm256Adc.setReference1V();

    /* Set the prescaler. */
    call HplAtxm256Adc.setPrescaler4();
  }

  /* This function disables the ADC. */
  async command void HplAtxm256Adc.disableAdc() 
  {
    /* Clear the ENABLE bit in the CTRLA register. */
    CLR_BIT(ADC_CTRLA, ADC_CTRLA_ENABLE); 
 
    /* Update the MCU's power state. */
    call McuPowerState.update();
  }

  /* This function sets the ADC conversion mode to unsigned. */
  async command void HplAtxm256Adc.setConversionModeSigned()
  {
    /* Hard-coded to signed mode. */
    SET_BIT(ADC_CTRLB, ADC_CTRLB_CONVMODE);         
  }

  /* This function sets the ADC resolution and result layout.
   * 12 bit results can either be left or right adjusted, which
   * changes the way in which it is laid out in the two 8-bit result
   * registers. */
  async command void HplAtxm256Adc.setResolution(uint8_t resolution)
  {
    switch (resolution) {
      case ATXM256_ADC_12_BIT_RIGHT_ADJ:
        CLR_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_1);
        CLR_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_0);
        break;
     
      case ATXM256_ADC_8_BIT_RIGHT_ADJ:
        SET_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_1);
        CLR_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_0);
        break;
     
      case ATXM256_ADC_12_BIT_LEFT_ADJ:
        SET_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_1);
        SET_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_0);
        break;
     
      /* The default is 8 bits right adjusted. */
      default:
        CLR_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_1);
        CLR_BIT(ADC_CTRLB, ADC_CTRLB_RESOLUTION_0);
        break;
    }
  }

  /* Load the ADC calibration registers from the signature row. */
  async command void HplAtxm256Adc.loadCalibration()
  {
    atomic {
      NVM_CMD = NVM_CMD_READ_CALIB_ROW_gc;
      ADC_CALL = pgm_read_byte(offsetof(NVM_PROD_SIGNATURES_t, ADCACAL0));
      ADC_CALH = pgm_read_byte(offsetof(NVM_PROD_SIGNATURES_t, ADCACAL1));
      NVM_CMD = NVM_CMD_NO_OPERATION_gc;
    }
  }
 
  /* This function sets the Atxmega256 ADC input mode to differential. */
  async command void HplAtxm256Adc.setInputModeDifferential(uint8_t pin)
  {
    switch(pin) {
      case 0:         
        SET_BIT(ADC_CHANNEL_0_CTRL, ADC_CHANNEL_CTRL_INPUTMODE_1);
        CLR_BIT(ADC_CHANNEL_0_CTRL, ADC_CHANNEL_CTRL_INPUTMODE_0);
        break;

      default:
        SET_BIT(ADC_CHANNEL_1_CTRL, ADC_CHANNEL_CTRL_INPUTMODE_1);
        CLR_BIT(ADC_CHANNEL_1_CTRL, ADC_CHANNEL_CTRL_INPUTMODE_0);
      break;
    }
  }

  /* This function sets the Atxmega256 input gain to X1 (no amplication). */
  async command void HplAtxm256Adc.setGainX1(uint8_t pin)
  {         
    /* Hard-coded to x1. */
    switch(pin) {
    case 0:
      CLR_BIT(ADC_CHANNEL_0_CTRL, ADC_CHANNEL_CTRL_GAIN_2);
      CLR_BIT(ADC_CHANNEL_0_CTRL, ADC_CHANNEL_CTRL_GAIN_1);
      CLR_BIT(ADC_CHANNEL_0_CTRL, ADC_CHANNEL_CTRL_GAIN_0);
      break;

    default:
      CLR_BIT(ADC_CHANNEL_1_CTRL, ADC_CHANNEL_CTRL_GAIN_2);
      CLR_BIT(ADC_CHANNEL_1_CTRL, ADC_CHANNEL_CTRL_GAIN_1);
      CLR_BIT(ADC_CHANNEL_1_CTRL, ADC_CHANNEL_CTRL_GAIN_0);
      break;
    }
  }

  /* This function returns a voltage (in arbitrary units) for a
   * particular sensor. */
  async command int32_t HplAtxm256Adc.doConversionRaw(uint8_t sensorNumber)
  {
    // These measurements are relative (differential) to the reference voltage
    // We do this because differential mode is much more accurate on the XMega
    // line than single-ended mode.
    call HplAtxm256Adc.doSensorConversion(sensorNumber);
    
    while (!call HplAtxm256Adc.isComplete(1))
      ;
    return call HplAtxm256Adc.getValue(1);
  }

  async command uint16_t HplAtxm256Adc.rawToMilliVolt(int32_t raw)
  {
    int32_t mV = (raw/2) - (raw/64) + (raw/256);
    if (mV>1000)
      mV=1000;
    mV+=call HplAtxm256Adc.getReferenceLevelmV();
    if (mV<0)
      mV=0;
    return mV;
  }

  async command uint32_t HplAtxm256Adc.rawToMicroVolt(int32_t raw)
  {
    int32_t uV = raw*489;
    if (uV>1000000)
      uV=1000000;
    uV+=call HplAtxm256Adc.getReferenceLeveluV();
    if (uV<0)
      uV=0;
    return uV;
  }
   
  /* Read the current value of a single sensor, in milliVolts, average over "avg" readings
     Convenience function, deprecated! */
  async command uint16_t HplAtxm256Adc.doConversionUnsigned(uint8_t sensorNumber, uint16_t avg)
  {
    int32_t raw_sum=0;
    uint16_t i;
    
    for (i=0;i<avg;i++)
    {
      raw_sum+=call HplAtxm256Adc.doConversionRaw(sensorNumber);
    }
    raw_sum/=avg;
    return call HplAtxm256Adc.rawToMilliVolt(raw_sum);
  }
  
  /* Get the value (in uV) of the reference */
  async command uint32_t HplAtxm256Adc.getReferenceLeveluV()
  {
    return REFERENCE_UV;
  }

  /* Get the value (in uV) of the reference */
  async command uint16_t HplAtxm256Adc.getReferenceLevelmV()
  {
    return (REFERENCE_UV/1000);
  }

  /* This function starts a Atxm256mega ADC conversion for a particular 
   * SSAdaptor sensor number (1 - 4). */
  async command void HplAtxm256Adc.doSensorConversion(uint8_t sensorNumber)
  {
    /* Start ADC conversion on the port A pin that each sensor is attached to. */
    switch (sensorNumber)
    {
      case 1: call HplAtxm256Adc.startConversion(2); break;
      case 2: call HplAtxm256Adc.startConversion(1); break;
      case 3: call HplAtxm256Adc.startConversion(7); break;
      case 4: call HplAtxm256Adc.startConversion(4); break;
      default: break;
    }
  }

  /* This function starts a Atxm256mega ADC conversion for the voltage 
   * reference. */
  async command void HplAtxm256Adc.doReferenceConversion()
  {
    /* Start the conversion on pin 0 of port A. */
    call HplAtxm256Adc.startConversion(0);
  }

  /* This functions starts a Atxm256mega ADC conversion for a particular
   * pin on Port A of the Atxm256mega. */
  async command void HplAtxm256Adc.startConversion(uint8_t pin) 
  { 
    atomic {
      if (! READ_BIT(ADC_CTRLA, ADC_CTRLA_ENABLE)) {
        call HplAtxm256Adc.enableAdc();
      }

      /* Set the input mode. */
      call HplAtxm256Adc.setInputModeDifferential(pin);

      /* Set the gain. */
      call HplAtxm256Adc.setGainX1(pin);

      switch (pin) {
        case 0:
        default:
          /* Set the input pin as Port A, Pin 0. */
          ADCA.CH0.MUXCTRL = ADC_CH_MUXPOS_PIN0_gc;
          SET_BIT(ADC_CTRLA, ADC_CTRLA_CH_0);
        break;

        case 1:
          /* Set the input pin as Port A, Pin 1. */
          ADCA.CH1.MUXCTRL = ADC_CH_MUXPOS_PIN1_gc;
          SET_BIT(ADC_CTRLA, ADC_CTRLA_CH_1);
        break;

        case 2:
          /* Set the input pin as Port A, Pin 2. */
          ADCA.CH1.MUXCTRL = ADC_CH_MUXPOS_PIN2_gc;
          SET_BIT(ADC_CTRLA, ADC_CTRLA_CH_1);
        break;

        case 4:
          /* Set the input pin as Port A, Pin 4. */
          ADCA.CH1.MUXCTRL = ADC_CH_MUXPOS_PIN4_gc;
          SET_BIT(ADC_CTRLA, ADC_CTRLA_CH_1);
        break;

        case 7:
          /* Set the input pin as Port A, Pin 7. */
          ADCA.CH1.MUXCTRL = ADC_CH_MUXPOS_PIN7_gc;
          SET_BIT(ADC_CTRLA, ADC_CTRLA_CH_1);
        break;
      }
    }
  }

  /* Check to see if the ADC is enabled. */
  async command bool HplAtxm256Adc.isEnabled()     
  {       
    return READ_BIT(ADC_CTRLA, ADC_CTRLA_ENABLE); 
  }
  
  async command bool HplAtxm256Adc.isComplete(uint8_t channel)    
  {
    switch (channel) {
      case 0: return READ_BIT(ADC_INTFLAGS, ADC_INTFLAGS_CH0); break;
      case 1: return READ_BIT(ADC_INTFLAGS, ADC_INTFLAGS_CH1); break;
      case 2: return READ_BIT(ADC_INTFLAGS, ADC_INTFLAGS_CH2); break;
      case 3: return READ_BIT(ADC_INTFLAGS, ADC_INTFLAGS_CH3); break;           
      default: return FALSE; break;
    }
  }
}
