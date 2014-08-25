/*
 * HplAtxm256Rtc16P.nc
 *
 * atxmega 16 bit real time clock.
 *
 * References: 1. AVR1314 - Using the XMEGA Real Time Counter.pdf
 *                Rev. 8047A-AVR-02/08
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

#define RTC_WAIT_UNTIL_READY() while(RTC.STATUS & RTC_SYNCBUSY_bm) {}

module HplAtxm256Rtc16P
{
  provides {
    interface Init                     as MoteClockInitHook;
    interface StdControl;
    interface HplAtxm256Counter        as Counter;
    interface HplAtxm256CaptureCompare as Compare;
  }
  uses
  {
    interface HplAtxm256OnOff     as Power;
    interface HplAtxm256Interrupt as OverflowInt;
    interface HplAtxm256Interrupt as CompareInt;
    interface McuPowerState;
  }
}
implementation
{
  command error_t MoteClockInitHook.init()
  {
    // Enable RTC clocked from external 32 kHz oscillator.
    CLK.RTCCTRL = CLK_RTCSRC_TOSC32_gc | CLK_RTCEN_bm;
    return SUCCESS;
  }

  command error_t StdControl.start()
  {
    call Power.on();

    // Count all the way to the top.
    RTC.PER = 0xffff;

    // Initialise count to zero. As a side effect this also synchronises PER to
    // the RTC domain as per [1] section 2.4 p3.
    RTC.CNT = 0;

    return SUCCESS;
  }

  command error_t StdControl.stop()
  {
    call Counter.off();
    CLK.RTCCTRL = 0;
    call Power.off();
  }

  async command uint16_t Counter.get() { return RTC.CNT; }

  async command void Counter.set( uint16_t t ) { 
    RTC_WAIT_UNTIL_READY();
    RTC.CNT = t; 
  }

  async event void OverflowInt.fired() { signal Counter.overflow(); }

  async command void Counter.reset() { call OverflowInt.reset(); }

  async command void Counter.start() { call OverflowInt.enable(); }

  async command void Counter.stop() { call OverflowInt.disable(); }

  async command bool Counter.test() { return call OverflowInt.test(); }

  async command bool Counter.isOn() { return call OverflowInt.isEnabled(); }

  async command void Counter.off() { call Counter.setScale(RTC_PRESCALER_OFF_gc); }

  async command void Counter.setScale( uint8_t scale) { 
    RTC_WAIT_UNTIL_READY();
    RTC.CTRL = scale; 
    call McuPowerState.update();
  }

  async command uint8_t Counter.getScale() {
    return (RTC.CTRL & RTC_PRESCALER_gm); 
  }

  async command uint16_t Compare.get() { return RTC.COMP; }

  async command void Compare.set(uint16_t t) { 
    RTC_WAIT_UNTIL_READY();
    RTC.COMP = t; 
  }

  default async event void Compare.fired(uint16_t) { }
  async event void CompareInt.fired() {
    signal Compare.fired(call Compare.get());
  }

  async command void Compare.reset() { call CompareInt.reset(); }

  async command void Compare.start() { 
    call CompareInt.enable();
  }

  async command void Compare.stop()  { 
    call CompareInt.disable();
  }

  async command bool Compare.test() { 
    return call CompareInt.test();
  }

  async command bool Compare.isOn() { 
    return call CompareInt.isEnabled();
  }
}
