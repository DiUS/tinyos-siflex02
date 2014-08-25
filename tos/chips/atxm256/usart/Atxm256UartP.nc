/*
 * Atxm256UartP.nc
 *
 * Generic Hal UART implementation for atxmega.
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

#include <Atxm256Timer.h>

generic module Atxm256UartP() 
{
  provides {
    interface StdControl;
    interface UartStream;
    interface UartByte;
  }
  uses {
    interface Atxm256UartConfigure;
    interface HplAtxm256Interrupt as TxInt;
    interface HplAtxm256Interrupt as DrInt;
    interface HplAtxm256Interrupt as RxInt;
    interface HplAtxm256Usart as Usart;
    interface Counter<TMicro, uint32_t>;
    interface McuPowerState;
  }
}
implementation 
{
  norace volatile uint16_t m_txLen, m_rxLen;
  norace volatile uint8_t* COUNT_NOK(m_txLen) m_txBuf;
  norace volatile uint8_t* COUNT_NOK(m_rxLen) m_rxBuf;
  norace volatile uint16_t m_txPos, m_rxPos;
  // Number of microseconds to communicate a byte.
  norace volatile uint32_t  m_byteTimeUs;

  command error_t StdControl.start() {
    atxm256_uart_config_t* config;

    if(call Usart.getMode())
    {
      return EBUSY;
    }

    config = call Atxm256UartConfigure.getConfig();
    if(config->baudRate < ATXM256_UART_MIN_BAUD_RATE
    || config->baudRate > ATXM256_UART_MAX_BAUD_RATE)
    {
      return EINVAL;
    }

    m_byteTimeUs = ATXM256_UART_BYTE_TIME(config->baudRate);

    call Usart.setModeUart(config);
    call RxInt.enable();
    call TxInt.enable();
    call McuPowerState.update();

    return SUCCESS;
  }

  command error_t StdControl.stop() {
    if ( m_rxBuf || m_txBuf ) {
      return EBUSY;
    }

    call TxInt.disable();
    call RxInt.disable();
    call Usart.setModeOff();
    call McuPowerState.update();

    return SUCCESS;
  }

  async command error_t UartStream.enableReceiveInterrupt() 
  {
    call RxInt.enable();
    return SUCCESS;
  }
  
  async command error_t UartStream.disableReceiveInterrupt()
  {
    call RxInt.disable();
    return SUCCESS;
  }

  async command error_t UartStream.receive( uint8_t* buf, uint16_t len )
  {
    if ( len == 0 ) {
      return FAIL;
    }

    atomic {
      if ( m_rxBuf ) {
        return EBUSY;
      }

      m_rxBuf = buf;
      m_rxLen = len;
      m_rxPos = 0;
    }

    return SUCCESS;
  }
  
  async event void DrInt.fired()
  {
  }

  async event void RxInt.fired()
  {
    uint8_t data = call Usart.rx();
    if ( m_rxBuf ) {
      m_rxBuf[ m_rxPos++ ] = data;
      if ( m_rxPos >= m_rxLen ) {
        uint8_t* buf = (uint8_t*)m_rxBuf;
        m_rxBuf = NULL;
        signal UartStream.receiveDone( buf, m_rxLen, SUCCESS );
      }
    } else {
      signal UartStream.receivedByte( data );
    }
  }
  
  async command error_t UartStream.send( uint8_t* buf, uint16_t len ) 
  {
    if ( len == 0 ) {
      return FAIL;
    } else if ( m_txBuf ) {
      return EBUSY;
    }

    m_txBuf = buf;
    m_txLen = len;
    m_txPos = 0;
    call Usart.tx( buf[ m_txPos++ ] );

    return SUCCESS;
  }

  async event void TxInt.fired()
  {
    if ( m_txPos < m_txLen ) {
      call Usart.tx( m_txBuf[ m_txPos++ ] );
    } else {
      uint8_t* buf = (uint8_t*)m_txBuf;
      m_txBuf = NULL;
      signal UartStream.sendDone( buf, m_txLen, SUCCESS );
    }
  }
  
  async command error_t UartByte.send( uint8_t data ) 
  {
    call TxInt.reset();
    call TxInt.disable();
    call Usart.tx( data );
    while( !call TxInt.test() ) { }
    call TxInt.reset();
    call TxInt.enable();

    return SUCCESS;
  }
  
  async command error_t UartByte.receive( uint8_t* byte, uint8_t timeout ) 
  {
    uint32_t timeout_micro = m_byteTimeUs * timeout;
    uint32_t start;
    
    start = call Counter.get();
    while( !call RxInt.test() ) {
      if ( ( call Counter.get() - start ) >= timeout_micro ) {
				return FAIL;
      }
    }
    *byte = call Usart.rx();
    
    return SUCCESS;
  }
  
  async event void Counter.overflow() {}

  default async event void UartStream.sendDone(
                           uint8_t* buf, uint16_t len, error_t error) { }
  default async event void UartStream.receivedByte(uint8_t byte) { }
  default async event void UartStream.receiveDone( 
                           uint8_t* buf, uint16_t len, error_t error) { }
}
