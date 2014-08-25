/*
 * HplAtxm256Timer1C.nc
 *
 * Generic component for atxmega timer type 1.
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

generic configuration HplAtxm256Timer1P (uint16_t timer_addr)
{
  provides {
    interface StdControl;
    interface HplAtxm256TimerControl   as TimerControl;
    interface HplAtxm256Counter        as Counter;
    interface HplAtxm256CaptureCompare as CaptureCompare[uint8_t id];
  }
  uses {
    interface HplAtxm256OnOff     as Power;
    interface HplAtxm256Interrupt as OverflowInt;
    interface HplAtxm256Interrupt as CCIntA;
    interface HplAtxm256Interrupt as CCIntB;
  }
}
implementation
{
  components 
    new HplAtxm256TimerControl1P(timer_addr) as Control1,
    new HplAtxm256Counter1P(timer_addr) as Counter1,
    new HplAtxm256CaptureCompare1P(timer_addr) as CaptureCompare1,
    McuSleepC;

  StdControl     = Control1;
  TimerControl   = Control1;
  Counter        = Counter1;

  Control1.Power         = Power;
  Counter1.OverflowInt   = OverflowInt;
  Control1.Counter       -> Counter1;
  Counter1.McuPowerState -> McuSleepC;

  CaptureCompare1.CCIntA = CCIntA;
  CaptureCompare1.CCIntB = CCIntB;

  CaptureCompare[0] = CaptureCompare1.CaptureCompareA;
  CaptureCompare[1] = CaptureCompare1.CaptureCompareB;
}
