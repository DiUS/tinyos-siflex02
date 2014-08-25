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
 * @author Bernd Meyer <bmeyer@dius.com.au>
 */

interface HplAtxm256Aes
{
  /**
   * Initial setup of AES module for encryption/decryption
   *
   * @param encrypt TRUE for encryption, FALSE for decryption
   */
  command void prepareAES(bool encrypt);

  /**
   *
   * Loads a 16 byte key into AES module   
   *
   * @param key The key to load.
   */
  command void loadKey (const uint8_t* key);

  /**
   *
   * Reads a 16 byte key from the AES module. This is used to
   * read out the decryption key at the end of an encryption
   * cycle
   *
   * @param key Where to save the key.
   */
  command void readKey (uint8_t* key);

  /**
   *
   * Loads a 16 byte cleartext/cyphertext into AES module   
   *
   * @param data The data to load.
   * @param xor  Whether to XOR the new data with the data in the buffer
   */
  command void loadData (const uint8_t* data, bool xor);

  /**
   *
   * Reads a 16 byte data buffer from the AES module. This is used to
   * read back the encrypted/decrypted data after the AES module has
   * done its job
   *
   * @param key Where to save the key.
   */
  command void readData(uint8_t* data);

  /**
   * Executes an encryption/decryption
   *
   * @returns SUCCESS if the operation succeeded, FAIL for any failure
   */
  command error_t performAES();
}
