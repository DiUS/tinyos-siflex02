#ifndef _FLASH_H
#define _FLASH_H

void flash_read (uint32_t addr, void *buf, uint32_t len);
void flash_write (uint32_t addr, void *buf, uint32_t len);

#endif
