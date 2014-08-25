#ifndef BLOCKCIPHER_H
#define BLOCKCIPHER_H

// These data structures are used with the generic BlockCipher interface
#define makeCipherBlock(bits)    \
   typedef struct                \
   {                             \
      uint8_t data[(bits+7)/8];  \
   } cipherblock##bits##_t

makeCipherBlock(64);
makeCipherBlock(128);
makeCipherBlock(256);
makeCipherBlock(0);

typedef cipherblock0_t cipherblock_t;

#endif
