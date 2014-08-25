/*
 * HplAtxm256IOC.nc
 *
 * HPL IO on all atxmega256 pins.
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

configuration HplAtxm256IOC
{
  provides {
    interface HplAtxm256IO as PortA0;
    interface HplAtxm256IO as PortA1;
    interface HplAtxm256IO as PortA2;
    interface HplAtxm256IO as PortA3;
    interface HplAtxm256IO as PortA4;
    interface HplAtxm256IO as PortA5;
    interface HplAtxm256IO as PortA6;
    interface HplAtxm256IO as PortA7;

    interface HplAtxm256IO as PortB0;
    interface HplAtxm256IO as PortB1;
    interface HplAtxm256IO as PortB2;
    interface HplAtxm256IO as PortB3;
    interface HplAtxm256IO as PortB4;
    interface HplAtxm256IO as PortB5;
    interface HplAtxm256IO as PortB6;
    interface HplAtxm256IO as PortB7;

    interface HplAtxm256IO as PortC0;
    interface HplAtxm256IO as PortC1;
    interface HplAtxm256IO as PortC2;
    interface HplAtxm256IO as PortC3;
    interface HplAtxm256IO as PortC4;
    interface HplAtxm256IO as PortC5;
    interface HplAtxm256IO as PortC6;
    interface HplAtxm256IO as PortC7;

    interface HplAtxm256IO as PortD0;
    interface HplAtxm256IO as PortD1;
    interface HplAtxm256IO as PortD2;
    interface HplAtxm256IO as PortD3;
    interface HplAtxm256IO as PortD4;
    interface HplAtxm256IO as PortD5;
    interface HplAtxm256IO as PortD6;
    interface HplAtxm256IO as PortD7;

    interface HplAtxm256IO as PortE0;
    interface HplAtxm256IO as PortE1;
    interface HplAtxm256IO as PortE2;
    interface HplAtxm256IO as PortE3;
    interface HplAtxm256IO as PortE4;
    interface HplAtxm256IO as PortE5;
    interface HplAtxm256IO as PortE6;
    interface HplAtxm256IO as PortE7;

    interface HplAtxm256IO as PortF0;
    interface HplAtxm256IO as PortF1;
    interface HplAtxm256IO as PortF2;
    interface HplAtxm256IO as PortF3;
    interface HplAtxm256IO as PortF4;
    interface HplAtxm256IO as PortF5;
    interface HplAtxm256IO as PortF6;
    interface HplAtxm256IO as PortF7;
    interface HplAtxm256IO as PortR0;
    interface HplAtxm256IO as PortR1;
  }
}
implementation
{
  components 
    new HplAtxm256IOPortP((uint16_t)&PORTA) as PortA,
    new HplAtxm256IOPortP((uint16_t)&PORTB) as PortB,
    new HplAtxm256IOPortP((uint16_t)&PORTC) as PortC,
    new HplAtxm256IOPortP((uint16_t)&PORTD) as PortD,
    new HplAtxm256IOPortP((uint16_t)&PORTE) as PortE,
    new HplAtxm256IOPortP((uint16_t)&PORTF) as PortF;

  components
    new HplAtxm256IOPinP((uint16_t)&PORTR, 0) as PortRPin0,
    new HplAtxm256IOPinP((uint16_t)&PORTR, 1) as PortRPin1;

  PortA0 = PortA.Pin0;
  PortA1 = PortA.Pin1;
  PortA2 = PortA.Pin2;
  PortA3 = PortA.Pin3;
  PortA4 = PortA.Pin4;
  PortA5 = PortA.Pin5;
  PortA6 = PortA.Pin6;
  PortA7 = PortA.Pin7;

  PortB0 = PortB.Pin0;
  PortB1 = PortB.Pin1;
  PortB2 = PortB.Pin2;
  PortB3 = PortB.Pin3;
  PortB4 = PortB.Pin4;
  PortB5 = PortB.Pin5;
  PortB6 = PortB.Pin6;
  PortB7 = PortB.Pin7;

  PortC0 = PortC.Pin0;
  PortC1 = PortC.Pin1;
  PortC2 = PortC.Pin2;
  PortC3 = PortC.Pin3;
  PortC4 = PortC.Pin4;
  PortC5 = PortC.Pin5;
  PortC6 = PortC.Pin6;
  PortC7 = PortC.Pin7;

  PortD0 = PortD.Pin0;
  PortD1 = PortD.Pin1;
  PortD2 = PortD.Pin2;
  PortD3 = PortD.Pin3;
  PortD4 = PortD.Pin4;
  PortD5 = PortD.Pin5;
  PortD6 = PortD.Pin6;
  PortD7 = PortD.Pin7;

  PortE0 = PortE.Pin0;
  PortE1 = PortE.Pin1;
  PortE2 = PortE.Pin2;
  PortE3 = PortE.Pin3;
  PortE4 = PortE.Pin4;
  PortE5 = PortE.Pin5;
  PortE6 = PortE.Pin6;
  PortE7 = PortE.Pin7;

  PortF0 = PortF.Pin0;
  PortF1 = PortF.Pin1;
  PortF2 = PortF.Pin2;
  PortF3 = PortF.Pin3;
  PortF4 = PortF.Pin4;
  PortF5 = PortF.Pin5;
  PortF6 = PortF.Pin6;
  PortF7 = PortF.Pin7;

  PortR0 = PortRPin0;
  PortR1 = PortRPin1;
}
