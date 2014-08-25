/*
 * HplAtxm256UsartC0C.nc
 *
 * Hpl USART on port C0.
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

configuration HplAtxm256UsartC0C {
  provides interface HplAtxm256Usart;
  provides interface HplAtxm256Interrupt as TxInt;
  provides interface HplAtxm256Interrupt as DrInt;
  provides interface HplAtxm256Interrupt as RxInt;
}
implementation
{
  components new HplAtxm256UsartP((uint16_t)&USARTC0) as HplUsart,
             HplAtxm256PowerReductionC,
             HplAtxm256UsartInterruptsC0P as UsartInterruptsC0,
             MoteClockC,
             HplAtxm256IOC as HplIO;

  HplAtxm256Usart = HplUsart;
  TxInt = UsartInterruptsC0.TxInt;
  DrInt = UsartInterruptsC0.DrInt;
  RxInt = UsartInterruptsC0.RxInt;

  HplUsart.SystemClock -> MoteClockC;
  HplUsart.Power       -> HplAtxm256PowerReductionC.portc_usart0;
  HplUsart.TxD         -> HplIO.PortC3;
  HplUsart.RxD         -> HplIO.PortC2;
}
