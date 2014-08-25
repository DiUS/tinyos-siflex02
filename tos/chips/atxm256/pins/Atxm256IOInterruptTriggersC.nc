/*
 * Atxm256IOInterruptTriggersC.nc
 *
 * Access to interrupt triggers for an IO pin.
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

generic module Atxm256IOInterruptTriggersC()
{
  provides {
    interface Atxm256IOInterruptTrigger as Int0Trigger;
    interface Atxm256IOInterruptTrigger as Int1Trigger;
  }
  uses interface HplAtxm256IO as IO;
}
implementation
{
  async command void Int0Trigger.on()   { call IO.triggerInt0On();  }
  async command void Int0Trigger.off()  { call IO.triggerInt0Off(); }
  async command bool Int0Trigger.isOn() { return call IO.triggerInt0IsOn(); }
  async command bool Int0Trigger.isAnyOn() { 
    return call IO.triggerInt0IsAnyOn(); 
  }
  async command void Int0Trigger.setInputSenseConfig(uint8_t bits) {
    call IO.setInputSenseConfig(bits);
  }

  async command void Int1Trigger.on()   { call IO.triggerInt1On();  }
  async command void Int1Trigger.off()  { call IO.triggerInt1Off(); }
  async command bool Int1Trigger.isOn() { return call IO.triggerInt1IsOn(); }
  async command bool Int1Trigger.isAnyOn() { 
    return call IO.triggerInt1IsAnyOn(); 
    }
  async command void Int1Trigger.setInputSenseConfig(uint8_t bits) {
    call IO.setInputSenseConfig(bits);
  }
}
