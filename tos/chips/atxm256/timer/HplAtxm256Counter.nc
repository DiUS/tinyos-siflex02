/*
 * HplAtxm256Counter.nc
 *
 * atxmega counter interface.
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

interface HplAtxm256Counter
{
  // ==== Counter value register: Direct access ======================

  /** 
   * Get the current time.
   * @return  the current time
   */
  async command uint16_t get();

  /** 
   * Set the current time.
   * @param t     the time to set
   */
  async command void set( uint16_t t );

  // ==== Interrupt signals ==========================================

  /** Signalled on timer overflow interrupt. */
  async event void overflow();

  // ==== Interrupt flag utilites: Bit level set/clr =================

  /** Clear the overflow interrupt flag. */
  async command void reset();

  /** Enable the overflow interrupt. */
  async command void start();

  /** Turn off overflow interrupts. */
  async command void stop();

  /** 
   * Did an overflow interrupt occur?
   * @return TRUE if overflow triggered, FALSE otherwise
   */
  async command bool test();

  /** 
   * Is overflow interrupt on? 
   * @return TRUE if overflow enabled, FALSE otherwise
   */
  async command bool isOn();

  // ==== Start and stop the clock. =================

  /** Turn off the clock. */
  async command void off();

  /** 
   * Turn on the clock.
   * @param scale   Prescaler setting of clock -- must be of type TC_CLKSEL_t
   *                or RTC_PRESCALER_t, depending on the timer;
   */
  async command void setScale( uint8_t scale);

  /** 
   * Get prescaler setting.
   * @return  Prescaler setting of clock -- must be of type TC_CLKSET_t
   *          or RTC_PRESCALER_t, depending on the timer;
   */
  async command uint8_t getScale();
}
