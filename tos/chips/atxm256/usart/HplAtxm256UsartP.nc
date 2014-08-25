/*
 * HplAtxm256UsartP.nc
 *
 * Generic Hpl USART for atxmega.
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

generic module HplAtxm256UsartP(uint16_t usart_addr)
{
  provides {
    interface HplAtxm256Usart;
  }
  uses {
    interface Atxm256SystemClock  as SystemClock;
    interface HplAtxm256OnOff     as Power;
    interface HplAtxm256IO        as TxD;
    interface HplAtxm256IO        as RxD;
  }
}
implementation
{
#define usart ((USART_t*)usart_addr)

  /**
   * Set the UART baudrate.
   *
   * This function sets the baudrate register regarding the CPU frequency.
   *
   * \param baud  The baudrate.
   *
   * \retval SUCCESS if the hardware supports the baud rate
   * \retval FAIL    if the hardware does not support the baud rate (i.e. it's
   *                 either too high or too low.)
   */
  error_t setUartBaudRate(uint32_t baud)
  {
    int8_t   exponent;
    uint32_t divide;
    uint32_t limit;
    uint32_t ratio;
    uint32_t min_rate;
    uint32_t max_rate;
    uint32_t peripheralClockHz;

    /* Get peripheral clock. */
    peripheralClockHz = call SystemClock.peripheralClockHz();

    /*
     * Check if the hardware supports the given baud rate
     */
    // 8 = (2^0) * 8 * (2^0) = (2^BSCALE_MIN) * 8 * (BSEL_MIN)
    max_rate = peripheralClockHz / 8;
    // 4194304 = (2^7) * 8 * (2^12) = (2^BSCALE_MAX) * 8 * (BSEL_MAX+1)
    min_rate = peripheralClockHz / 4194304;

    if (!((usart)->CTRLB & USART_CLK2X_bm)) {
      max_rate /= 2;
      min_rate /= 2;
    }

    if ((baud > max_rate) || (baud < min_rate)) {
      return FAIL;
    }

    /*
     * Check if double speed is enabled.
     */
    if (!((usart)->CTRLB & USART_CLK2X_bm)) {
      baud *= 2;
    }

    /*
     * Find the lowest possible exponent.
     */
    limit = 0xfffU >> 4;
    ratio = peripheralClockHz / baud;

    for (exponent = -7; exponent < 7; exponent++) {
      if (ratio < limit) {
        break;
      }

      limit <<= 1;

      if (exponent < -3) {
        limit |= 1;
      }
    }

    /*
     * Depending on the value of exponent, scale either the input frequency or
     * the target baud rate. By always scaling upwards, we never introduce
     * any additional inaccuracy.
     *
     * We are including the final divide-by-8 (aka. right-shift-by-3) in this
     * operation as it ensures that we never exceeed 2**32 at any point.
     *
     * The formula for calculating BSEL is slightly different when exponent is
     * negative than it is when exponent is positive.
     */
    if (exponent < 0) {
      /*
       * We are supposed to subtract 1, then apply BSCALE. We want to apply
       * BSCALE first, so we need to turn everything inside the parenthesis
       * into a single fractional expression.
       */
      peripheralClockHz -= 8 * baud;
      /*
       * If we end up with a left-shift after taking the final divide-by-8
       * into account, do the shift before the divide. Otherwise, left-shift
       * the denominator instead (effectively resulting in an overall right 
       * shift.)
       */
      if (exponent <= -3) {
        divide = ((peripheralClockHz << (-exponent - 3)) + baud / 2) / baud;
      } else {
        baud <<= exponent + 3;
        divide = (peripheralClockHz + baud / 2) / baud;
      }
    } else {
      /*
       * We will always do a right shift in this case, but we need to shift
       * three extra positions because of the divide-by-8.
       */
      baud <<= exponent + 3;
      divide = (peripheralClockHz + baud / 2) / baud - 1;
    }

    (usart)->BAUDCTRLB = (uint8_t)(((divide >> 8) & 0X0F) | (exponent << 4));
    (usart)->BAUDCTRLA = (uint8_t)divide;

    return SUCCESS;
  }

  async command void HplAtxm256Usart.setModeUart(
                     atxm256_uart_config_t* config)
  {
    call Power.on();
    call TxD.set();
    call TxD.makeOutput();
    call RxD.clr();
    call RxD.makeInput();
    usart->CTRLC = USART_CMODE_ASYNCHRONOUS_gc
                 | config->charSize
                 | config->parity
                 | config->stopBits;
    setUartBaudRate(config->baudRate);
    usart->CTRLB |= USART_RXEN_bm | USART_TXEN_bm;
  }

  async command void HplAtxm256Usart.setModeOff()
  {
    usart->CTRLB = 0x00;
    usart->CTRLC = 0x00;
    call TxD.makeInput();
    call TxD.clr();
    call RxD.clr();
    call Power.off();
  }

  async command uint8_t HplAtxm256Usart.getMode()
  {
    return (usart->CTRLC & USART_CMODE_gm);
  }

  async command void HplAtxm256Usart.tx( uint8_t data )
  {
    usart->DATA = data;
  }

  async command uint8_t HplAtxm256Usart.rx()
  {
    return usart->DATA;
  }
}
