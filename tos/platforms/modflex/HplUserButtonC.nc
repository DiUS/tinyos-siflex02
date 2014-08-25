/*
 * HplUserButtonC.nc
 * 
 * HPL user buttons on modflex for siflex02.
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

configuration HplUserButtonC {
  provides interface GeneralIO     as Button1IO;
  provides interface GpioInterrupt as Button1Int;

  provides interface GeneralIO     as Button2IO;
  provides interface GpioInterrupt as Button2Int;
}
implementation {
#define button1_port PortE5
#define button2_port PortF0

  components HplAtxm256IOC           as HplIO;
  components HplAtxm256IOInterruptsC as HplInterrupts;

  components new Atxm256GeneralIOC() as Button1GeneralIO;
  Button1IO = Button1GeneralIO;
  Button1GeneralIO -> HplIO.button1_port;

  components new Atxm256GeneralIOC() as Button2GeneralIO;
  Button2IO = Button2GeneralIO;
  Button2GeneralIO -> HplIO.button2_port;

  components new Atxm256GpioInterruptC()       as Button1GpioInt,
             new Atxm256IOInterruptTriggersC() as Button1Triggers;
  Button1Int = Button1GpioInt;
  Button1GpioInt.HplInt  -> HplInterrupts.PortIntE0;
  Button1GpioInt.Trigger -> Button1Triggers.Int0Trigger;
  Button1Triggers.IO     -> HplIO.button1_port;

  components new Atxm256GpioInterruptC()       as Button2GpioInt,
             new Atxm256IOInterruptTriggersC() as Button2Triggers;
  Button2Int = Button2GpioInt;
  Button2GpioInt.HplInt  -> HplInterrupts.PortIntF0;
  Button2GpioInt.Trigger -> Button2Triggers.Int0Trigger;
  Button2Triggers.IO     -> HplIO.button2_port;
}
