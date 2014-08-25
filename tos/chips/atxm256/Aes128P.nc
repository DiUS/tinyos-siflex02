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

module Aes128P
{
  provides interface BlockCipher<cipherblock128_t>;
  uses interface HplAtxm256Aes as HplAes;
}
implementation
{
  error_t doAes (const cipherblock128_t* key, const cipherblock128_t* inData, cipherblock128_t* outData,
                 bool encrypt, bool do_xor)
  {
    error_t res;
    
    call HplAes.prepareAES(encrypt);
    call HplAes.loadKey(key->data);
    call HplAes.loadData(inData->data,do_xor);
    res=call HplAes.performAES();
    if (res!=SUCCESS)
      return res;
    if (outData)
      call HplAes.readData(outData->data);
    return SUCCESS;
  }

  command error_t BlockCipher.encrypt (const cipherblock128_t* key, const cipherblock128_t* plain, cipherblock128_t* cipher)
  {
    return doAes(key,plain,cipher,TRUE,FALSE);
  }
  
  command error_t BlockCipher.encrypt_chained (const cipherblock128_t* key, const cipherblock128_t* plain, cipherblock128_t* cipher)
  {
    return doAes(key,plain,cipher,TRUE,TRUE);
  }
  
  command error_t BlockCipher.decrypt (const cipherblock128_t* key, const cipherblock128_t* cipher, cipherblock128_t* plain)
  {
    return doAes(key,cipher,plain,FALSE,FALSE);
  }
}

