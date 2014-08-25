/*
 * Copyright 2011 Dius Computing Pty Ltd. All rights reserved.
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
 * - Neither the name of the copyright holders nor the names of
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
 *
 * @author Johny Mattsson <jmattsson@dius.com.au>
 */

#include "flash_driver.h"

module ProgFlashC
{
  provides interface ProgFlash;
}
implementation
{

/* We expose the flash_read()/flash_write() functions for application use too.
 * This means that if their addresses ever change, the applications will break.
 * To minimise the risk of this, we put each of them into separate sections,
 * which we then put at well-known addresses).
 */
#define FLASH_READ __attribute__ ((section (".flashread")))
#define FLASH_WRITE __attribute__ ((section (".flashwrite")))

/* Prevent nesc/avr-gcc/avr-ld from omitting the flash driver API functions
 * in case it sees they're not actually used.
 */
#define API @C() @spontaneous()


  inline void wait_for_nvm () { while (NVM.STATUS & NVM_NVMBUSY_bm) {} }

  // Note: elpm can auto-inc RAMPZ:Z, which would produce a better flash_read
  // function, but at the expense of having to write all of flash_read in asm.
  uint8_t flash_read_byte (uint32_t addr)
  {
    uint8_t byte;
    NVM_CMD = NVM_CMD_NO_OPERATION_gc;
    asm (
      "lds __tmp_reg__, %2    \n\t"  // load original RAMPZ
      "movw r30, %A1          \n\t"  // store lower address word in Z (r30:r31)
      "sts %2, %C1            \n\t"  // store upper address word in RAMPZ
      "elpm %0, Z             \n\t"  // load flash byte
      "sts %2, __tmp_reg__    \n\t"  // restore RAMPZ
      : "=r" (byte)
      : "r" (addr),
        "i" (_SFR_MEM_ADDR(RAMPZ))
      : "r30", "r31"
    );
    return byte;
  }

  void flash_read (uint32_t addr, void *buf, uint32_t len) FLASH_READ API
  {
    uint8_t *out = buf;
    uint8_t sreg = SREG;
    cli ();
    wait_for_nvm ();
    for (; len; --len, ++addr)
      *out++ = flash_read_byte (addr);
    SREG = sreg;
  }


  AVR_ATOMIC_HANDLER(NVM_SPM_vect)
  {
    // Disable SPM interrupt
    NVM.INTCTRL = 0;
  }

  typedef enum { WORKAROUND_PREPARE, WORKAROUND_FINALISE } WorkaroundOp;
  void workaround (WorkaroundOp op)
  {
    // MASSIVE WORKAROUND DUE TO AVR1008 ERRATA!

    // Register saves static in here, to avoid having to declare another segment
    static uint8_t sleep_ctrl, pmic_status, pmic_ctrl, sreg, nvm_intctrl;

    if (op == WORKAROUND_PREPARE)
    {
      uint8_t new_pmic_ctrl;

      // Disable interrupts while we set things up
      sreg        = SREG;
      cli ();

      sleep_ctrl  = SLEEP.CTRL;
      pmic_status = PMIC.STATUS;
      pmic_ctrl   = PMIC.CTRL;
      nvm_intctrl = NVM.INTCTRL;

      // Enable IDLE sleep mode
      SLEEP.CTRL = SLEEP_SMODE_IDLE_gc;

      // Ensure only high level interrupts are enabled, and the vector
      // location is pointing to the boot section table
      new_pmic_ctrl = 
        (pmic_ctrl & ~(PMIC_MEDLVLEN_bm | PMIC_LOLVLEN_bm)) | PMIC_HILVLEN_bm
        | PMIC_IVSEL_bm;

      CCP = CCP_IOREG_gc;         // changing ISR table requires CCP_IOREG
      PMIC.CTRL = new_pmic_ctrl;

      // TODO: Ensure no other high level interrupts are enabled!
      //   If anything other than the NVM SPM interrupts wakes the MCU the
      //   chip will reset (and if it doesn't, it'll hit a dud ISR anyway)

      // By now, the only interrupt we can get should be the SPM one

      // Prepare for sleep, so ensure interrupts are enabled
      sei();
      SLEEP.CTRL |= SLEEP_SEN_bm;
    }
    else // WORKAROUND_FINALISE
    {
      // Restore registers (and potentially swap ISR table back)
      SLEEP.CTRL  = sleep_ctrl;
      PMIC.STATUS = pmic_status;
      CCP         = CCP_IOREG_gc; // changing ISR table requires CCP_IOREG
      PMIC.CTRL   = pmic_ctrl;
      NVM.INTCTRL = nvm_intctrl;
      SREG        = sreg;
    }
  }

  void flash_exec_spm (uint8_t cmd, uint32_t addr)
  {
    workaround (WORKAROUND_PREPARE);

    asm volatile (
      "sts   %0, %5      \n\t"      // store command into NVM_CMD
      "movw r30, %A6     \n\t"      // store bottom 16bits into Z (r30:r31)
      "sts   %1, %C6     \n\t"      // store top 8 bits into RAMPZ
      "sts   %3, %4      \n\t"      // write CCP signature to enable SPM
      "spm               \n\t"      // program
      "sts   %2, %7      \n\t"      // enable SPM interrupt
      "sleep             \n\t"      // sleep before the SPM kills us
      "clr   r1          \n\t"      // restore __zero_reg__ manually
      :
      : "i" (_SFR_MEM_ADDR(NVM_CMD)),
        "i" (_SFR_MEM_ADDR(RAMPZ)),
        "i" (_SFR_MEM_ADDR(NVM_INTCTRL)),
        "i" (_SFR_MEM_ADDR(CCP)),
        "r" (CCP_SPM_gc),
        "r" (cmd),
        "r" (addr),
        "r" (NVM_SPMLVL_HI_gc)
      : "r30", "r31"
    );

    workaround (WORKAROUND_FINALISE);
  }

  void flash_load_word (uint32_t addr, uint16_t word)
  {
    // When we're loading into the page buffer, that word goes into r1:r0, also
    // known as __zero_reg__,__tmp_reg__. While we don't need to worry about
    // restoring __tmp_reg__, we do need to restore __zero_reg__ - it seems
    // gcc doesn't do it even if we define it as being clobbered.
    asm (
      "movw  r0, %4     \n\t"       // store word into r1:r0
      "sts   %0, %2     \n\t"       // store command into NVM_CMD
      "movw r30, %A3    \n\t"       // store bottom 16 bits into Z
      "sts   %1, %C3    \n\t"       // store top 8 bits into RAMPZ
      "spm              \n\t"       // program
      "clr   r1         \n\t"       // "restore" __zero_reg__
      :
      : "i" (_SFR_MEM_ADDR(NVM_CMD)),
        "i" (_SFR_MEM_ADDR(RAMPZ)),
        "r" (NVM_CMD_LOAD_FLASH_BUFFER_gc),
        "r" (addr),
        "r" (word)
      : "r30", "r31"
    );
  }

  void flash_write (uint32_t addr, void *buf, uint32_t len) FLASH_WRITE API
  {
    uint8_t *src = buf;

    // Wait for NVM to become idle
    while (NVM.STATUS & NVM_NVMBUSY_bm) {}

    while (len)
    {
      uint16_t page_offs = (addr % PROGMEM_PAGE_SIZE); 
      uint32_t page_start_addr = (addr - page_offs);
      uint16_t bytes_to_load = PROGMEM_PAGE_SIZE - page_offs;
      uint16_t i;

      if (bytes_to_load > len)
        bytes_to_load = len;

      // erase page buffer
      NVM.CMD = NVM_CMD_ERASE_FLASH_BUFFER_gc;
      NVM.CTRLA = NVM_CMDEX_bm;
      while (NVM.STATUS & NVM_NVMBUSY_bm) {}

      // load page buffer
      // TODO: make this support odd start addresses as well (pad 0xff at start)
      for (i = 0; i < bytes_to_load; i += 2, src += 2)
      {
        union {
          uint8_t byte[2];
          uint16_t word;
        } load;

        load.byte[0] = src[0];
        load.byte[1] = i < (bytes_to_load - 1) ? src[1] : 0xff;

        flash_load_word (page_offs + i, load.word);
      }

      // program page
      flash_exec_spm (NVM_CMD_ERASE_WRITE_APP_PAGE_gc, page_start_addr);

      len -= bytes_to_load;
      addr += bytes_to_load;
    }
  }


  command error_t ProgFlash.write (in_flash_addr_t addr, uint8_t *buf, in_flash_addr_t len)
  {
    if (addr + len > TOSBOOT_START)
       return FAIL;

    flash_write (addr, buf, len);
    return SUCCESS;
  }
}
