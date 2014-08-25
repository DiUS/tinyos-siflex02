#ifndef _HARDWARE_H_
#define _HARDWARE_H_

#include "atxm256hardware.h"

typedef uint32_t in_flash_addr_t;
typedef uint32_t ex_flash_addr_t;

/* A plain siflex02 has no LEDs */
#define TOSH_SET_PIN_DIRECTIONS()
#define TOSH_CLR_GREEN_LED_PIN()
#define TOSH_SET_GREEN_LED_PIN()
#define TOSH_CLR_YELLOW_LED_PIN()
#define TOSH_SET_YELLOW_LED_PIN()
#define TOSH_CLR_RED_LED_PIN()
#define TOSH_SET_RED_LED_PIN()

static inline void wait( uint16_t dt )
{
  while (dt--)
    asm (
      "nop\n\t"
      "nop\n\t"
      "nop\n\t"
      "nop\n\t"
    );
}

#endif
