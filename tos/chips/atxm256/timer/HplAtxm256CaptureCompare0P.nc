/*
 * HplAtxm256CaptureCompare0P.nc
 *
 * Generic capture/compare component for atxmega timer type 0.
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

generic module HplAtxm256CaptureCompare0P (uint16_t timer_addr)
{
  provides {
    interface HplAtxm256CaptureCompare as CaptureCompareA;
    interface HplAtxm256CaptureCompare as CaptureCompareB;
    interface HplAtxm256CaptureCompare as CaptureCompareC;
    interface HplAtxm256CaptureCompare as CaptureCompareD;
  }
  uses {
    interface HplAtxm256Interrupt as CCIntA;
    interface HplAtxm256Interrupt as CCIntB;
    interface HplAtxm256Interrupt as CCIntC;
    interface HplAtxm256Interrupt as CCIntD;
  }
}
implementation
{
#define tc ((TC0_t*)timer_addr)

  async command uint16_t CaptureCompareA.get() { return tc->CCA; }
  async command uint16_t CaptureCompareB.get() { return tc->CCB; }
  async command uint16_t CaptureCompareC.get() { return tc->CCC; }
  async command uint16_t CaptureCompareD.get() { return tc->CCD; }

  async command void CaptureCompareA.set(uint16_t t) { tc->CCA = t; }
  async command void CaptureCompareB.set(uint16_t t) { tc->CCB = t; }
  async command void CaptureCompareC.set(uint16_t t) { tc->CCC = t; }
  async command void CaptureCompareD.set(uint16_t t) { tc->CCD = t; }

  default async event void CaptureCompareA.fired(uint16_t) { }
  async event void CCIntA.fired() {
    signal CaptureCompareA.fired(call CaptureCompareA.get());
  }
  default async event void CaptureCompareB.fired(uint16_t) { }
  async event void CCIntB.fired() {
    signal CaptureCompareB.fired(call CaptureCompareB.get());
  }
  default async event void CaptureCompareC.fired(uint16_t) { }
  async event void CCIntC.fired() {
    signal CaptureCompareC.fired(call CaptureCompareC.get());
  }
  default async event void CaptureCompareD.fired(uint16_t) { }
  async event void CCIntD.fired() {
    signal CaptureCompareC.fired(call CaptureCompareD.get());
  }

  async command void CaptureCompareA.reset() { call CCIntA.reset(); }
  async command void CaptureCompareB.reset() { call CCIntB.reset(); }
  async command void CaptureCompareC.reset() { call CCIntC.reset(); }
  async command void CaptureCompareD.reset() { call CCIntD.reset(); }

  async command void CaptureCompareA.start() { 
    call CCIntA.enable();
  }
  async command void CaptureCompareB.start() { 
    call CCIntB.enable();
  }
  async command void CaptureCompareC.start() { 
    call CCIntC.enable();
  }
  async command void CaptureCompareD.start() { 
    call CCIntD.enable();
  }

  async command void CaptureCompareA.stop()  { 
    call CCIntA.disable();
  }
  async command void CaptureCompareB.stop()  { 
    call CCIntB.disable();
  }
  async command void CaptureCompareC.stop()  { 
    call CCIntC.disable();
  }
  async command void CaptureCompareD.stop()  { 
    call CCIntD.disable();
  }

  async command bool CaptureCompareA.test() { 
    return call CCIntA.test();
  }
  async command bool CaptureCompareB.test() {
    return call CCIntB.test();
  }
  async command bool CaptureCompareC.test() {
    return call CCIntC.test();
  }
  async command bool CaptureCompareD.test() { 
    return call CCIntD.test();
  }

  async command bool CaptureCompareA.isOn() { 
    return call CCIntA.isEnabled();
  }
  async command bool CaptureCompareB.isOn() { 
    return call CCIntB.isEnabled();
  }
  async command bool CaptureCompareC.isOn() { 
    return call CCIntC.isEnabled();
  }
  async command bool CaptureCompareD.isOn() { 
    return call CCIntD.isEnabled();
  }
}
