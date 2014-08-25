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

module HplAtxm256EepromP
{
  provides interface HplAtxm256Eeprom;
  provides interface Init;
}
implementation
{
  AVR_NONATOMIC_HANDLER(NVM_EE_vect)
  {
    // disable the EE level interrupt
    NVM.INTCTRL &= ~NVM_EELVL_gm;
    signal HplAtxm256Eeprom.done ();
  }

  inline bool nvm_busy ()
  {
    return NVM.STATUS & NVM_NVMBUSY_bm;
  }

  inline void nvm_load_addr (eeprom_addr_t addr)
  {
      NVM.ADDR0 = (uint8_t)addr & 0xff;
      NVM.ADDR1 = (uint8_t)(addr >> 8);
      NVM.ADDR2 = 0;
  }

  inline void nvm_execute_for_write ()
  {
    // MASSIVE WORKAROUND DUE TO AVR1008 ERRATA!

    // Save various registers
    uint8_t sleep_ctrl, pmic_status, pmic_ctrl, nvm_intctrl;

    atomic {
      sleep_ctrl  = SLEEP.CTRL;
      pmic_status = PMIC.STATUS;
      pmic_ctrl   = PMIC.CTRL;
      nvm_intctrl = NVM.INTCTRL;

      // Enable IDLE sleep mode
      SLEEP.CTRL = SLEEP_SMODE_IDLE_gc;
      // Ensure only high level interrupts are enabled
      PMIC.CTRL =
        (PMIC.CTRL & ~(PMIC_MEDLVLEN_bm | PMIC_LOLVLEN_bm)) | PMIC_HILVLEN_bm;

      // TODO: Ensure no other high level interrupts are enabled!
      //   If anything other than the NVM EEPROM interrupts wakes the MCU the
      //   chip will reset...

      // By now, the only interrupt we can get should be the EEPROM one
      
      // Prepare for sleep, so ensure interrupts are enabled
      sei();
      SLEEP.CTRL |= SLEEP_SEN_bm;
      
      
      // Commence the EEPROM write - the next three lines is all that _should_
      // be needed, if it wasn't for the AVR1008 errata.
      CCP = CCP_IOREG_gc;
      NVM.CTRLA = NVM_CMDEX_bm;
      // enable EE level interrupt
      NVM.INTCTRL = NVM_EELVL_HI_gc;
      
      
      // Go to sleep before the EEPROM write resets the chip *sigh*
      asm volatile ("sleep");
      cli();
      
      // Restore registers
      SLEEP.CTRL  = sleep_ctrl;
      PMIC.STATUS = pmic_status;
      PMIC.CTRL   = pmic_ctrl;
      NVM.INTCTRL = nvm_intctrl;
    }
  }

  inline void nvm_execute_for_read ()
  {
    CCP = CCP_IOREG_gc;
    NVM.CTRLA = NVM_CMDEX_bm;
  }


  command error_t Init.init ()
  {
    // Disable memory mapped EEPROM access, and Power Reduction mode
    NVM.CTRLB &= ~NVM_EEMAPEN_bm & ~NVM_EPRM_bm;
    return SUCCESS;
  }

  command bool HplAtxm256Eeprom.isBusy ()
  {
    return nvm_busy ();
  }

  command bool HplAtxm256Eeprom.isBufferDirty ()
  {
    return NVM.STATUS & NVM_EELOAD_bm;
  }

  command error_t HplAtxm256Eeprom.bufferLoadByte (eeprom_offs_t offs, uint8_t byte)
  {
    if (nvm_busy ())
      return FAIL;

    NVM.CMD = NVM_CMD_LOAD_EEPROM_BUFFER_gc;
    NVM.ADDR0 = offs;
    NVM.DATA0 = byte;

    return SUCCESS;
  }

  command error_t HplAtxm256Eeprom.bufferErase ()
  {
    if (nvm_busy ())
      return FAIL;

    NVM.CMD = NVM_CMD_ERASE_EEPROM_BUFFER_gc;
    nvm_execute_for_write ();

    return SUCCESS;
  }

  command error_t HplAtxm256Eeprom.readByte (eeprom_addr_t addr, uint8_t *dst)
  {
    if (!dst || nvm_busy ())
      return FAIL;

    NVM.CMD = NVM_CMD_READ_EEPROM_gc;
    nvm_load_addr (addr);
    nvm_execute_for_read ();

    *dst = NVM.DATA0;

    return SUCCESS;
  }

  command error_t HplAtxm256Eeprom.eraseAll ()
  {
    if (nvm_busy ())
      return FAIL;

    NVM.CMD = NVM_CMD_ERASE_EEPROM_gc;
    nvm_execute_for_write ();

    return SUCCESS;
  }

  command error_t HplAtxm256Eeprom.erasePage (eeprom_addr_t addr)
  {
    if (nvm_busy ())
      return FAIL;

    NVM.CMD = NVM_CMD_ERASE_EEPROM_PAGE_gc;
    nvm_load_addr (addr);
    nvm_execute_for_write ();

    return SUCCESS;
  }

  command error_t HplAtxm256Eeprom.writePage (eeprom_addr_t addr)
  {
    if (nvm_busy ())
      return FAIL;

    NVM.CMD = NVM_CMD_WRITE_EEPROM_PAGE_gc;
    nvm_load_addr (addr);
    nvm_execute_for_write ();

    return SUCCESS;
  }

  command error_t HplAtxm256Eeprom.eraseWritePage (eeprom_addr_t addr)
  {
    if (nvm_busy ())
      return FAIL;

    NVM.CMD = NVM_CMD_ERASE_WRITE_EEPROM_PAGE_gc;
    nvm_load_addr (addr);
    nvm_execute_for_write ();

    return SUCCESS;
  }
}
