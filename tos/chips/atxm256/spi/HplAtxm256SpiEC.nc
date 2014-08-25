/*
 * HplAtxm256SpiEC.nc
 *
 * HPL SPI on atxmega port E.
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

configuration HplAtxm256SpiEC
{
  provides {
    interface HplAtxm256Spi;
    interface HplAtxm256Interrupt as SpiInt;
  }
}
implementation
{
  components new HplAtxm256SpiP((uint16_t)&SPIE) as HplSpi,
             HplAtxm256SpiInterruptsEP           as SpiInterrupts,
             HplAtxm256IOC                       as IO,
             HplAtxm256PowerReductionC           as Power,
             McuSleepC;

  HplAtxm256Spi = HplSpi;
  SpiInt        = SpiInterrupts;

  HplSpi.ss    -> IO.PortE4; // Slave set line
  HplSpi.mosi  -> IO.PortE5; // Master out, slave in
  HplSpi.miso  -> IO.PortE6; // Master in, slave out
  HplSpi.sck   -> IO.PortE7; // SPI clock line

  HplSpi.Power         -> Power.porte_spi;
  HplSpi.McuPowerState -> McuSleepC;
}
