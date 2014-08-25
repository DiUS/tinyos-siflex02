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

#include "Storage.h"
#include "StorageVolumes.h"
#include "flash_driver.h"
#include "crc.h"

generic module BlockStorageC(volume_id_t volid) {
  provides {
    interface BlockWrite;
    interface BlockRead;
    interface StorageMap;
  }
}
implementation {

  // Compile-time guard against attempting to use an EEPROM volume
  enum { BLOCK_STORAGE_ONLY_SUPPORTED_FOR_FLASH_VOLUMES =
         1/ATXM256_VOLUME_IS_FLASH(volid) };

  enum { PAGE_SIZE = 512 };

  // We have to trade off between stack space and run time.
  // The chosen value was carefully plucked from the air to satisfy that.
  enum { CRC_BUF_SIZE = 64 };

  struct transaction {
    enum { BS_NONE, BS_READ, BS_WRITE, BS_ERASE, BS_SYNC, BS_CRC } op;
    storage_addr_t addr;
    void *buf;
    storage_len_t len;
  } data = { 0 };

  inline bool busy () { return data.op != BS_NONE; }

  inline uint32_t base_addr ()
  {
    return (uint32_t)ATXM256_VOLUME_MAP[volid].vol.flash.base * PAGE_SIZE;
  }

  inline uint32_t phys_addr (uint32_t addr) { return addr + base_addr (); }

  inline bool valid_addr (uint32_t addr)
  {
    return addr >= base_addr () &&
           addr < (base_addr () + call BlockRead.getSize ());
  }

  uint16_t calc_crc (uint32_t addr, uint32_t len, uint16_t crc)
  {
    uint8_t buffer[CRC_BUF_SIZE];
    while (len)
    {
      uint8_t num = len > CRC_BUF_SIZE ? CRC_BUF_SIZE : len;
      uint8_t i;

      flash_read (addr, &buffer, num);
      for (i = 0; i < num; ++i)
        crc = crcByte (crc, buffer[i]);
      len -= num;
    }
    return crc;
  }

  task void processTransaction ()
  {
    struct transaction t = data;
    data.op = BS_NONE;
    switch (t.op)
    {
      case BS_READ:
        flash_read (t.addr, t.buf, t.len);
        signal BlockRead.readDone (t.addr, t.buf, t.len, SUCCESS);
        break;
      case BS_WRITE:
        flash_write (t.addr, t.buf, t.len);
        signal BlockWrite.writeDone (t.addr, t.buf, t.len, SUCCESS);
        break;
      case BS_ERASE:
         // The flash driver in our TOSBoot does erase/write, so no-op here
        signal BlockWrite.eraseDone (SUCCESS);
        break;
      case BS_SYNC:
        // flash_write() has already ensured the data is written out
        signal BlockWrite.syncDone (SUCCESS);
        break;
      case BS_CRC:
      {
        uint16_t crc;
        crc = calc_crc (t.addr, t.len, (uint16_t)t.buf);
        signal BlockRead.computeCrcDone (t.addr, t.len, crc, SUCCESS);
        break;
      }
      case BS_NONE:
      default: break;
    }
  }


  command error_t BlockWrite.write (storage_addr_t addr, void* buf, storage_len_t len)
  {
    if (busy ())
      return EBUSY;

    // We only support commencing writes on page boundaries for now.
    // The flash driver doesn't handle odd addresses, and there is no real
    // need to support non-page aligned writes.
    if (addr % PAGE_SIZE)
      return EINVAL;

    addr = phys_addr (addr);
    if (!valid_addr (addr) || !valid_addr (addr + len))
      return EINVAL;

    data.op = BS_WRITE;
    data.addr = addr;
    data.buf = buf;
    data.len = len;
    post processTransaction ();

    return SUCCESS;
  }

  command error_t BlockWrite.erase () {
    if (busy ())
      return EBUSY;

    data.op = BS_ERASE;
    post processTransaction ();

    return SUCCESS;
  }

  command error_t BlockWrite.sync () {
    if (busy ())
      return EBUSY;

    data.op = BS_SYNC;
    post processTransaction ();

    return SUCCESS;
  }

  command error_t BlockRead.read (storage_addr_t addr, void* buf, storage_len_t len)
  {
    if (busy ())
      return EBUSY;

    addr = phys_addr (addr);
    if (!valid_addr (addr) || !valid_addr (addr + len))
      return EINVAL;

    data.op = BS_READ;
    data.addr = addr;
    data.buf = buf;
    data.len = len;
    post processTransaction ();

    return SUCCESS;
  }

  command error_t BlockRead.computeCrc (storage_addr_t addr, storage_len_t len, uint16_t crc)
  {
    if (busy ())
      return EBUSY;

    addr = phys_addr (addr);
    if (!valid_addr (addr) || !valid_addr (addr + len))
      return EINVAL;

    data.op = BS_CRC;
    data.addr = addr;
    data.buf = (void *)crc;
    data.len = len;
    post processTransaction ();

    return SUCCESS;
  }

  command storage_len_t BlockRead.getSize ()
  {
    return (storage_len_t)ATXM256_VOLUME_MAP[volid].vol.flash.size * PAGE_SIZE;
  }

  command storage_addr_t StorageMap.getPhysicalAddress (storage_addr_t addr)
  {
    return phys_addr (addr);
  }
}
