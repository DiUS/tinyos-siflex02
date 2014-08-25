/*
 * Atxm256SpiDC.nc
 *
 * Generic Hal SPI for atxmega.
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

generic module Atxm256SpiP()
{
  provides {
    interface Init;
    interface SpiByte;
    interface FastSpiByte;
    interface SpiPacket;
    interface Resource[uint8_t id];
  }
  uses {
    interface HplAtxm256Spi       as Spi;
    interface HplAtxm256Interrupt as SpiInt;
    interface Resource            as ResourceArbiter[uint8_t id];
    interface ArbiterInfo;
    interface Atxm256SystemClock;
  }
}
implementation
{
  enum {
    SPI_ATOMIC_SIZE = 2,
  };

  volatile uint16_t bufLen;
  volatile uint8_t* COUNT_NOK(bufLen) txBuf;
  volatile uint8_t* COUNT_NOK(bufLen) rxBuf;
  norace volatile uint16_t bufPos;

  uint8_t getSpiClockFlags4MHz() {
    uint8_t peripheralMHz;

    peripheralMHz
    = (uint8_t)(call Atxm256SystemClock.peripheralClockHz() / 1000000);

    if(peripheralMHz <= 8) {
      return SPI_CLK2X_bm | SPI_PRESCALER_DIV4_gc;
    } else if(peripheralMHz <= 16) {
      return SPI_PRESCALER_DIV4_gc;
    } else if(peripheralMHz <= 32) {
      return SPI_CLK2X_bm | SPI_PRESCALER_DIV16_gc;
    }

    // The default if the peripheral clock is unfeasibly fast.
    // It will most probably be wrong.
    return SPI_PRESCALER_DIV16_gc;
  }

  void startSpi() {
    call Spi.initMaster(getSpiClockFlags4MHz() | SPI_MODE_0_gc);
  }

  void stopSpi() {
    call Spi.shutdown();
  }

  command error_t Init.init() {
    return SUCCESS;
  }

  async command uint8_t SpiByte.write( uint8_t tx ) {
    call Spi.write( tx );
    while (!call SpiInt.test()) { }
    return call Spi.read();
  }

  async command void FastSpiByte.splitWrite(uint8_t data) {
    call Spi.write(data);
  }

  async command uint8_t FastSpiByte.splitRead() {
    while(!call SpiInt.test()) { }
    return call Spi.read();
  }

  async command uint8_t FastSpiByte.splitReadWrite(uint8_t data) {
    uint8_t b;
    while(!call SpiInt.test()) { }
    b = call Spi.read();
    call Spi.write(data);
    return b;
  }

  async command uint8_t FastSpiByte.write(uint8_t data) {
    call Spi.write(data);
    while(!call SpiInt.test()) { }
    return call Spi.read();
  }

  void signalSendPacketDone() {
    signal SpiPacket.sendDone((uint8_t*)txBuf, (uint8_t*)rxBuf, bufLen, SUCCESS);
  }

  task void sendPacketWithZeroBytesDone() {
    atomic signalSendPacketDone();
  }

  void continuePacketSend() {
    uint16_t end;
    uint8_t  b;

    atomic {
      call Spi.write(txBuf ? txBuf[bufPos] : 0);

      end = bufPos + SPI_ATOMIC_SIZE;
      if(end > bufLen) { end = bufLen; }

      for(bufPos++; bufPos < end; bufPos++) {
        while(!call SpiInt.test()) { }
        b = call Spi.read();
        if(rxBuf) { rxBuf[bufPos - 1] = b; }
        call Spi.write(txBuf ? txBuf[bufPos] : 0 );
      }
    }
  }

  async command error_t SpiPacket.send(uint8_t* writeBuf, 
                                       uint8_t* readBuf, 
                                       uint16_t len) {
    bufLen = len;
    txBuf = writeBuf;
    rxBuf = readBuf;
    bufPos = 0;

    if ( bufLen ) {
      call SpiInt.reset();
      call SpiInt.enable();
      continuePacketSend();
    } else {
      post sendPacketWithZeroBytesDone();
    }

    return SUCCESS;
  }

  async event void SpiInt.fired() {
    uint8_t b;
    b = call Spi.read();
    if(rxBuf) { 
      rxBuf[bufPos - 1] = b; 
    }
    if(bufPos < bufLen) {
      continuePacketSend();
    } else {
      call SpiInt.disable();
      signalSendPacketDone();
    }
  }

  default async event void SpiPacket.sendDone(
    uint8_t* /* tx */,  uint8_t* /* rx */, 
    uint16_t /* len */, error_t  /* err */ ) { }

  async command error_t Resource.immediateRequest[ uint8_t id ]() {
    error_t result = call ResourceArbiter.immediateRequest[ id ]();
    if ( result == SUCCESS ) {
      startSpi();
    }
    return result;
  }
  
  async command error_t Resource.request[ uint8_t id ]() {
    atomic {
      if (!call ArbiterInfo.inUse()) {
        startSpi();
      }
    }
    return call ResourceArbiter.request[ id ]();
  }
 
  async command error_t Resource.release[ uint8_t id ]() {
    error_t error = call ResourceArbiter.release[ id ]();
    atomic {
      if (!call ArbiterInfo.inUse()) {
        stopSpi();
      }
    }
    return error;
  }
 
  async command bool Resource.isOwner[uint8_t id]() {
    return call ResourceArbiter.isOwner[id]();
  }
  
  event void ResourceArbiter.granted[ uint8_t id ]() {
    signal Resource.granted[ id ]();
  }
  
  default event void Resource.granted[ uint8_t id ]() {}
}
