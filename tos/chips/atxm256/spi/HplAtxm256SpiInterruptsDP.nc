/*
 * HplAtxm256SpiInterruptsDP.nc
 *
 * atxmega SPI interrupts on port D.
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

module HplAtxm256SpiInterruptsDP
{
  provides interface HplAtxm256Interrupt as SpiInt;
}
implementation
{
  inline async command void SpiInt.enable() { 
    SPID.INTCTRL |= SPI_INTLVL_LO_gc; }
  inline async command void SpiInt.disable() { 
    SPID.INTCTRL &= ~SPI_INTLVL_gm;   }
  inline async command bool SpiInt.isEnabled() { 
    return (SPID.INTCTRL & SPI_INTLVL_gm) ? TRUE : FALSE; 
  }
  inline async command void SpiInt.reset() { 
    atomic {
      uint8_t b; b = SPID.STATUS; b = SPID.DATA;
    }
  }
  inline async command bool SpiInt.test() { 
    return (SPID.STATUS & SPI_IF_bm) ? TRUE : FALSE;
  }
  default async event void SpiInt.fired() { }
  AVR_NONATOMIC_HANDLER(SPID_INT_vect) {
    signal SpiInt.fired();
  }
}
