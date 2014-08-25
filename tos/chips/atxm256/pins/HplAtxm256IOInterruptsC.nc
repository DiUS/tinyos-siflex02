/*
 * HplAtxm256IOInterruptsC.nc
 *
 * HPL IO interrupts for xmega.
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

module HplAtxm256IOInterruptsC
{
  provides {
    interface HplAtxm256Interrupt as PortIntC0;
    interface HplAtxm256Interrupt as PortIntC1;
    interface HplAtxm256Interrupt as PortIntD0;
    interface HplAtxm256Interrupt as PortIntD1;
    interface HplAtxm256Interrupt as PortIntE0;
    interface HplAtxm256Interrupt as PortIntE1;
    interface HplAtxm256Interrupt as PortIntF0;
    interface HplAtxm256Interrupt as PortIntF1;
    interface HplAtxm256Interrupt as PortIntR0;
    interface HplAtxm256Interrupt as PortIntR1;
  }
}
implementation
{
  ATXM256_RESET_ISR(PortIntC0, PORTC,
                    INTCTRL, PORT_INT0LVL_LO_gc, PORT_INT0LVL_gm,
                    INTFLAGS, PORT_INT0IF_bm, PORTC_INT0_vect)

  ATXM256_RESET_ISR(PortIntC1, PORTC,
                    INTCTRL, PORT_INT1LVL_LO_gc, PORT_INT1LVL_gm,
                    INTFLAGS, PORT_INT1IF_bm, PORTC_INT1_vect)

  ATXM256_RESET_ISR(PortIntD0, PORTD,
                    INTCTRL, PORT_INT0LVL_LO_gc, PORT_INT0LVL_gm,
                    INTFLAGS, PORT_INT0IF_bm, PORTD_INT0_vect)

  ATXM256_RESET_ISR(PortIntD1, PORTD,
                    INTCTRL, PORT_INT1LVL_LO_gc, PORT_INT1LVL_gm,
                    INTFLAGS, PORT_INT1IF_bm, PORTD_INT1_vect)

  ATXM256_RESET_ISR(PortIntE0, PORTE,
                    INTCTRL, PORT_INT0LVL_LO_gc, PORT_INT0LVL_gm,
                    INTFLAGS, PORT_INT0IF_bm, PORTE_INT0_vect)

  ATXM256_RESET_ISR(PortIntE1, PORTE,
                    INTCTRL, PORT_INT1LVL_LO_gc, PORT_INT1LVL_gm,
                    INTFLAGS, PORT_INT1IF_bm, PORTE_INT1_vect)

  ATXM256_RESET_ISR(PortIntF0, PORTF,
                    INTCTRL, PORT_INT0LVL_LO_gc, PORT_INT0LVL_gm,
                    INTFLAGS, PORT_INT0IF_bm, PORTF_INT0_vect)

  ATXM256_RESET_ISR(PortIntF1, PORTF,
                    INTCTRL, PORT_INT1LVL_LO_gc, PORT_INT1LVL_gm,
                    INTFLAGS, PORT_INT1IF_bm, PORTF_INT1_vect)

  ATXM256_RESET_ISR(PortIntR0, PORTR,
                    INTCTRL, PORT_INT0LVL_LO_gc, PORT_INT0LVL_gm,
                    INTFLAGS, PORT_INT0IF_bm, PORTR_INT0_vect)

  ATXM256_RESET_ISR(PortIntR1, PORTR,
                    INTCTRL, PORT_INT1LVL_LO_gc, PORT_INT1LVL_gm,
                    INTFLAGS, PORT_INT1IF_bm, PORTR_INT1_vect)
}
