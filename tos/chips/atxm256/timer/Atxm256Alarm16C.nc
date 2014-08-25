/*
 * Atxm256Alarm16C.nc
 *
 * Adapt a TEP102 16 bit alarm from an atxmega hardware timer and
 * one of its compare registers.
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

generic module Atxm256Alarm16C (typedef frequency_tag, int mindt)
{
  provides interface Alarm<frequency_tag, uint16_t> as Alarm @atmostonce();
  uses interface HplAtxm256Counter as HWCounter;
  uses interface HplAtxm256CaptureCompare as HWCaptureCompare;
}
implementation
{
  async command uint16_t Alarm.getNow() {
    return call HWCounter.get();
  }

  async command uint16_t Alarm.getAlarm() {
    return call HWCaptureCompare.get();
  }

  async command bool Alarm.isRunning() {
    return call HWCaptureCompare.isOn();
  }

  async command void Alarm.stop() {
    call HWCaptureCompare.stop();
  }

  async command void Alarm.start( uint16_t dt ) 
  {
    call Alarm.startAt(call HWCounter.get(), dt);
  }

  async command void Alarm.startAt( uint16_t t0, uint16_t dt ) {
    /* We don't set an interrupt before "now" + mindt to avoid setting
       an interrupt which is in the past by the time we actually set
       it. mindt should always be at least 2, because you cannot
       reliably set an interrupt one cycle in the future. mindt should
       also be large enough to cover the execution time of this
       function. */
    atomic {
      uint16_t now, elapsed, expires;

      now = call HWCounter.get();
      elapsed = now + mindt - t0;
      if (elapsed >= dt) {
        expires = now + mindt;
      } else {
        expires = t0 + dt;
      }

      /* Don't set compare register to "-1". */
      if (expires == 0)
        expires = 1;

      /* Note: all HWCaptureCompare.set values have one subtracted,
         because the comparisons are continuous, but the actual
         interrupt is signalled at the next timer clock cycle. */
      call HWCaptureCompare.set(expires - 1);
      call HWCaptureCompare.reset();
      call HWCaptureCompare.start();
    }
  }

  async event void HWCaptureCompare.fired(uint16_t) {
    call HWCaptureCompare.stop();
    signal Alarm.fired();
  }

  async event void HWCounter.overflow() {
  }
}
