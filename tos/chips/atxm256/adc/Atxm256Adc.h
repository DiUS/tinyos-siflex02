/*
 * Atxm256Adc.h
 *
 * Copied from the atm128 ADC code base and slightly modified.
 * Read the copyright notice below.
 *
 * Copyright 2011 Dius Computing Pty Ltd. All rights reserved.
 */

// $Id: Atm128Adc.h,v 1.6 2010-06-29 22:07:43 scipio Exp $

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

// @author Martin Turon <mturon@xbow.com>
// @author Hu Siquan <husq@xbow.com>

#ifndef _H_Atxm256ADC_h
#define _H_Atxm256ADC_h

#define _BV(bit) (1 << (bit))

// Bit operators using bit number
#define SET_BIT(port, bit)    ((port) |= _BV(bit))
#define CLR_BIT(port, bit)    ((port) &= ~_BV(bit))
#define READ_BIT(port, bit)   (((port) & _BV(bit)) != 0)
#define FLIP_BIT(port, bit)   ((port) ^= _BV(bit))
#define WRITE_BIT(port, bit, value) \
   if (value) SET_BIT((port), (bit)); \
   else CLR_BIT((port), (bit))


/* ADC Control Register A (CTRLA). */
#define ADC_CTRLA _SFR_IO8(0x0200)

/* ADC Control Register A (CTRLB). */
#define ADC_CTRLB _SFR_IO8(0x0201)

/* ADC Reference Control Register. */
#define ADC_REFCTRL _SFR_IO8(0x0202)

/* ADC Event Control Register. */
#define ADC_EVCTRL _SFR_IO8(0x0203)

/* ADC Prescaler Register. */
#define ADC_PRESCALER _SFR_IO8(0x0204)

/* ADC Interrupt flags Register. */
#define ADC_INTFLAGS _SFR_IO8(0x0206)

/* ADC Temp Register. */
#define ADC_REFCTRL _SFR_IO8(0x0202)

/* ADC Calibration Register (Low byte). */
#define ADC_CALL _SFR_IO8(0x020C)

/* ADC Calibration Register (High byte). */
#define ADC_CALH _SFR_IO8(0x020D)

/* ADC Data Register (Low byte; Channel 0). */
#define ADC_CH0RESL _SFR_IO8(0x0210)

/* ADC Data Register (High byte; Channel 0). */
#define ADC_CH0RESH _SFR_IO8(0x0211)

/* ADC Data Register (Low byte; Channel 1). */
#define ADC_CH1RESL _SFR_IO8(0x0212)

/* ADC Data Register (High byte; Channel 1). */
#define ADC_CH1RESH _SFR_IO8(0x0213)

/* ADC Data Register (Low byte; Channel 2). */
#define ADC_CH2RESL _SFR_IO8(0x0214)

/* ADC Data Register (High byte; Channel 2). */
#define ADC_CH2RESH _SFR_IO8(0x0215)

/* ADC Data Register (Low byte; Channel 3). */
#define ADC_CH3RESL _SFR_IO8(0x0216)

/* ADC Data Register (High byte; Channel 3). */
#define ADC_CH3RESH _SFR_IO8(0x0217)

/* ADC Compare Low Register. */
#define ADC_CMPL _SFR_IO8(0x0218)

/* ADC Compare High Register. */
#define ADC_CMPH _SFR_IO8(0x0219)

/* ADC CH0 OFFSET Register. */
#define ADC_CH0_OFFSET _SFR_IO8(0x0220)

/* ADC CH1 OFFSET Register. */
#define ADC_CH1_OFFSET _SFR_IO8(0x0228)

/* ADC CH2 OFFSET Register. */
#define ADC_CH2_OFFSET _SFR_IO8(0x0230)

/* ADC CH3 OFFSET Register. */
#define ADC_CH3_OFFSET _SFR_IO8(0x0238)

/* ADC Channel 0 CTRL Register. */
#define ADC_CHANNEL_0_CTRL _SFR_IO8(0x0220) 

/* ADC Channel 0 MUXCTRL Register. */
#define ADC_CHANNEL_0_MUXCTRL _SFR_IO8(0x0221) 

/* ADC Channel 0 INTCTRL Register. */
#define ADC_CHANNEL_0_INTCTRL _SFR_IO8(0x0222) 

/* ADC Channel 0 INTFLAGS Register. */
#define ADC_CHANNEL_0_INTFLAGS _SFR_IO8(0x0223)

/* ADC Channel 0 RESL Register. */
#define ADC_CHANNEL_0_RESL _SFR_IO8(0x0224)

/* ADC Channel 0 RESH Register. */
#define ADC_CHANNEL_0_RESH _SFR_IO8(0x0225)

/* ADC Channel 1 CTRL Register. */
#define ADC_CHANNEL_1_CTRL _SFR_IO8(0x0228) 

/* ADC Channel 1 MUXCTRL Register. */
#define ADC_CHANNEL_1_MUXCTRL _SFR_IO8(0x0229) 

/* ADC Channel 1 INTCTRL Register. */
#define ADC_CHANNEL_1_INTCTRL _SFR_IO8(0x022A) 

/* ADC Channel 1 INTFLAGS Register. */
#define ADC_CHANNEL_1_INTFLAGS _SFR_IO8(0x022B)

/* ADC Channel 1 RESL Register. */
#define ADC_CHANNEL_1_RESL _SFR_IO8(0x022C)

/* ADC Channel 1 RESH Register. */
#define ADC_CHANNEL_1_RESH _SFR_IO8(0x022D)

/* ADC Channel 2 CTRL Register. */
#define ADC_CHANNEL_2_CTRL _SFR_IO8(0x0230) 

/* ADC Channel 2 MUXCTRL Register. */
#define ADC_CHANNEL_2_MUXCTRL _SFR_IO8(0x0231) 

/* ADC Channel 2 INTCTRL Register. */
#define ADC_CHANNEL_2_INTCTRL _SFR_IO8(0x0232) 

/* ADC Channel 2 INTFLAGS Register. */
#define ADC_CHANNEL_2_INTFLAGS _SFR_IO8(0x0233)

/* ADC Channel 2 RESL Register. */
#define ADC_CHANNEL_2_RESL _SFR_IO8(0x0234)

/* ADC Channel 2 RESH Register. */
#define ADC_CHANNEL_2_RESH _SFR_IO8(0x0235)

/* ADC Channel 3 CTRL Register. */
#define ADC_CHANNEL_3_CTRL _SFR_IO8(0x0238) 

/* ADC Channel 3 MUXCTRL Register. */
#define ADC_CHANNEL_3_MUXCTRL _SFR_IO8(0x0239) 

/* ADC Channel 3 INTCTRL Register. */
#define ADC_CHANNEL_3_INTCTRL _SFR_IO8(0x023A) 

/* ADC Channel 3 INTFLAGS Register. */
#define ADC_CHANNEL_3_INTFLAGS _SFR_IO8(0x023B)

/* ADC Channel 3 RESL Register. */
#define ADC_CHANNEL_3_RESL _SFR_IO8(0x023C)

/* ADC Channel 3 RESH Register. */
#define ADC_CHANNEL_3_RESH _SFR_IO8(0x023D)

/* The ADC calibration registers for Port A. */
#define ADC_ADCACAL0 _SFR_IO8(0x008E0220)//_SFR_IO8(0x01E0); /* Load into CALL Register. */
#define ADC_ADCACAL1 _SFR_IO8(0x008E0221)//_SFR_IO8(0x01E1); /* Load into CALH Register. */

/* ADC Channel 0 CTRLA Register bit names. */
enum
{
   ADC_CTRLA_DMASEL_1 = 7,
   ADC_CTRLA_DMASEL_0 = 6,
   ADC_CTRLA_CH_3 = 5,
   ADC_CTRLA_CH_2 = 4,
   ADC_CTRLA_CH_1 = 3,
   ADC_CTRLA_CH_0 = 2,
   ADC_CTRLA_FLUSH = 1,
   ADC_CTRLA_ENABLE = 0
};

/* ADC CTRLB Register bit names. */
enum
{
   ADC_CTRLB_CONVMODE = 4,
   ADC_CTRLB_FREERUN = 3,
   ADC_CTRLB_RESOLUTION_1 = 2,
   ADC_CTRLB_RESOLUTION_0 = 1
};

/* ADC Channel CTRL Register bit names. */
enum
{
   ADC_CHANNEL_CTRL_GAIN_2 = 4,
   ADC_CHANNEL_CTRL_GAIN_1 = 3,
   ADC_CHANNEL_CTRL_GAIN_0 = 2,
   ADC_CHANNEL_CTRL_INPUTMODE_1 = 1,
   ADC_CHANNEL_CTRL_INPUTMODE_0 = 0,
};

/* ADC Channel MUXCTRL Register bit names. */
enum
{
   ADC_CHANNEL_MUXCTRL_MUXPOS_2 = 5,
   ADC_CHANNEL_MUXCTRL_MUXPOS_1 = 4,
   ADC_CHANNEL_MUXCTRL_MUXPOS_0 = 3
};

/* ADC register offsets. */
enum
{
   ATXM256_ADC_PORTA_OFFSET = 0x0200,
   ATXM256_ADC_PORTB_OFFSET = 0x0240
};

/* ADC REFCTRL Register bit names. */
enum
{
   ADC_REFCTRL_REFSEL_1 = 5,
   ADC_REFCTRL_REFSEL_0 = 4,
   ADC_REFCTRL_BANDGAP = 1,
   ADC_REFCTRL_TEMPREF = 0
};

/* ADC Prescaler Register bit names. */
enum
{
   ADC_PRESCALER_2 = 2,
   ADC_PRESCALER_1 = 1,
   ADC_PRESCALER_O = 0
};

/* ADC CTRL Register bit names. */
enum
{
   ADC_CTRL_START = 7,
   ADC_CTRL_GAIN_2 = 4,
   ADC_CTRL_GAIN_1 = 3,
   ADC_CTRL_GAIN_0 = 2,
   ADC_CTRL_INPUT_MODE_1 = 1,
   ADC_CTRL_INPUT_MODE_0 = 0
};

/* ADC INTCTRL Register bit names. */
enum
{
   ADC_CHANNEL_INTCTRL_INTMODE_1 = 3,
   ADC_CHANNEL_INTCTRL_INTMODE_0 = 2,
   ADC_CHANNEL_INTCTRL_INTLVL_1 = 1,
   ADC_CHANNEL_INTCTRL_INTLVL_0 = 0
};

/* ADC INTFLAGS Register bit names. */
enum
{
   ADC_INTFLAGS_CH3 = 3,
   ADC_INTFLAGS_CH2 = 2,
   ADC_INTFLAGS_CH1 = 1,
   ADC_INTFLAGS_CH0 = 0,
};

/* ADC multiplexer Settings for the Atxm256. */
enum
{
   /* Single-ended inputs. */
   ATXM256_ADC_SNGL_ADC0 = 0,
   ATXM256_ADC_SNGL_ADC1,
   ATXM256_ADC_SNGL_ADC2,
   ATXM256_ADC_SNGL_ADC3,
   ATXM256_ADC_SNGL_ADC4,
   ATXM256_ADC_SNGL_ADC5,
   ATXM256_ADC_SNGL_ADC6,
   ATXM256_ADC_SNGL_ADC7,

   /* TODO: Differential inputs without gain. */

   /* TODO: Differential inputs with gain. */

};

/* Voltage Reference Settings. */
enum
{
   ATXM256_ADC_VREF_INTERNAL_1_00_V = 0, /* VREF = Internal 1.00V. */
   ATXM256_ADC_VREF_INTERNAL_VCC_1_6_V, /* VREF = Internal Vcc/1.6V. */
   ATXM256_ADC_VREF_AREFA, /* VREF = External Port A voltage. */
   ATXM256_ADC_VREF_AREFB /* VREF = External Port B voltage. */
};

/* Voltage Reference Settings */
enum {
    ATXM256_ADC_RIGHT_ADJUST = 0, 
    ATXM256_ADC_LEFT_ADJUST = 1,
};

/* ADC Prescaler Settings */
/* Note: each platform must define ATXM256_ADC_PRESCALE to the smallest
   prescaler which guarantees full A/D precision. */
enum {
    ATXM256_ADC_PRESCALE_4 = 0,
    ATXM256_ADC_PRESCALE_8,
    ATXM256_ADC_PRESCALE_16,
    ATXM256_ADC_PRESCALE_32,
    ATXM256_ADC_PRESCALE_64,
    ATXM256_ADC_PRESCALE_128,
    ATXM256_ADC_PRESCALE_256,
    ATXM256_ADC_PRESCALE_512
};

/* ADC Enable Settings */
enum {
    ATXM256_ADC_ENABLE_OFF = 0,
    ATXM256_ADC_ENABLE_ON,
};

/* ADC Start Conversion Settings */
enum {
    ATXM256_ADC_START_CONVERSION_OFF = 0,
    ATXM256_ADC_START_CONVERSION_ON,
};

/* ADC Free Running Select Settings */
enum {
    ATXM256_ADC_FREE_RUNNING_OFF = 0,
    ATXM256_ADC_FREE_RUNNING_ON,
};

/* ADC Interrupt Flag Settings */
enum {
    ATXM256_ADC_INT_FLAG_OFF = 0,
    ATXM256_ADC_INT_FLAG_ON,
};

/* ADC Interrupt Enable Settings */
enum {
    ATXM256_ADC_INT_ENABLE_OFF = 0,
    ATXM256_ADC_INT_ENABLE_ON,
};

/* ADC conversion mode settings. */
enum
{
   ATXM256_ADC_UNSIGNED_MODE = 0,
   ATXM256_ADC_SIGNED_MODE = 1
};

/* ADC input mode settings. */
enum
{
   ATXM256_ADC_INTERNAL = 0,
   ATXM256_ADC_SINGLE_ENDED = 1,
   ATXM256_ADC_DIFF = 2,
   ATXM256_ADC_DIFFWGAIN = 3
};

/* ADC Resolution Settings. */
enum
{
   ATXM256_ADC_12_BIT_RIGHT_ADJ = 0,
   ATXM256_ADC_8_BIT_RIGHT_ADJ = 2,
   ATXM256_ADC_12_BIT_LEFT_ADJ = 3
};

// The resource identifier string for the ADC subsystem
#define UQ_ATXM256ADC_RESOURCE "atxm256adc.resource" 

#endif //_H_Atxm256ADC_h

