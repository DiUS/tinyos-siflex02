/*
 * HplAtxm256TimerD0C.nc
 *
 * atxmega timer D0.
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

configuration HplAtxm256TimerD0C
{
  provides {
    interface StdControl;
    interface HplAtxm256TimerControl     as TimerControl;
    interface HplAtxm256Counter          as Counter;
    interface HplAtxm256CaptureCompare   as CaptureCompare[uint8_t id];
  }
}
implementation
{
  components new HplAtxm256Timer0P((uint16_t)(&TCD0)) as Timer,
             HplAtxm256TimerInterruptC as TimerInterrupts,
             HplAtxm256PowerReductionC as Power;

  StdControl        =  Timer;
  TimerControl      =  Timer;
  Counter           =  Timer;
  CaptureCompare    =  Timer;

  Timer.Power       -> Power.portd_tc0;

  Timer.OverflowInt -> TimerInterrupts.tcd0_ovf;
  Timer.CCIntA      -> TimerInterrupts.tcd0_cca;
  Timer.CCIntB      -> TimerInterrupts.tcd0_ccb;
  Timer.CCIntC      -> TimerInterrupts.tcd0_ccc;
  Timer.CCIntD      -> TimerInterrupts.tcd0_ccd;
}
