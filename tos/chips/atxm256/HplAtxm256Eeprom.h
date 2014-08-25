#ifndef _HPLATXM256_EEPROM_H
#define _HPLATXM256_EEPROM_H
typedef uint16_t eeprom_addr_t;
typedef uint8_t eeprom_offs_t;

// volume layout, in pages
typedef struct eeprom_volume_info_t {
  uint8_t base;
  uint8_t size;
} eeprom_volume_info_t;

#endif
