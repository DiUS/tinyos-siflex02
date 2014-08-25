/*
 * HplAtxm256PowerReductionC.nc
 *
 * Provides access to atxmega power reduction registers so
 * modules can be powered on or off.
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

#include <avr/power.h>

module HplAtxm256PowerReductionC
{
  provides {
    interface HplAtxm256OnOff as rtc;

    interface HplAtxm256OnOff as portc_tc0;
    interface HplAtxm256OnOff as portc_tc1;
    interface HplAtxm256OnOff as portd_tc0;
    interface HplAtxm256OnOff as portd_tc1;
    interface HplAtxm256OnOff as porte_tc0;
    interface HplAtxm256OnOff as porte_tc1;
    interface HplAtxm256OnOff as portf_tc0;

    interface HplAtxm256OnOff as portc_usart0;
    interface HplAtxm256OnOff as portc_usart1;
    interface HplAtxm256OnOff as portd_usart0;
    interface HplAtxm256OnOff as portd_usart1;
    interface HplAtxm256OnOff as porte_usart0;
    interface HplAtxm256OnOff as porte_usart1;
    interface HplAtxm256OnOff as portf_usart0;

    interface HplAtxm256OnOff as portc_spi;
    interface HplAtxm256OnOff as portd_spi;
    interface HplAtxm256OnOff as porte_spi;
  }
}
implementation
{
  ATXM256_PR_ONOFF(rtc, PR.PRGEN, PR_RTC_bm)

  ATXM256_PR_ONOFF(portc_tc0, PR.PRPC, PR_TC0_bm)
  ATXM256_PR_ONOFF(portc_tc1, PR.PRPC, PR_TC1_bm)
  ATXM256_PR_ONOFF(portd_tc0, PR.PRPD, PR_TC0_bm)
  ATXM256_PR_ONOFF(portd_tc1, PR.PRPD, PR_TC1_bm)
  ATXM256_PR_ONOFF(porte_tc0, PR.PRPE, PR_TC0_bm)
  ATXM256_PR_ONOFF(porte_tc1, PR.PRPE, PR_TC1_bm)
  ATXM256_PR_ONOFF(portf_tc0, PR.PRPF, PR_TC0_bm)

  ATXM256_PR_ONOFF(portc_usart0, PR.PRPC, PR_USART0_bm)
  ATXM256_PR_ONOFF(portc_usart1, PR.PRPC, PR_USART1_bm)
  ATXM256_PR_ONOFF(portd_usart0, PR.PRPD, PR_USART0_bm)
  ATXM256_PR_ONOFF(portd_usart1, PR.PRPD, PR_USART1_bm)
  ATXM256_PR_ONOFF(porte_usart0, PR.PRPE, PR_USART0_bm)
  ATXM256_PR_ONOFF(porte_usart1, PR.PRPE, PR_USART1_bm)
  ATXM256_PR_ONOFF(portf_usart0, PR.PRPF, PR_USART0_bm)

  ATXM256_PR_ONOFF(portc_spi, PR.PRPC, PR_SPI_bm);
  ATXM256_PR_ONOFF(portd_spi, PR.PRPD, PR_SPI_bm);
  ATXM256_PR_ONOFF(porte_spi, PR.PRPE, PR_SPI_bm);
}
