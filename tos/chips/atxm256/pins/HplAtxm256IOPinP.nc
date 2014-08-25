/*
 * HplAtxm256IOPinP.nc
 *
 * HPL IO pin access for atxmega.
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

#include <atxm256hardware.h>

generic module HplAtxm256IOPinP (uint16_t port_addr, uint8_t bit)
{
  provides interface HplAtxm256IO as IO;
}
implementation
{
#define port ((PORT_t*)port_addr)
#define bv _BV(bit)
#define pinctrl ((&port->PIN0CTRL)[bit])
  async command bool IO.get()        { return (port->IN & bv) ? TRUE : FALSE; }
  async command void IO.set()        { port->OUTSET = bv; }
  async command void IO.clr()        { port->OUTCLR = bv; }
  async command void IO.toggle()     { port->OUTTGL = bv; }

  async command void IO.makeInput()  { port->DIRCLR = bv; }
  async command bool IO.isInput()    { return (port->DIR & bv) ? FALSE : TRUE; }
  async command void IO.makeOutput() { port->DIRSET = bv; }
  async command bool IO.isOutput()   { return (port->DIR & bv) ? TRUE : FALSE; }

  async command void IO.setOutputPullConfig(uint8_t bits) {
    pinctrl = (pinctrl & ~PORT_OPC_gm) | bits;
  }
  async command uint8_t IO.getOutputPullConfig() {
    return (pinctrl & PORT_OPC_gm);
  }

  async command void IO.setInputSenseConfig(uint8_t bits) {
    pinctrl = (pinctrl & ~PORT_ISC_gm) | bits;
  }
  async command uint8_t IO.getInputSenseConfig() {
    return (pinctrl & PORT_ISC_gm);
  }

  async command void IO.triggerInt0On()      { port->INT0MASK |= bv;  }
  async command void IO.triggerInt0Off()     { port->INT0MASK &= ~bv; }
  async command bool IO.triggerInt0IsOn()    { return (port->INT0MASK & bv) 
                                               ? TRUE : FALSE; }
  async command bool IO.triggerInt0IsAnyOn() { return port->INT0MASK 
                                               ? TRUE : FALSE; }

  async command void IO.triggerInt1On()      { port->INT1MASK |= bv;  }
  async command void IO.triggerInt1Off()     { port->INT1MASK &= ~bv; }
  async command bool IO.triggerInt1IsOn()    { return (port->INT1MASK & bv)
                                                      ? TRUE : FALSE; }
  async command bool IO.triggerInt1IsAnyOn() { return port->INT1MASK 
                                                      ? TRUE : FALSE; }
}
