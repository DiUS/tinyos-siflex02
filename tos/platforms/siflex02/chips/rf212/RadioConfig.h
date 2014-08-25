/*
 * RadioConfig.h
 * 
 * rf212 radio header for siflex02.
 *
 * Copyright 2011 Dius Computing Pty Ltd. All rights reserved.
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
 * - Neither the name of the copyright holders nor the names of
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

#ifndef __RADIOCONFIG_H__
#define __RADIOCONFIG_H__

#include <Siflex02Timer.h>
#include <RF212DriverLayer.h>
#include <util/crc16.h>

enum
{
	/**
	 * This is the value of the TRX_CTRL_0 register
	 * which configures the output pin currents and the CLKM clock
	 */
	RF212_TRX_CTRL_0_VALUE = 0,

	/**
	 * This is the value of the TRX_CTRL_1 register.
   * PAEXT enables the rf212 to control the siflex02's RF Power Amplifier.
   */
  RF212_TRX_CTRL_1_VALUE = RF212_CTRL_1_MODE_PAEXT_AUTOCRC,

	/**
	 * This is the value of the TRX_CTRL_2 register.
   */
  RF212_TRX_CTRL_2_VALUE = RF212_DATA_MODE_DEFAULT,

  /**
   * RF CTRL 0 register.
   */
  RF212_RF_CTRL_0_VALUE = RF212_RF_CTRL_0_MODE_8USLEAD_0DB,

	/**
	 * This is the default value of the CCA_MODE field in the PHY_CC_CCA register
	 * which is used to configure the default mode of the clear channel assesment
	 */
	RF212_CCA_MODE_VALUE = RF212_CCA_MODE_3,

	/**
	 * This is the value of the CCA_THRES register that controls the
	 * energy levels used for clear channel assesment
	 */
	RF212_CCA_THRES_VALUE = 0xC7,
};

/* This is the default value of the TX_PWR field of the PHY_TX_PWR register. */
#ifndef RF212_DEF_RFPOWER
#define RF212_DEF_RFPOWER	0x0c
#endif

/* This is the default value of the CHANNEL field of the PHY_CC_CCA register. */
#ifndef RF212_DEF_CHANNEL
#define RF212_DEF_CHANNEL	2
#endif

/* The number of microseconds a sending mote will wait for an acknowledgement */
#ifndef SOFTWAREACK_TIMEOUT
#define SOFTWAREACK_TIMEOUT	3500
#endif

/*
 * This is the command used to calculate the CRC for the RF212 chip. 
 * TODO: Check why the default crcByte implementation is in a different endianness
 */
inline uint16_t RF212_CRCBYTE_COMMAND(uint16_t crc, uint8_t data)
{
	return _crc_ccitt_update(crc, data);
}

/**
 * This is the timer type of the radio alarm interface.
 */
typedef TMicro TRadio;
typedef uint32_t tradio_size;

/**
 * The number of radio alarm ticks per one microsecond.
 */
#define RADIO_ALARM_MICROSEC	1L

/**
 * The base two logarithm of the number of radio alarm ticks per one millisecond
 */
#define RADIO_ALARM_MILLI_EXP	10

/**
 * Make PACKET_LINK automaticaly enabled for Ieee154MessageC
 */
#if !defined(TFRAMES_ENABLED) && !defined(PACKET_LINK)
#define PACKET_LINK
#endif

#endif//__RADIOCONFIG_H__
