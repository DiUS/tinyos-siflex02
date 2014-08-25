/*
 * UserButtonP.nc
 * 
 * A generic user button on modflex for siflex02.
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

#include <UserButton.h>

generic module UserButtonP() {
  provides interface Notify<button_state_t>;
  provides interface McuPowerOverride;

  uses interface Notify<bool> as NotifyLower;
  uses interface Timer<TMilli> as debounceTimer;
}
implementation {
  norace volatile mcu_power_t lowestPowerState = ATXM256_POWER_DOWN;

  command error_t Notify.enable() {
    lowestPowerState = ATXM256_POWER_IDLE;
    return call NotifyLower.enable();
  }

  command error_t Notify.disable() {
    lowestPowerState = ATXM256_POWER_DOWN;
    return call NotifyLower.disable();
  }

  event void debounceTimer.fired() {
    call Notify.enable();
    signal Notify.notify( BUTTON_PRESSED );
  }

  task void debounce() {
    call debounceTimer.startOneShot(120);
  }

  event void NotifyLower.notify( bool val ) {
    call Notify.disable();
    post debounce();
  }

  async command mcu_power_t McuPowerOverride.lowestState() 
  {
    return lowestPowerState;
  }
  
  default event void Notify.notify( button_state_t val ) { }
}
