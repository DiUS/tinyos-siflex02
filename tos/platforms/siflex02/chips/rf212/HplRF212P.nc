/*
 * HplRF212P.nc
 * 
 * rf212 radio configuration for siflex02.
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

module HplRF212P
{
  provides
  {
    interface Init;
    interface GpioCapture as IRQ;
    interface McuPowerOverride;
  }
  uses
  {
    interface HplAtxm256IO              as PortIRQ;
    interface GpioInterrupt             as Interrupt;
    interface Counter<T32khz, uint16_t> as Counter32kHz16;
  }
}

implementation
{
  norace bool radioOn = FALSE;
  
  command error_t Init.init()
  {
    call PortIRQ.makeInput();
    call PortIRQ.clr();
    return SUCCESS;
  }
  
  async command mcu_power_t McuPowerOverride.lowestState()
  {
    return radioOn ? ATXM256_POWER_IDLE : ATXM256_POWER_DOWN;
  }
  
  async event void Interrupt.fired() {
    uint16_t time = call Counter32kHz16.get();
    signal IRQ.captured(time);
  }
  
  async command error_t IRQ.captureRisingEdge()
  {
    call Interrupt.enableRisingEdge();
    radioOn = TRUE;
  
    return SUCCESS;
  }

  async command error_t IRQ.captureFallingEdge()
  {
    // The falling edge comes when the IRQ_STATUS register of the RF212 is
    // read.
    return FAIL;  
  }

  async command void IRQ.disable()
  {
    call Interrupt.disable();
    radioOn = FALSE;
  }
  
  async event void Counter32kHz16.overflow() {}
}
