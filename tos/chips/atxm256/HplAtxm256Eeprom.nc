/*
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
 *
 * @author Johny Mattsson <jmattsson@dius.com.au>
 */

#include "HplAtxm256Eeprom.h"
interface HplAtxm256Eeprom
{
  /** @returns True if the NVM controller is busy. */
  command bool isBusy ();

  /** @returns True if the EEPROM page buffer is in-use/dirty. */
  command bool isBufferDirty ();

  /**
   * Loads a byte into the EEPROM page buffer.
   * The location in the page buffer gets tagged-for-writing by the NVM,
   * and said location will be included by the erase and write functions.
   *
   * @param offs The offset in the page buffer to store the byte.
   * @param byte The byte to store.
   * @returns SUCCESS if the byte was successfully stored, FAIL if NVM is busy.
   */
  command error_t bufferLoadByte (eeprom_offs_t offs, uint8_t byte);

  /**
   * Begins an erase of the EEPROM page buffer.
   * Until the done() event is signalled, all further operations will fail.
   *
   * @returns SUCCESS if the operation was commenced, FAIL if the NVM is busy.
   */
  command error_t bufferErase ();

  /**
   * Reads a single byte from the EEPROM.
   *
   * @param addr The (zero-based) EEPROM address to read from.
   * @param dst Destination buffer for the read byte.
   * @returns SUCCESS if the read succeeded, FAIL if the NVM is busy (dst is
   *  left untouched).
   */
  command error_t readByte (eeprom_addr_t addr, uint8_t *dst);

  /**
   * Begins an erase of all EEPROM pages. Only page locations tagged by
   * bufferLoadByte() will be erased.
   * Until the done() event is signalled, all further operations will fail.
   *
   * @returns SUCCESS if the erase was commenced, FAIL if the NVM is busy.
   */
  command error_t eraseAll ();

  /**
   * Begins an erase of a single EEPROM page. Only locations tagged by
   * bufferLoadByte() will be erased.
   * Until the done() event is signalled, all further operations will fail.
   *
   * @param addr EEPROM address pointing to the start of the page to erase.
   * @returns SUCCESS if the erase was commenced, FAIL if the NVM is busy.
   */
  command error_t erasePage (eeprom_addr_t addr);

  /**
   * Commences a write of the EEPROM page buffer data into the specified page.
   * Only locations tagged by bufferLoadByte() will be written.
   * Until the done() event is signalled, all further operations will fail.
   *
   * @param addr EEPROM address pointing to the start of the page to write.
   * @returns SUCCESS if the write was commenced, FAIL if the NVM is busy.
   */
  command error_t writePage (eeprom_addr_t addr);

  /**
   * Commences an erase+write operation, writing the data from the EEPROM page
   * buffer. Only locations tagged by bufferLoadByte() will be written.
   * Until the done() event is signalled, all further operations will fail.
   *
   * @param addr EEPROM address pointing to the start of the page to write.
   * @returns SUCCESS if the write was commenced, FAIL if the NVM is busy.
   */
  command error_t eraseWritePage (eeprom_addr_t addr);

  /**
   * Signalled when a successfully commenced split-phase operation completes.
   */
  async event void done ();
}
