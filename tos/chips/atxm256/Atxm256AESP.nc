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

module Atxm256AESP
{
  provides interface Atxm256AES;
  uses interface HplAtxm256AES as HAES;
}
implementation
{
  uint8_t key[16];
  uint8_t rev_key[16];
  bool    key_valid=FALSE;
  bool    rev_valid=FALSE;

  void aes128_loadKey_raw (uint8_t* key_in) @C() @spontaneous()
  {
    memcpy(key,key_in,16);
    key_valid=TRUE;
    rev_valid=FALSE;
  }

  command void Atxm256AES.loadKey (uint8_t* key_in)
  {
    aes128_loadKey_raw(key_in);
  }
  
  error_t aes128_encrypt_raw(uint8_t* data, uint8_t* target, size_t len) @C() @spontaneous()
  {
    error_t res;
    uint8_t buf[16];

    if (!key_valid)
      return FAIL;
    
    while (len>=16)
    {
      call HAES.prepareAES(TRUE);
      call HAES.loadKey(key);
      call HAES.loadData(data,FALSE);
      res=call HAES.performAES();
      if (res!=SUCCESS)
        return res;
      call HAES.readData(target);
      len-=16;
      target+=16;
      data+=16;
    }
    
    if (len)
    {
      // Partial block
      memset(buf,0,16);
      memcpy(buf,data,len);
      call HAES.prepareAES(TRUE);
      call HAES.loadKey(key);
      call HAES.loadData(buf,FALSE);
      res=call HAES.performAES();
      if (res!=SUCCESS)
        return res;
      call HAES.readData(buf);
      memcpy(target,buf,len);
    }
    return SUCCESS;
  }
  
  command error_t  Atxm256AES.encrypt (uint8_t* data, uint8_t* target, size_t len)
  {
    return aes128_encrypt_raw(data,target,len);
  }

  error_t aes128_decrypt_raw(uint8_t* data, uint8_t* target, size_t len) @C() @spontaneous()
  {
    error_t res;
    uint8_t buf[16];
    
    if (!key_valid)
    {
      return FAIL;
    }
    
    if (!rev_valid)
    {
      call HAES.prepareAES(TRUE);
      call HAES.loadKey(key);
      call HAES.loadData(buf,FALSE);
      res=call HAES.performAES();
      if (res!=SUCCESS)
      {
        return res;
      }
      call HAES.readData(buf); // Need to read the data, even if we don't care!
      call HAES.readKey(rev_key);
      rev_valid=TRUE;
    }
    
    while (len>=16)
    {
      call HAES.prepareAES(FALSE);
      call HAES.loadKey(rev_key);
      call HAES.loadData(data,FALSE);
      res=call HAES.performAES();
      if (res!=SUCCESS)
      {
        return res;
      }
      call HAES.readData(target);
      len-=16;
      target+=16;
      data+=16;
    }
    
    if (len)
    {
      // Partial block
      memset(buf,0,16);
      memcpy(buf,data,len);
      call HAES.prepareAES(FALSE);
      call HAES.loadKey(rev_key);
      call HAES.loadData(buf,FALSE);
      res=call HAES.performAES();
      if (res!=SUCCESS)
      {
        return res;
      }
      call HAES.readData(buf);
      memcpy(target,buf,len);
    }
    return SUCCESS;
  }
  
  command error_t  Atxm256AES.decrypt (uint8_t* data, uint8_t* target, size_t len)
  {
    return aes128_decrypt_raw(data,target,len);
  }

  error_t createEncryptionBlock(uint8_t* buf, bool flag0, uint8_t Mish,
                             uint8_t L, size_t val, uint8_t* nonce)
  {
    uint8_t flags;
    uint8_t i;
    error_t res;
    

    if (!key_valid)
      return FAIL;

    flags=
      ((flag0) <<6)                | // AData
      (Mish<<3)                    | // M
      ((L-1)<<0);                    // L
    buf[0]=flags;
    for (i=0;i<15-L;i++)
      buf[i+1]=nonce[i];
    for (;i<13;i++)
      buf[i+1]=0;
    if (i==13)
      buf[(i++)+1]=val>>8;
    if (i==14)
      buf[i+1]=val;
    
    call HAES.prepareAES(TRUE);
    call HAES.loadKey(key);
    call HAES.loadData(buf,FALSE);
    res=call HAES.performAES();
    if (res!=SUCCESS)
      return res;
    call HAES.readData(buf); // dummy
    return SUCCESS;
  }
  
  error_t aes128_sign_raw(uint8_t* a, size_t alen, uint8_t* m, size_t mlen,
                          uint8_t* target, uint8_t M, uint8_t L, uint8_t* nonce) @C() @spontaneous()
  {
    uint8_t buf[16];
    uint8_t i;
    error_t res;
    
    // We only handle simple l(a) encoding
    if (alen>=0xff00)
      return FAIL;
    res=createEncryptionBlock(buf,
                              (alen>0),
                              (M?(((M-2)/2)):0),
                              L,
                              mlen,
                              nonce);
    if (res!=SUCCESS)
      return res;
    // state now contains X1. Next, AuthData
    i=0;
    if (alen)
    {
      buf[0]=alen>>8;
      buf[1]=alen;
      i=2;
    }


    while (alen)
    {
      while (alen && i<16)
      {
        buf[i++]=*(a++);
        alen--;
      }
      while (i<16)
        buf[i++]=0;

      call HAES.prepareAES(TRUE);
      call HAES.loadKey(key);
      call HAES.loadData(buf,TRUE);
      res=call HAES.performAES();
      if (res!=SUCCESS)
        return res;
      call HAES.readData(buf); // dummy
      i=0;
    }
    // Done with addauthdata. Now, m
    
    while (mlen)
    {
      while (mlen && i<16)
      {
        buf[i++]=*(m++);
        mlen--;
      }
      while (i<16)
        buf[i++]=0;
      call HAES.prepareAES(TRUE);
      call HAES.loadKey(key);
      call HAES.loadData(buf,TRUE);
      res=call HAES.performAES();
      if (res!=SUCCESS)
        return res;
      call HAES.readData(buf); // dummy, except for the last time
      i=0;
    }
    
    memcpy(target,buf,M); // Note --- this is the *un*encrypted authentication tag
    return SUCCESS;
  }
  
  
  command error_t  Atxm256AES.sign(uint8_t* a, size_t alen, uint8_t* m, size_t mlen,
                                   uint8_t* target, uint8_t M, uint8_t L, uint8_t* nonce)
  {
    return sign_raw(a,alen,m,mlen,target,M,L,nonce);
  }

  error_t ccm_encode_raw(uint8_t* data, size_t len, size_t start_index, uint8_t L, uint8_t* nonce)  @C() @spontaneous()
  {
    uint8_t buf[16];
    
    while (len)
    {
      uint8_t j;
      
      error_t res=createEncryptionBlock(buf,FALSE,0,L,start_index,nonce);
      if (res!=SUCCESS)
        return res;
      j=0;
      while (len && j<16)
      {
        (*data++)^=buf[j++];
        len--;
      }
      start_index++;
    }
    return SUCCESS;
  }

  command error_t Atxm256AES.ccm_encode(uint8_t* data, size_t len, size_t start_index, uint8_t L, uint8_t* nonce)
  {
    return ccm_encode_raw(data,len,start_index,L,nonce);
  }
  
  
}
