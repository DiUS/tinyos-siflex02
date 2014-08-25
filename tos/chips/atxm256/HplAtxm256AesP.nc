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

module HplAtxm256AesP
{
  provides interface HplAtxm256Aes;
}
implementation
{
  inline bool aes_finished ()
  {
    return AES.STATUS & (AES_ERROR_bm | AES_SRIF_bm);
  }

  inline bool aes_valid ()
  {
    return AES.STATUS & AES_SRIF_bm;
  }

  inline bool aes_error ()
  {
    return AES.STATUS & AES_ERROR_bm;
  }

  command void HplAtxm256Aes.prepareAES(bool encrypt)
  {
    AES.CTRL=encrypt?0:AES_DECRYPT_bm;
  }
  
  command void HplAtxm256Aes.loadKey (const uint8_t* key)
  {
    uint8_t i;
    for (i=0;i<16;i++)
      AES.KEY=key[i];
  }

  command void HplAtxm256Aes.readKey (uint8_t* key)
  {
    uint8_t i;
    for (i=0;i<16;i++)
      key[i]=AES.KEY;
  }

  command void HplAtxm256Aes.loadData (const uint8_t* data, bool xor)
  {
    uint8_t i;
    
    if (xor)
      AES.CTRL|=AES_XOR_bm;
    for (i=0;i<16;i++)
      AES.STATE=data[i];
  }

  command void HplAtxm256Aes.readData (uint8_t* data)
  {
    uint8_t i;
    for (i=0;i<16;i++)
      data[i]=AES.STATE;
  }

  command error_t HplAtxm256Aes.performAES()
  {
    AES.CTRL|=AES_START_bm;
    while (!aes_finished())
      ;
    return aes_valid()?SUCCESS:FAIL;
  }
}
