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
generic module ConfigStorageP (volume_id_t volid)
{
  provides interface Mount;
  provides interface ConfigStorage;

  uses interface HplAtxm256Eeprom as Eeprom;
}
implementation
{
  /* To support transactional behaviour, we split the volume in half, put a
   * small header into each, and only write to one partition at a time.
   * Each header has a magic id (to determine whether that partition contains
   * valid data) and a version number. The valid partition with the highest
   * version number contains the latest commit. Version numbers wrap around
   * and version 0 is treated as greated than 255.
   * All reads are directed at the partition with the latest valid data, and
   * writes go to the other partition. When a commit is successful, the roles
   * of the partitions are effectively changed. On a successful commit, the
   * data is copied over into the "scratch" partition to form the base for
   * further changes.
   */

  // Compile-time check to ensure specified volume is an EEPROM volume
  enum { CONFIG_STORAGE_ONLY_SUPPORTS_EEPROM_VOLUMES =
         1/ATXM256_VOLUME_IS_EEPROM(volid) };

  const uint32_t MAGIC_ID = 0xdd902a8d;

  typedef struct {
    uint32_t magic_id;
    uint8_t version;
  } ConfigHeader;

  enum { NONE, COMMIT, WRITE, MOUNT, COPYDATA } current_op;

  bool busy = FALSE;
  bool mounted = FALSE;
  bool erasing = FALSE;

  // Cached headers
  ConfigHeader hdr_a, hdr_b;

  // Read/write location/length
  struct {
    storage_addr_t offs;
    void *data;
    storage_len_t len;
  } rw;

  storage_len_t progress; // in-progress write count

  // Because we are not the only user of the EEPROM, we need to keep track
  // of whether we actually have an outstanding split-phase call --- all the
  // EEPROM feedback comes through a single event, and if we listen to that
  // event while another user causes the eeprom driver to signal, we are in
  // Deep Trouble[tm]
  bool am_waiting_for_eeprom=FALSE;
  void wait_for_eeprom()
  {
    am_waiting_for_eeprom=TRUE;
  }

  // We only expect a difference of 1 between the versions, but we need to
  // handle wrap-around correctly. Hence, we test whether a.ver is b.ver+1.
  bool part_a_is_latest ()
  {
    if (hdr_a.magic_id == MAGIC_ID && hdr_b.magic_id == MAGIC_ID)
      return hdr_a.version == (uint8_t)(hdr_b.version + 1);
    else if (hdr_b.magic_id != MAGIC_ID)
      return TRUE; // prefer the A partition, even if not yet valid
    else
      return FALSE;
  }

  inline ConfigHeader *part_read_hdr ()
  {
    return part_a_is_latest () ? &hdr_a : &hdr_b;
  }

  inline ConfigHeader *part_write_hdr ()
  {
    return part_a_is_latest () ? &hdr_b : &hdr_a;
  }

  inline eeprom_addr_t part_a ()
  {
    return ATXM256_VOLUME_MAP[volid].vol.eeprom.base * EEPROM_PAGE_SIZE;
  }
  inline eeprom_addr_t part_b ()
  {
    return ATXM256_VOLUME_MAP[volid].vol.eeprom.base * EEPROM_PAGE_SIZE +
      ((ATXM256_VOLUME_MAP[volid].vol.eeprom.size * EEPROM_PAGE_SIZE) / 2);
  }

  eeprom_addr_t part_read_addr ()
  {
    return part_a_is_latest () ? part_a () : part_b ();
  }

  eeprom_addr_t part_write_addr ()
  {
    return part_a_is_latest () ? part_b () : part_a ();
  }

  inline eeprom_addr_t part_read_data_addr ()
  {
    return part_read_addr () + sizeof (ConfigHeader);
  }

  inline eeprom_addr_t part_write_data_addr ()
  {
    return part_write_addr () + sizeof (ConfigHeader);
  }

  bool read_header (eeprom_addr_t addr, ConfigHeader *dst_hdr)
  {
    uint8_t *dst = (uint8_t *)dst_hdr;
    uint8_t i;
    for (i = 0; i < sizeof (ConfigHeader); ++i)
    {
      if (call Eeprom.readByte (addr + i, dst + i) != SUCCESS)
        return FALSE;
    }
    return TRUE;
  }

  task void copy_data ()
  {
    uint8_t byte, i;
    storage_len_t left;

    eeprom_addr_t read_addr = part_read_data_addr () + progress;
    eeprom_addr_t addr = part_write_data_addr () + progress;
    eeprom_addr_t page_addr = addr & ~(EEPROM_PAGE_SIZE -1);
    eeprom_offs_t page_offs = addr - page_addr;

    left = call ConfigStorage.getSize () - progress;

    for (i = 0; (i < left) && ((page_offs + i) < EEPROM_PAGE_SIZE); ++i)
    {
      if (call Eeprom.readByte (read_addr + i, &byte) != SUCCESS)
        goto failed;
      if (call Eeprom.bufferLoadByte (page_offs + i, byte) != SUCCESS)
        goto failed;
    }
    if (call Eeprom.eraseWritePage (page_addr) != SUCCESS)
      goto failed;
    wait_for_eeprom();
    
    progress += i;
    erasing = FALSE;

    return;

  failed:
    erasing = TRUE;
    while (call Eeprom.bufferErase () != SUCCESS) {}
    wait_for_eeprom();
  }


  task void do_mount ()
  {
    if (!read_header (part_a (), &hdr_a) ||
        !read_header (part_b (), &hdr_b))
          goto failed;

    current_op = MOUNT;
    progress = 0;

    post copy_data ();
    return;

  failed:
    busy = FALSE;
    signal Mount.mountDone (FAIL);
  }

  task void do_write ()
  {
    eeprom_addr_t addr = part_write_data_addr () + rw.offs + progress;
    eeprom_addr_t page_addr = addr & ~(EEPROM_PAGE_SIZE -1);
    eeprom_offs_t page_offs = addr - page_addr;
    storage_len_t left = rw.len - progress;
    uint8_t *data = (uint8_t *)rw.data + progress;
    uint8_t i;

    current_op = WRITE;
    for (i = 0; (i < left) && ((page_offs + i) < EEPROM_PAGE_SIZE); ++i)
    {
      if (call Eeprom.bufferLoadByte (page_offs + i, data[i]) != SUCCESS)
        goto failed;
    }
    if (call Eeprom.eraseWritePage (page_addr) != SUCCESS)
      goto failed;
    wait_for_eeprom();
    
    progress += i;
    erasing = FALSE;
    return;

  failed:
    erasing = TRUE;
    while (call Eeprom.bufferErase () != SUCCESS) {}
    wait_for_eeprom();
  }

  task void do_read ()
  {
    eeprom_addr_t addr = part_read_data_addr () + rw.offs;
    storage_len_t i;
    error_t result = FAIL;
    for (i = 0; i < rw.len; ++i)
    {
      if (call Eeprom.readByte (addr + i, rw.data + i) != SUCCESS)
        goto out;
    }
    result = SUCCESS;

  out:
    busy = FALSE;
    signal ConfigStorage.readDone (rw.offs, rw.data, rw.len, result);
  }

  task void do_commit ()
  {
    uint8_t i;
    ConfigHeader *hdr = part_write_hdr ();
    uint8_t *hdr_bytes = (uint8_t *)hdr;
    eeprom_addr_t addr = part_write_addr ();
    eeprom_addr_t page_addr = addr & ~(EEPROM_PAGE_SIZE -1);
    eeprom_offs_t page_offs = addr - page_addr;

    hdr->version = part_read_hdr ()->version + 1;
    hdr->magic_id = MAGIC_ID;

    current_op = COMMIT;

    for (i = 0; i < sizeof (ConfigHeader); ++i)
    {
      if (call Eeprom.bufferLoadByte (page_offs + i, hdr_bytes[i]) != SUCCESS)
        goto failed;
    }
    if (call Eeprom.eraseWritePage (page_addr) != SUCCESS)
      goto failed;
    wait_for_eeprom();

    return;

  failed:
    hdr->version -= 2; // do not claim to be committed
    erasing = TRUE;
    while (call Eeprom.bufferErase () != SUCCESS) {}
    wait_for_eeprom();
  }


  task void eeprom_done ()
  {
    bool was_erasing = erasing;
    erasing = FALSE;
    busy = FALSE;

    if (!am_waiting_for_eeprom)
      return;
    am_waiting_for_eeprom=FALSE;
    
    switch (current_op)
    {
      case COMMIT:
      {
        busy = TRUE;
        current_op = COPYDATA;
        progress = 0;
        post copy_data ();
        break;
      }
      case WRITE:
        if (progress == rw.len)
          signal ConfigStorage.writeDone (
            rw.offs, rw.data, rw.len, was_erasing ? FAIL : SUCCESS);
        else
        {
          busy = TRUE;
          post do_write (); // have more data to write out
        }
        break;
      case COPYDATA:
        // At this stage we're committed and can't back out, so even if we
        // failed in the copydata stage, we must keep retrying - we've
        // potentially already overwritten old data, and can't accept new
        // writes until we've copied over the committed data as the new base.
        if (progress == call ConfigStorage.getSize ())
            signal ConfigStorage.commitDone (SUCCESS);
        else
        {
          busy = TRUE;
          post copy_data ();
        }
        break;
      case MOUNT:
        if (was_erasing)
          signal Mount.mountDone (FAIL);
        else
        {
          if (progress == call ConfigStorage.getSize ())
          {
            mounted = TRUE;
            signal Mount.mountDone (SUCCESS);
          }
          else
          {
            busy = TRUE;
            post copy_data ();
          }
        }
        break;
      default: break;
    }
  }

  async event void Eeprom.done ()
  {
    post eeprom_done ();
  }

  command error_t Mount.mount ()
  {
    if (mounted)
      return FAIL;

    busy = TRUE;

    post do_mount ();
    return SUCCESS;
  }

  command error_t ConfigStorage.read (storage_addr_t addr, void *buf, storage_len_t len)
  {
    if (busy)
      return EBUSY;
    if (!mounted)
      return EOFF;
    if (addr + len > call ConfigStorage.getSize ())
      return EINVAL;
    if (part_read_hdr ()->magic_id != MAGIC_ID)
      return FAIL;

    busy = TRUE;
    rw.offs = addr;
    rw.data = buf;
    rw.len = len;
    post do_read ();
    return SUCCESS;
  }

  command error_t ConfigStorage.write (storage_addr_t addr, void *buf, storage_len_t len)
  {
    if (busy)
      return EBUSY;
    if (!mounted)
      return EOFF;
    if (addr + len > call ConfigStorage.getSize ())
      return EINVAL;

    busy = TRUE;
    rw.offs = addr;
    rw.data = buf;
    rw.len = len;
    progress = 0;
    post do_write ();
    return SUCCESS;
  }

  command error_t ConfigStorage.commit ()
  {
    if (busy)
      return EBUSY;
    if (!mounted)
      return EOFF;

    busy = TRUE;
    post do_commit ();
    return SUCCESS;
  }

  command storage_len_t ConfigStorage.getSize ()
  {
    storage_len_t rawsize =
      ATXM256_VOLUME_MAP[volid].vol.eeprom.size * EEPROM_PAGE_SIZE;
    storage_len_t minsize = 2 * sizeof (ConfigHeader);
    if (rawsize < minsize)
      return 0;
    else
      return (rawsize / 2) - sizeof (ConfigHeader);
  }

  command bool ConfigStorage.valid ()
  {
    return
      mounted && (hdr_a.magic_id == MAGIC_ID || hdr_b.magic_id == MAGIC_ID);
  }
}
