/*
 * Atxm256Usart.h
 *
 * USART header for atxmega.
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

#ifndef _H_ATXM256USART_H
#define _H_ATXM256USART_H

// Minimum allowed baud rate. The time in microseconds required to 
// communicate one byte must fit into a uint16_t.
#define ATXM256_UART_MIN_BAUD_RATE ((8000000u / (65535u - 1)) + 1)

// Maximum allowed baud rate. The time required to communicate 
// one byte must be greater than 1 microsecond.
#define ATXM256_UART_MAX_BAUD_RATE 8000000u

// The time required in microseconds to communicate a byte at a given baud
// rate. Add one so the integer byte time is at least the real byte time.
#define ATXM256_UART_BYTE_TIME(baud) ((8000000u / (baud)) + 1)

typedef enum {
  ATXM256_UART_ONE_STOP_BIT  = 0,
  ATXM256_UART_TWO_STOP_BITS = USART_SBMODE_bm
} atxm256_uart_stop_bits_t;

// UART configuration structure.
typedef struct {
  // UART baud rate.
  uint32_t baudRate;

  //Parity: USART_PMODE_DISABLED_gc, USART_PMODE_EVEN_gc, USART_PMODE_ODD_gc.
  uint8_t parity;

  // Number of bits to transmit as a character (atxm256_uart_char_bits_t):
  // USART_CHSIZE_5BIT_gc, USART_CHSIZE_6BIT_gc, USART_CHSIZE_7BIT_gc,
  // USART_CHSIZE_8BIT_gc, USART_CHSIZE_9BIT_gc.
  uint8_t charSize;

  // Number of stop bits between two characters (1 or 2):
  // ATXM256_UART_ONE_STOP_BIT, ATXM256_UART_TWO_STOP_BITS
  uint8_t stopBits;
} atxm256_uart_config_t;

#endif // _H_ATXM256USART_H
