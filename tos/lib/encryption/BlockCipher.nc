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

interface BlockCipher<block_t>
{
  /**
   *
   * Performs encryption, potentially in place
   * The *_chained variant XORs the block with the output of the previous encryption
   * 
   * @param key      The encryption key
   * @param plain    The data to encrypt
   * @param cipher   Destination to store encrypted data. Must be equal to plain, or not overlap
   *                 May be NULL, in which case the ciphertext is not returned at all (useful
   *                 when subsequent operations are _chained())
   * @returns SUCCESS if the operation succeeded, FAIL for any failure
   */
  command error_t encrypt (const block_t* key, const block_t* plain, block_t* cipher);
  command error_t encrypt_chained (const block_t* key, const block_t* plain, block_t* cipher);

  /**
   *
   * Performs decryption, potentially in place
   *
   * @param key      The encryption key. Note: This is the *en*cryption key. The cipher module
   *                 may internally transform this into a decryption key.
   * @param cipher   The data to decrypt
   * @param plain    Destination to store decrypted data. Must be equal to cipher, or not overlap
   * @returns SUCCESS if the operation succeeded, FAIL for any failure
   */
  command error_t decrypt (const block_t* key, const block_t* cipher, block_t* plain);
}

