/*
 * HplAtxm256IOPortP.nc
 *
 * HPL IO port access for xmega.
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

generic configuration HplAtxm256IOPortP (uint16_t port_addr)
{
  provides {
    interface HplAtxm256IO as Pin0;
    interface HplAtxm256IO as Pin1;
    interface HplAtxm256IO as Pin2;
    interface HplAtxm256IO as Pin3;
    interface HplAtxm256IO as Pin4;
    interface HplAtxm256IO as Pin5;
    interface HplAtxm256IO as Pin6;
    interface HplAtxm256IO as Pin7;
  }
}
implementation
{
  components 
    new HplAtxm256IOPinP(port_addr, 0) as Bit0,
    new HplAtxm256IOPinP(port_addr, 1) as Bit1,
    new HplAtxm256IOPinP(port_addr, 2) as Bit2,
    new HplAtxm256IOPinP(port_addr, 3) as Bit3,
    new HplAtxm256IOPinP(port_addr, 4) as Bit4,
    new HplAtxm256IOPinP(port_addr, 5) as Bit5,
    new HplAtxm256IOPinP(port_addr, 6) as Bit6,
    new HplAtxm256IOPinP(port_addr, 7) as Bit7;

  Pin0 = Bit0;
  Pin1 = Bit1;
  Pin2 = Bit2;
  Pin3 = Bit3;
  Pin4 = Bit4;
  Pin5 = Bit5;
  Pin6 = Bit6;
  Pin7 = Bit7;
}
