/*
 * HplRF212C.nc
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

#include <RadioConfig.h>

configuration HplRF212C
{
	provides
	{
		interface Resource as SpiResource;
		interface FastSpiByte;

		interface GeneralIO as SELN;
		interface GeneralIO as SLP_TR;
		interface GeneralIO as RSTN;

		interface GpioCapture as IRQ;
		interface Alarm<TRadio, tradio_size> as Alarm;
		interface LocalTime<TRadio> as LocalTimeRadio;
	}
}

implementation
{
  // Expose IRQ from private module.
	components HplRF212P;
	IRQ = HplRF212P.IRQ;

  // Provide radio interrupt and its pin to private module.
#define irq_port PortD2
	components HplAtxm256IOC                     as HplIO,
             new Atxm256GpioInterruptC()       as RadioInterrupt;
	HplRF212P.PortIRQ   -> HplIO.irq_port;
  HplRF212P.Interrupt -> RadioInterrupt;

  // Configure radio interrupt.
  components HplAtxm256IOInterruptsC           as IOInterrupts,
             new Atxm256IOInterruptTriggersC() as IOInterruptTriggers;
  RadioInterrupt.HplInt  -> IOInterrupts.PortIntD0;
  RadioInterrupt.Trigger -> IOInterruptTriggers.Int0Trigger;
  IOInterruptTriggers.IO -> HplIO.irq_port;

  // Configure HAL radio pins.
  components new Atxm256GeneralIOC() as SLP_TR_GeneralIO,
             new Atxm256GeneralIOC() as RSTN_GeneralIO,
             new Atxm256GeneralIOC() as SELN_GeneralIO;
	RSTN   = RSTN_GeneralIO;   RSTN_GeneralIO.HplIO   -> HplIO.PortD0;
	SLP_TR = SLP_TR_GeneralIO; SLP_TR_GeneralIO.HplIO -> HplIO.PortD3;
	SELN   = SELN_GeneralIO;   SELN_GeneralIO.HplIO   -> HplIO.PortD4;

  // Configure radio SPI.
	components Atxm256SpiDC as SpiC;
	SpiResource = SpiC.Resource[unique(UQ_ATXM256_SPID)];
	FastSpiByte = SpiC;

  // Provide 16 bit 32 kHz counter to private module.
	components Counter32kHz16C;
	HplRF212P.Counter32kHz16 -> Counter32kHz16C;

  // Expose microsecond alarm.
	components new AlarmMicro32C() as RadioAlarm;
	Alarm = RadioAlarm;

  // Wire radio init into platform init sequence.
	components PlatformC;
	HplRF212P.Init <- PlatformC.MoteInit;

  // Provide local time microsecond counter.
	components LocalTimeMicroC;
	LocalTimeRadio = LocalTimeMicroC;
	
  // Allow radio to take part in power management.
	components McuSleepC;
  McuSleepC.McuPowerOverride -> HplRF212P;
}
