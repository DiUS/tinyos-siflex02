/*
 * atxm256hardware.h
 *
 * The ATXMEGA256 hardware header.
 *
 * This is based on the atm128 hardware header.
 *
 * Copyright 2011 Dius Computing Pty Ltd. All rights reserved.
 */

/*                                                                     
 *  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.  By
 *  downloading, copying, installing or using the software you agree to
 *  this license.  If you do not agree to this license, do not download,
 *  install, copy or use the software.
 *
 *  Copyright (c) 2004-2005 Crossbow Technology, Inc.
 *  Copyright (c) 2002-2003 Intel Corporation.
 *  Copyright (c) 2000-2003 The Regents of the University  of California.    
 *  All rights reserved.
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
 * - Neither the name of the copyright holder nor the names of
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

#ifndef _H_atxm256hardware_H
#define _H_atxm256hardware_H

#include <avr/io.h>
#if __AVR_LIBC_VERSION__ >= 10400UL
#include <avr/interrupt.h>
#else
#include <avr/interrupt.h>
#include <avr/signal.h>
#endif
#include <avr/wdt.h>
#include <avr/pgmspace.h>


/* Handle interrupt with interrupts disabled. */
#define AVR_ATOMIC_HANDLER(signame) \
ISR(signame) @atomic_hwevent() @C()

/* Handle interrupt with interrupts enabled. */
#define AVR_NONATOMIC_HANDLER(signame) \
ISR(signame, ISR_NOBLOCK) @hwevent() @C()


/* Convenience macro for implementing HplAtxm256Interrupt. */
#define _ATXM256_ISR(name, module, \
                     int_ctrl, enable_bits, disable_bits, \
                     int_flags, test_bits) \
  inline async command void name.enable()    { module.int_ctrl |= enable_bits; } \
  inline async command void name.disable()   { module.int_ctrl &= ~disable_bits; } \
  inline async command bool name.isEnabled() {  \
    return (module.int_ctrl & disable_bits) ? TRUE : FALSE;  \
  } \
  inline async command void name.reset()     { module.int_flags |= test_bits; } \
  inline async command bool name.test() {  \
    return (module.int_flags & test_bits) ? TRUE : FALSE; \
  } \
  default async event void name.fired() { }

/* Implement HplAtxm256Interrupt. */
#define ATXM256_ISR(name, module, \
                     int_ctrl, enable_bits, disable_bits, \
                     int_flags, test_bits, int_vector) \
  _ATXM256_ISR(name, module, \
                     int_ctrl, enable_bits, disable_bits, \
                     int_flags, test_bits) \
  AVR_NONATOMIC_HANDLER(int_vector) { \
    signal name.fired(); \
  } \

/* Implement HplAtxm256Interrupt and reset the interrupt flag when the
   interrupt fires. */
#define ATXM256_RESET_ISR(name, module, \
                     int_ctrl, enable_bits, disable_bits, \
                     int_flags, test_bits, int_vector) \
  _ATXM256_ISR(name, module, \
                     int_ctrl, enable_bits, disable_bits, \
                     int_flags, test_bits) \
  AVR_NONATOMIC_HANDLER(int_vector) { \
    call name.reset(); \
    signal name.fired(); \
  } \


/* Convenience macro for implementing power on/off for a particular module. */
#define ATXM256_PR_ONOFF(name, pr, bm) \
  async command void name.on()   { pr &= ~bm; } \
  async command void name.off()  { pr |= bm;  } \
  async command bool name.isOn() { (pr & bm) ? TRUE : FALSE; }


/* const_[u]int[8/16/32]_t types are used to declare single and array
 * constants that should live in ROM/FLASH. These constants must be read
 * via the corresponding read_[u]int[8/16/32]_t macros. */

typedef uint8_t  const_uint8_t  PROGMEM;
typedef uint16_t const_uint16_t PROGMEM;
typedef uint32_t const_uint32_t PROGMEM;
typedef int8_t   const_int8_t   PROGMEM;
typedef int16_t  const_int16_t  PROGMEM;
typedef int32_t  const_int32_t  PROGMEM;

#define read_uint8_t(x)  pgm_read_byte(x)
#define read_uint16_t(x) pgm_read_word(x)
#define read_uint32_t(x) pgm_read_dword(x)

#define read_int8_t(x)  ( (int8_t)pgm_read_byte(x) )
#define read_int16_t(x) ((int16_t)pgm_read_word(x) )
#define read_int32_t(x) ((int32_t)pgm_read_dword(x))


/* Enables interrupts. */
inline void __nesc_enable_interrupt() @safe() {
    sei();
}

/* Disables all interrupts. */
inline void __nesc_disable_interrupt() @safe() {
    cli();
}

/* Defines data type for storing interrupt mask state during atomic. */
typedef uint8_t __nesc_atomic_t;
__nesc_atomic_t __nesc_atomic_start(void);
void __nesc_atomic_end(__nesc_atomic_t original_SREG);

#ifndef NESC_BUILD_BINARY
/* @spontaneous() functions should not be included when NESC_BUILD_BINARY
   is #defined, to avoid duplicate functions definitions when binary
   components are used. Such functions do need a prototype in all cases,
   though. */
# define ATOMIC_TAG @spontaneous()
#else
# define ATOMIC_TAG __attribute__((always_inline))
#endif

/* Saves current interrupt mask state and disables interrupts. */
inline __nesc_atomic_t 
__nesc_atomic_start(void) ATOMIC_TAG @safe()
{
    __nesc_atomic_t result = SREG;
    __nesc_disable_interrupt();
    asm volatile("" : : : "memory"); /* ensure atomic section effect visibility */
    return result;
}

/* Restores interrupt mask to original state. */
inline void 
__nesc_atomic_end(__nesc_atomic_t original_SREG) ATOMIC_TAG @safe()
{
  asm volatile("" : : : "memory"); /* ensure atomic section effect visibility */
  SREG = original_SREG;
}


/* TinyOS power type for atxmega power management. */
typedef uint8_t mcu_power_t @combine("mcombine");

/* xmega power states ordered from least power saving to most power saving. */
enum {
  ATXM256_POWER_IDLE = 0,
  ATXM256_POWER_SAVING,
  ATXM256_POWER_DOWN
};

/* Combine function for xmega power states. 
 * The result state is the least power saving state. */
mcu_power_t mcombine(mcu_power_t m1, mcu_power_t m2) @safe() {
  return (m1 < m2) ? m1: m2;
}


/* Floating-point network-type support.
   These functions must convert to/from a 32-bit big-endian integer that follows
   the layout of Java's java.lang.float.floatToRawIntBits method.
   Conveniently, for the AVR family, this is a straight byte copy...
*/


typedef float nx_float __attribute__((nx_base_be(afloat)));

inline float __nesc_ntoh_afloat(const void *COUNT(sizeof(float)) source) @safe() {
  float f;
  memcpy(&f, source, sizeof(float));
  return f;
}

inline float __nesc_hton_afloat(void *COUNT(sizeof(float)) target, float value) @safe() {
  memcpy(target, &value, sizeof(float));
  return value;
}

#endif //_H_atxm256hardware_H
