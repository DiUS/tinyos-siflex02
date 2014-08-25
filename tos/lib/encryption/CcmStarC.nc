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
 */
generic module CcmStarC(typedef block_t,typedef nxL @integer())
{
  provides interface CcmStar<block_t,nxL>;
  uses interface BlockCipher<block_t>;
}

#define DATA(x) (((cipherblock_t*)(x))->data)

implementation
{
  error_t createEncryptionBlock(const block_t* key, const uint8_t* nonce,
                                bool flag0, uint8_t Mish, const nxL* val,
                                block_t* buf)
  {
    uint8_t flags;
    uint8_t* wbuf=DATA(buf);
    
    flags=
      ((flag0) <<6)                | // AData
      (Mish<<3)                    | // M
      ((sizeof(nxL)-1)<<0);          // L
    *wbuf++=flags;
    memcpy(wbuf,nonce,sizeof(block_t)-sizeof(nxL)-1);
    wbuf+=sizeof(block_t)-sizeof(nxL)-1;
    *((nxL*)wbuf)=*val;

    return call BlockCipher.encrypt(key,buf,buf);
  }

  error_t chainData(const block_t* key, const uint8_t* nonce,
                    const uint8_t* data, size_t len, uint8_t firstIndex,
                    block_t* buf)
  {
    uint8_t i=firstIndex;
    
    while (len)
    {
      error_t res;
      
      while (len && i<sizeof(block_t))
      {
        DATA(buf)[i++]=*(data++);
        len--;
      }
      while (i<sizeof(block_t))
        DATA(buf)[i++]=0;

      res=call BlockCipher.encrypt_chained(key,buf,buf);
      if (res!=SUCCESS)
        return res;
      i=0;
    }
    return SUCCESS;
  }
  
  error_t createSignature(const block_t* key, const uint8_t* nonce,
                          const uint8_t* a, size_t alen,
                          const uint8_t* m, size_t mlen,
                          uint8_t* target, uint8_t M)
  {
    block_t buf;
    uint8_t i;
    error_t res;
    nxL nx_mlen;

    nx_mlen=mlen;
    
    // We only handle simplest case of encoding l(a)
    if (alen>=0xff00U)
      return FAIL;
    res=createEncryptionBlock(key,nonce,
                              (alen>0),
                              (M?(((M-2)/2)):0),
                              &nx_mlen,
                              &buf);
    if (res!=SUCCESS)
      return res;
    // the blockcipher state for encrypt_chained now contains X1. Next, AuthData
    i=0;
    if (alen)
    {
      DATA(&buf)[0]=alen>>8;
      DATA(&buf)[1]=alen;
      i=2;
    }
    res=chainData(key,nonce,a,alen,i,&buf);
    if (res!=SUCCESS)
      return res;
    res=chainData(key,nonce,m,mlen,0,&buf);
    if (res!=SUCCESS)
      return res;
    memcpy(target,DATA(&buf),M); // Note --- this is the *un*encrypted authentication tag
    return SUCCESS;
  }
  
  error_t ccmEncrypt(const block_t* key, const uint8_t* nonce,
                     uint8_t* data, size_t len, size_t start_index)
  {
    block_t buf;
    nxL index;

    index=start_index;
    while (len)
    {
      uint8_t j;
      
      error_t res=createEncryptionBlock(key,nonce,
                                        FALSE,0,&index,
                                        &buf);
      if (res!=SUCCESS)
        return res;
      j=0;
      while (len && j<sizeof(block_t))
      {
        (*data++)^=DATA(&buf)[j++];
        len--;
      }
      index++;
    }
    return SUCCESS;
  }

  command error_t CcmStar.encode(const block_t* key, const uint8_t* nonce,
                                 const uint8_t* a, size_t alen,
                                 uint8_t* m, size_t mlen,
                                 uint8_t* signature, uint8_t M)
  {
    if (M)
    {
      error_t res;
      
      res=createSignature(key,nonce,a,alen,m,mlen,signature,M);
      if (res!=SUCCESS)
        return res;
      res=ccmEncrypt(key,nonce,signature,M,0);
      if (res!=SUCCESS)
        return res;
    }
    return ccmEncrypt(key,nonce,m,mlen,1);
  }



  command error_t CcmStar.decode(const block_t* key, const uint8_t* nonce,
                                 const uint8_t* a, size_t alen,
                                 uint8_t* m, size_t mlen,
                                 uint8_t* signature, uint8_t M)
  {
    error_t res=ccmEncrypt(key,nonce,m,mlen,1);
    if (res!=SUCCESS)
      return res;
    
    if (M)
    {
      uint8_t newsig[16];
      
      res=ccmEncrypt(key,nonce,signature,M,0); 
      if (res!=SUCCESS)
        return res;
      res=createSignature(key,nonce,a,alen,m,mlen,newsig,M);
      if (res!=SUCCESS)
        return res;
      if (memcmp(signature,newsig,M)!=0)
        return FAIL;
    }
    return SUCCESS;
  }
}

  
