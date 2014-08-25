/*
 * HplAtxm256Adc.nc
 *
 * Copied from the atm128 ADC code base and slightly modified.
 * Read the copyright notice below.
 *
 * Copyright 2011 Dius Computing Pty Ltd. All rights reserved.
 */

/// $Id: HplAtm128Adc.nc,v 1.6 2010-06-29 22:07:43 scipio Exp $

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
 * HPL interface to the Atmega128 A/D conversion subsystem. Please see the
 * Atmega128 manual for full details on the functioning of this subsystem.
 * <p>
 * A word of warning: the Atmega128 SLEEP instruction initiates an A/D
 * conversion when the ADC and ADC interrupt are enabled.
 *
 * @author Martin Turon <mturon@xbow.com>
 * @author Hu Siquan <husq@xbow.com>
 * @author David Gay
 */

interface HplAtxm256Adc {

//interface to use for sensors

  /* Read the current value of a single sensor, in arbitrary, linear units */
  async command int32_t doConversionRaw(uint8_t sensorNumber);

  /* Convert arbitrary units to milliVolts [0...1000+referenceLevelInMV] */
  async command uint16_t rawToMilliVolt(int32_t raw);
  
  /* Convert arbitrary units to microVolts [0...1000000+referenceLevelInUV] */
  async command uint32_t rawToMicroVolt(int32_t raw);
  
  /* Read the current value of a single sensor, in milliVolts, average over "avg" readings
     Convenience function, deprecated! */
  async command uint16_t doConversionUnsigned(uint8_t sensorNumber,uint16_t avg);
  
  /* Get the value (in mV) of the reference */
  async command uint16_t getReferenceLevelmV();
  /* Get the value (in uV) of the reference */
  async command uint32_t getReferenceLeveluV();

  //direct interface to ADC
  /* This function takes a Atxmega256 virtual ADC channel and returns
   * the value in that virtual channel's result register. */
  async command int16_t getValue(uint8_t channel);

  /**
   * Enable ADC sampling
   */
  async command void enableAdc();
  /**
   * Disable ADC sampling
   */
  async command void disableAdc();

  /* Set the conversion mode to signed. */
  async command void setConversionModeSigned();

  /* Set the resolution. */
  async command void setResolution(uint8_t resolution);

  /* Load the calibration values from flash to the registers. */
  async command void loadCalibration();

  /* Set the input mode to single ended. */
  async command void setInputModeDifferential(uint8_t channel);

  /* Set the gain to X1. */
  async command void setGainX1(uint8_t port);

  /* Start a sensor conversion */
  async command void doSensorConversion(uint8_t sensorNumber);

  /* Start a reference conversion. */
  async command void doReferenceConversion();

  /**
   * Start ADC conversion on channel. 
   */
  async command void startConversion(uint8_t channel);

  /**
   * Is ADC enabled?
   * @return TRUE if the ADC is enabled, FALSE otherwise
   */
  async command bool isEnabled();
  
  /**
   * Is A/D conversion complete? 
   * @return TRUE if the A/D conversion is complete, FALSE otherwise
   */
  async command bool isComplete(uint8_t channel);

  /**
   * Set ADC prescaler to 4.
   * @param scale New ADC prescaler. Must be one of the ATXM256_ADC_PRESCALE_xxx
   *   values from Atxm256Adc.h
   */
  async command void setPrescaler4();

  /** 
   * Set ADC voltage reference to 1V
   */
  async command void setReference1V();  
}
