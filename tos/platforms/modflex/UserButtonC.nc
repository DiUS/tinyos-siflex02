/*
 * UserButtonC.nc
 * 
 * User buttons on modflex for siflex02.
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

configuration UserButtonC {
  provides interface Notify<button_state_t> as NotifyButton1;
  provides interface Notify<button_state_t> as NotifyButton2;
}
implementation {
  components HplUserButtonC;
  components McuSleepC;

  components new UserButtonP()   as Button1,
             new SwitchToggleC() as SwitchToggle1,
             new TimerMilliC()   as debounce1;
  NotifyButton1 = Button1;
  Button1.debounceTimer       -> debounce1;
  Button1.NotifyLower         -> SwitchToggle1.Notify;
  SwitchToggle1.GeneralIO     -> HplUserButtonC.Button1IO;
  SwitchToggle1.GpioInterrupt -> HplUserButtonC.Button1Int;
  Button1.McuPowerOverride    <- McuSleepC;

  components new UserButtonP()   as Button2,
             new SwitchToggleC() as SwitchToggle2,
             new TimerMilliC()   as debounce2;
  NotifyButton2 = Button2;
  Button2.debounceTimer       -> debounce2;
  Button2.NotifyLower         -> SwitchToggle2.Notify;
  SwitchToggle2.GeneralIO     -> HplUserButtonC.Button2IO;
  SwitchToggle2.GpioInterrupt -> HplUserButtonC.Button2Int;
  Button2.McuPowerOverride    <- McuSleepC;
}
