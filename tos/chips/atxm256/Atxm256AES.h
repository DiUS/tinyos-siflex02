#ifndef ATXM256AES_H
#define ATXM256AES_H

#ifndef AES_SUPPORT_ENCRYPTION
# define AES_SUPPORT_ENCRYPTION 1
#endif
#ifndef AES_SUPPORT_DECRYPTION
# define AES_SUPPORT_DECRYPTION 1
#endif

#if defined(AES_SUPPORT_ENCRYPTION) && AES_SUPPORT_ENCRYPTION
extern error_t aes128_encrypt_raw(uint8_t* data, uint8_t* target, size_t len) @C() @spontaneous();
#endif

#if defined(AES_SUPPORT_DECRYPTION) && AES_SUPPORT_DECRYPTION
extern error_t aes128_decrypt_raw(uint8_t* data, uint8_t* target, size_t len) @C() @spontaneous();
#endif

extern void aes128_loadKey_raw (uint8_t* key_in) @C() @spontaneous();


extern error_t sign_raw(uint8_t* a, size_t alen, uint8_t* m, size_t mlen,
                        uint8_t* target, uint8_t M, uint8_t L, uint8_t* nonce) @C() @spontaneous();
extern error_t ccm_encode_raw(uint8_t* data, size_t len, size_t start_index, uint8_t L,
                              uint8_t* nonce)  @C() @spontaneous();
#endif
