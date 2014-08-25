/*
 * HplAtxm256TimerControl0P.nc
 *
 * atxmega timer control interface for timer type 0.
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

generic module HplAtxm256TimerControl0P (uint16_t timer_addr)
{
  provides {
    interface StdControl;
    interface HplAtxm256TimerControl as TimerControl;
  }
  uses 
  {
    interface HplAtxm256OnOff   as Power;
    interface HplAtxm256Counter as Counter;
  }
}
implementation
{
#define tc ((TC0_t*)timer_addr)

  command error_t StdControl.start()
  {
    call Power.on();
    return SUCCESS;
  }

  command error_t StdControl.stop()
  {
    call Counter.off();
    call Power.off();
    return SUCCESS;
  }

  command void TimerControl.setWaveformGeneratorMode(uint8_t mode) {
    tc->CTRLB = (tc->CTRLB & ~TC0_WGMODE_gm) | mode;
  }

  async event void Counter.overflow()
  {
  }
}
