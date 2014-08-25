#ifndef _ATXM256_FLASH_H_
#define _ATXM256_FLASH_H_

enum { ATXM256_FLASH_PAGE_SIZE = 512 };

typedef uint32_t flash_addr_t;
typedef uint32_t flash_offs_t;
typedef uint16_t flash_page_t;

// base and size specified in page-number and page-count, respectively
typedef struct
{
  flash_page_t base;
  flash_page_t size;
} flash_volume_info_t;

#endif
