configuration Aes128C
{
  provides interface BlockCipher<cipherblock128_t>;
}

implementation
{
  components HplAtxm256AesC;
  components Aes128P;

  Aes128P.HplAes -> HplAtxm256AesC;
  BlockCipher = Aes128P;
}

  
