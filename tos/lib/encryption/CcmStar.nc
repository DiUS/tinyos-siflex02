// nxL is to be a network-byte-order integer type.

interface CcmStar<block_t,nxL @integer()>
{
  // Note: The nonce must be sizeof(block_t)-nxL-1 bytes long (see CCM* standard)
  command error_t encode(const block_t* key, const uint8_t* nonce,
                         const uint8_t* a, size_t alen,
                         uint8_t* m, size_t mlen,
                         uint8_t* signature, uint8_t M);
  command error_t decode(const block_t* key, const uint8_t* nonce,
                         const uint8_t* a, size_t alen,
                         uint8_t* m, size_t mlen,
                         uint8_t* signature, uint8_t M);
}

