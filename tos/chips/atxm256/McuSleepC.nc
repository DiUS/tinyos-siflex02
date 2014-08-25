/*
 * McuSleepC.nc
 *
 * ATXMEGA256 sleep implementation as per TEP 112.
 *
 * References: 1. XMEGA A Manual Preliminary 8077H-AVR-12/09
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

module McuSleepC @safe() {
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
  uses {
    interface McuPowerOverride;
  }
}
implementation {
  // Power bits for each power state - see atxm256hardware.h
  const_uint8_t atxm256PowerBits[ATXM256_POWER_DOWN + 1] = {
    SLEEP_SMODE_IDLE_gc,				// idle
    SLEEP_SMODE_PSAVE_gc,       // power saving
    SLEEP_SMODE_PDOWN_gc 		    // power down
  };

  // Work out power state.
  mcu_power_t getPowerState()
  {
    // Timer alarms set.
    if(TCC0.INTCTRLB || TCD0.INTCTRLB || TCE0.INTCTRLB || TCF0.INTCTRLB
    || TCC1.INTCTRLB || TCD1.INTCTRLB || TCE1.INTCTRLB)
    {
      return ATXM256_POWER_IDLE;
    }

    // Usart interrupts set.
#define MCUSLEEP_USART_INTLVL_gm \
(USART_TXCINTLVL_gm | USART_RXCINTLVL_gm | USART_DREINTLVL_gm)
    if((USARTC0.CTRLA & MCUSLEEP_USART_INTLVL_gm)
    || (USARTC1.CTRLA & MCUSLEEP_USART_INTLVL_gm)
    || (USARTD0.CTRLA & MCUSLEEP_USART_INTLVL_gm)
    || (USARTD1.CTRLA & MCUSLEEP_USART_INTLVL_gm)
    || (USARTE0.CTRLA & MCUSLEEP_USART_INTLVL_gm)
    || (USARTE1.CTRLA & MCUSLEEP_USART_INTLVL_gm)
    || (USARTF0.CTRLA & MCUSLEEP_USART_INTLVL_gm))
    {
      return ATXM256_POWER_IDLE;
    }

    // Spi interrupts set.
    if((SPIC.INTCTRL & SPI_INTLVL_gm) || (SPID.INTCTRL & SPI_INTLVL_gm)
    || (SPIE.INTCTRL & SPI_INTLVL_gm) || (SPIF.INTCTRL & SPI_INTLVL_gm))
    {
      return ATXM256_POWER_IDLE;
    }

    // Rtc running.
    if(CLK.RTCCTRL & CLK_RTCEN_bm)
    {
      // Can enter lower power sleep mode if just the RTC is running.
      return ATXM256_POWER_SAVING;
    }

    // Nothing running.
    return ATXM256_POWER_DOWN;
  }

  async command void McuSleep.sleep()
  {
    mcu_power_t powerState;

    // Combine power state with overrides, if any.
    powerState = mcombine(getPowerState(),
                          call McuPowerOverride.lowestState());

    // Set sleep mode corresponding to power state, and set Sleep Enable.
    SLEEP.CTRL = (atxm256PowerBits[powerState] | SLEEP_SEN_bm);

    // Enable interrupts, then sleep, then disable interrupts.
    sei();

    do {
      __asm__ __volatile__ ( "sleep" "\n\t" :: );
    } while(0);

    // Clear Sleep Enable as per [1] p. 98.
    SLEEP.CTRL &= ~SLEEP_SEN_bm;

    cli();
  }

  // Update power state before next sleep.
  async command void McuPowerState.update() 
  { 
    // Do nothing. The power state updates every sleep.
  }

  // Default lowest state is power off.
  default async command mcu_power_t McuPowerOverride.lowestState() 
  {
    return ATXM256_POWER_DOWN;
  }
}
