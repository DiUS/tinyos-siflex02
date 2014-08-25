/*
 * Atxm256UartF0C.nc
 *
 * Hal UART on atxmega port F0.
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

#include <Atxm256Usart.h>
#include <Atxm256Timer.h>

configuration Atxm256UartF0C
{
  provides {
    interface StdControl;
    interface UartByte;
    interface UartStream;
  }
  uses interface Atxm256UartConfigure;
  uses interface Counter<TMicro, uint32_t>;
}
implementation
{
  components new Atxm256UartP() as UartP,
             HplAtxm256UsartF0C as Usart,
             McuSleepC;

  StdControl           = UartP;
  UartStream           = UartP;
  UartByte             = UartP;

  UartP.Atxm256UartConfigure = Atxm256UartConfigure;
  UartP.Counter              = Counter;

  UartP.Usart         -> Usart;
  UartP.TxInt         -> Usart.TxInt;
  UartP.DrInt         -> Usart.DrInt;
  UartP.RxInt         -> Usart.RxInt;
  UartP.McuPowerState -> McuSleepC;
}
