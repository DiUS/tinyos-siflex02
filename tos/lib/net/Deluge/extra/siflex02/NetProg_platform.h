#ifndef _NETPROG_PLATFORM_H_
#define _NETPROG_PLATFORM_H_

#include <avr/wdt.h>

void netprog_reboot ()
{
  asm ("cli  \n\t"
       "jmp 0x40000");
}

#endif
