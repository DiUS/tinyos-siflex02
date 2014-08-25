/*
 * MoteClockC.nc
 * 
 * Clock configuration for siflex02.
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

#include <avr/io.h>

module MoteClockC {
  provides {
    interface Init;
    interface Atxm256SystemClock;
  }
  uses interface Init as MoteClockInitHook;
}
implementation
{
  // Configure the platform clock.
  command error_t Init.init()
  {
    // Enable external 32kHz crystal and low power mode for the 32kHz.
    OSC.XOSCCTRL = (OSC_X32KLPM_bm | OSC_XOSCSEL1_bm);

    // Enable 32MHz internal oscillator (and therefore disable the 2 MHz
    // internal oscillator).
    OSC.CTRL = (OSC_XOSCEN_bm | OSC_RC32MEN_bm);

    // The ATxmega shall run from its internal 32MHz Oscillator.
    // Set the clock speed to 16MHz. Use internal 32MHz and DFLL.
    while (0 == (OSC.STATUS & OSC_RC32MRDY_bm))
    {
      // Hang until the internal 32MHz Oscillator is stable.
      ;
    }

    CCP = 0xD8;                   // Enable change of protected IO register.
    CLK.PSCTRL = CLK_PSADIV_2_gc; // Use Prescaler A to divide 32MHz clock by 
                                  // 2 to 16MHz system clock.

    CCP = 0xD8;                   // Enable change of protected IO register.
    CLK.CTRL = CLK_SCLKSEL0_bm;   // Set internal 32MHz Oscillator as system 
                                  // clock.

    // Do any special init that must happen before enabling DFLL
    // (such as set CLK.RTCCTRL).
    call MoteClockInitHook.init();

    // Enable DFLL for the external oscillator.
    OSC.DFLLCTRL = OSC_RC32MCREF_bm;
    DFLLRC32M.CTRL |= DFLL_ENABLE_bm;

    return SUCCESS;
  }

  async command uint32_t Atxm256SystemClock.cpuClockHz()
  {
    return 16000000u;
  }

  async command uint32_t Atxm256SystemClock.peripheralClockHz()
  {
    return 16000000u;
  }

  default command error_t MoteClockInitHook.init()
  {
    return SUCCESS;
  }
}
