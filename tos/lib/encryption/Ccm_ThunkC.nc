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
module Ccm_ThunkC
{
  uses interface CcmStar<cipherblock128_t,nx_uint16_t>;
  uses interface RadioConfigExternalAccess as Config;
}

implementation
{
  error_t blip_ccm_encode(const uint8_t* nonce,
                          const uint8_t* a, size_t alen,
                          uint8_t* m, size_t mlen,
                          uint8_t* signature, uint8_t M) @C() @spontaneous()
  {
    return call CcmStar.encode(&(call Config.getConfig())->cipher_key,nonce,a,alen,m,mlen,signature,M);
  }
  
  error_t blip_ccm_decode(const uint8_t* nonce,
                          const uint8_t* a, size_t alen,
                          uint8_t* m, size_t mlen,
                          uint8_t* signature, uint8_t M) @C() @spontaneous()
  {
    return call CcmStar.decode(&(call Config.getConfig())->cipher_key,nonce,a,alen,m,mlen,signature,M);
  }

  uint8_t blip_ccm_security_mode(void) @C() @spontaneous()
  {
    return (call Config.getConfig())->used_security;
  }

  uint8_t blip_ccm_accepted_modes(void) @C() @spontaneous()
  {
    return (call Config.getConfig())->accepted_security;
  }
}
