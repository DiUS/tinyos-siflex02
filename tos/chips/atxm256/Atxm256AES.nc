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

interface Atxm256AES
{
  /**
   *
   * Loads a 16 byte key into AES module. Must be done prior to any encode/decode,
   * but need not be redone for each
   *
   * @param key The key to load.
   */
  command void loadKey (uint8_t* key);

  /**
   *
   * Performs AES128 encryption, potentially in place
   *
   * @param data    The data to encrypt
   * @param target  Destination to store encrypted data. Must be equal to data, or not overlap
   * @param length  number of bytes to encrypt
   * @returns SUCCESS if the operation succeeded, FAIL for any failure
   */
  command error_t encrypt (uint8_t* data, uint8_t* target, size_t len);

  /**
   *
   * Performs AES128 decryption, potentially in place
   *
   * @param data    The data to decrypt
   * @param target  Destination to store decrypted data. Must be equal to data, or not overlap
   * @param length  number of bytes to decrypt
   * @returns SUCCESS if the operation succeeded, FAIL for any failure
   */
  command error_t decrypt (uint8_t* data, uint8_t* target, size_t len);

  /**
   *
   * Performs AES128 CCM* signature (M bytes)
   * Note: The signature token return is *unencrypted*
   * 
   * @param a       The 'a' to sign
   * @param alen    length of a, in bytes
   * @param m       The 'm' to sign
   * @param mlen    length of m, in bytes
   * @param target  Destination to store signature, M bytes
   * @param M       The size, in bytes, of the desired signature
   * @param L       The 'L' parameter in CCM*
   * @param nonce   Pointer to 15-L bytes of nonce, application defined
   * @returns SUCCESS if the operation succeeded, FAIL for any failure
   */
  command error_t  sign(uint8_t* a, size_t alen, uint8_t* m, size_t mlen,
                        uint8_t* target, uint8_t M, uint8_t L, uint8_t* nonce);

  /**
   *
   * Performs AES128 CCM* encryption step
   *
   * @param data    The data to encode
   * @param len     length of data, in bytes
   * @param start_index  The first 'i' term for creating encryption blocks. typically 1, or 0 for
   *                the signature.
   * @param L       The 'L' parameter in CCM*
   * @param nonce   Pointer to 15-L bytes of nonce, application defined
   * @returns SUCCESS if the operation succeeded, FAIL for any failure
   */  command error_t ccm_encode(uint8_t* data, size_t len, size_t start_index, uint8_t L, uint8_t* nonce);
}

