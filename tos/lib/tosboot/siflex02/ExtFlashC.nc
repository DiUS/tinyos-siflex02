#include "flash_driver.h"
module ExtFlashC
{
  provides {
    interface Init;
    interface StdControl;
    interface ExtFlash;
  }
}
implementation {

  uint32_t addr;

  command error_t Init.init() { return SUCCESS; }
  command error_t StdControl.start() { return SUCCESS; }
  command error_t StdControl.stop() { return SUCCESS; }

  command void ExtFlash.startRead(uint32_t newAddr) {
    addr = newAddr;
  }

  command uint8_t ExtFlash.readByte() {
    uint8_t byte;
    flash_read (addr++, &byte, 1);
    return byte;
  }

  command void ExtFlash.stopRead() {}

}
