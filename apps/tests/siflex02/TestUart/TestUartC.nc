/*
 * TestUartC.nc
 *
 * UART test application.
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

#include "assert.h"

module TestUartC @safe()
{
  uses interface Boot;
  uses interface Leds;
  uses interface StdControl as UartControl;
  uses interface UartByte;
  uses interface UartStream;
  uses interface Timer<TMilli> as MilliTimer;
}
implementation
{
  event void MilliTimer.fired() {
    // Test send.
    char* hello = "Hellooo\r\n";
    call UartStream.send((uint8_t*)hello, strlen(hello));
  }

  event void Boot.booted()
  {
    error_t err;
    err = call UartControl.start();
    ASSERT(err == SUCCESS);

    call MilliTimer.startPeriodic(3000);

#if 0
    // Test synchronous send/recieve, including
    // receive timeout.
    call UartStream.disableReceiveInterrupt();
    for(;;)
    {
      for(i = 0; i < 100; i++)
      {
        err = call UartByte.receive(&b, 48);
        if(err == SUCCESS)
        {
          call UartByte.send(b);
          break;
        }
      }
      if(err == SUCCESS)
      {
        call Leds.led0On();
      }
      else
      {
        call Leds.led0Off();
      }
      call Leds.led2Toggle();
    }
#endif
  }

  async event void UartStream.receivedByte( uint8_t byte ) {
     call UartByte.send(byte); 
  }
  async event void UartStream.receiveDone( uint8_t* buf, uint16_t len, error_t error ) {}
  async event void UartStream.sendDone( uint8_t* buf, uint16_t len, error_t error ) {}
}
