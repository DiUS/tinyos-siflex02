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

#include "StorageVolumes.h"

#if EEPROM_PAGE_SIZE != 32
  #error "Unexpected page size! Code review+update needed!"
#endif


// Because we are not the only user of the EEPROM, we need to keep track
// of whether we actually have an outstanding split-phase call --- all the
// EEPROM feedback comes through a single event, and if we listen to that
// event while another user causes the eeprom driver to signal, we are in
// Deep Trouble[tm]
generic module LogStorageLiteP (volume_id_t volid, bool circular)
{
  provides interface LogWrite;
  provides interface LogRead;

  uses interface HplAtxm256Eeprom as Eeprom;
}
implementation
{

  enum { LOG_STORAGE_LITE_ONLY_SUPPORTS_EEPROM_VOLUMES =
         1/ATXM256_VOLUME_IS_EEPROM(volid) };

#define EEPROM_PAGE(addr) (addr / EEPROM_PAGE_SIZE)
#define VOL_NEXT_PAGE(page) \
    ((page + 1) > vol_last_page () ? \
     vol_first_data_page () : page + 1)
#define VOL_PREV_PAGE(page) \
    (page <= vol_first_data_page () ? \
     vol_last_page () : page - 1)

  enum {
    NONE,
    ERASE,
    ERASE_FINALISE,
    BUFFER_ERASE,
    APPEND,
    HEADER_AND_APPEND,
    ERASE_ERASE_BUFFER_AND_APPEND,
    ERASE_BUFFER_AND_APPEND,
    READ,
  } current_op;

  bool am_waiting_for_eeprom=FALSE;
  void wait_for_eeprom()
  {
    am_waiting_for_eeprom=TRUE;
  }

  eeprom_addr_t erase_progress;

  storage_cookie_t pos_write = SEEK_BEGINNING, pos_read = SEEK_BEGINNING;

  storage_cookie_t pos_append; // trails behind pos_write

  struct {
    void *buf;
    storage_len_t len;
    bool lost;
  } appended;

  struct {
    void *buf;
    storage_len_t len;
    error_t result;
  } read;

  const uint32_t MAGIC_ID = 0x47a653fd;
  struct {
    uint32_t magic;
    uint16_t volume_size;
    uint8_t  record_size;
  } header = { 0, 0 };


/// Convenience wrappers for volume bounds /////////////////////////////////

  inline eeprom_addr_t vol_start ()
  {
    return ATXM256_VOLUME_MAP[volid].vol.eeprom.base * EEPROM_PAGE_SIZE;
  }

  inline uint8_t vol_pages ()
  {
    return ATXM256_VOLUME_MAP[volid].vol.eeprom.size;
  }

  inline uint16_t vol_size ()
  {
    return ATXM256_VOLUME_MAP[volid].vol.eeprom.size * EEPROM_PAGE_SIZE;
  }

  inline eeprom_addr_t vol_end ()
  {
    return vol_start () + vol_size ();
  }

  inline uint8_t vol_first_page ()
  {
    return ATXM256_VOLUME_MAP[volid].vol.eeprom.base;
  }

  inline uint8_t vol_last_page ()
  {
    return vol_first_page()+vol_pages()-1;
  }
  
  inline uint8_t vol_first_data_page ()
  {
    return ATXM256_VOLUME_MAP[volid].vol.eeprom.base + 1;
  }

  inline eeprom_addr_t vol_data ()
  {
    return vol_first_data_page () * EEPROM_PAGE_SIZE;
  }


/// Erase helpers /////////////////////////////////////////////////////////

  // Tag all bytes in a page
  error_t tag_page ()
  {
    eeprom_offs_t i;
    for (i = 0; i < EEPROM_PAGE_SIZE; ++i)
    {
      if (call Eeprom.bufferLoadByte (i, 0) != SUCCESS)
        return EBUSY;
    }
    return SUCCESS;
  }

  void erase_buffer ()
  {
    current_op = BUFFER_ERASE;
    // We _really_ don't want to leave a buffer dirty, so retry until the
    // the NVM is no longer busy
    while (call Eeprom.bufferErase () != SUCCESS) {}
    wait_for_eeprom();
  }

  bool is_blank_page (uint8_t page)
  {
    uint8_t byte;
    int i;
    // Scan the page to see if it contains any written data
    for (i = 0; i < EEPROM_PAGE_SIZE; ++i)
      if ((call Eeprom.readByte (page * EEPROM_PAGE_SIZE + i, &byte) != SUCCESS)
          || byte != 0xff)
            return FALSE;
    return TRUE;
  }

  task void erase_page ()
  {
    tag_page ();
    if (call Eeprom.erasePage (erase_progress) != SUCCESS)
    {
      erase_buffer ();
      signal LogWrite.eraseDone (FAIL);
    }
    else
      wait_for_eeprom();
  }

/// Volume header helpers /////////////////////////////////////////////////

  typedef enum {
    VOLHDR_MISSING, VOLHDR_VALID, VOLHDR_INVALID
  } volume_state_t;

  // read, validate and cache volume header
  volume_state_t volume_header_state ()
  {
    if (!header.magic) // not cached yet
    {
      int i;
      uint8_t *h = (uint8_t *)&header;
      for (i = 0; i < sizeof (header); ++i, ++h)
      {
        if (call Eeprom.readByte (vol_start () + i, h) != SUCCESS)
        {
          header.magic = 0; // try again next time...
          break;
        }
      }
    }
    if (header.magic == ~0)
      return VOLHDR_MISSING;

    if (header.magic != MAGIC_ID)
      return VOLHDR_INVALID;
    if (header.volume_size != vol_size ())
      return VOLHDR_INVALID;

    return VOLHDR_VALID;
  }

  task void update_volume_header ()
  {
    int i;
    uint8_t *h = (uint8_t *)&header;
    header.magic = MAGIC_ID; // ensure we have the magic id set
    for (i = 0; i < sizeof (header); ++i, ++h)
    {
      if (call Eeprom.bufferLoadByte (i, *h) != SUCCESS)
        goto failed;
    }
    if (call Eeprom.writePage (vol_start ()) != SUCCESS)
      goto failed;
    else
    {
      wait_for_eeprom();
      return;
    }
    
  failed:
    erase_buffer (); // ideally we'd wait for this to finish before signalling
    signal LogWrite.appendDone (appended.buf, appended.len, FALSE, FAIL);
  }

/// Read/Write position helpers ///////////////////////////////////////////

  bool is_valid_record (eeprom_addr_t addr)
  {
    uint8_t i;
    uint8_t byte;
    for (i = 0; i < header.record_size; ++i)
    {
      // We can't safely handle an error here, other than by retrying, so retry
      while (call Eeprom.readByte (addr + i, &byte) != SUCCESS) {}
      if (byte != 0xff)
        return TRUE;
    }
    return FALSE;
  }

  // Note: assumes the header struct contains valid information
  storage_cookie_t discover_write_position ()
  {
    eeprom_addr_t addr;
    uint8_t page = vol_first_data_page (); // expected first blank page

    // the absolute minimum we need for a log is 3 pages: header, data, blank
    if (vol_pages () < 3)
      return (storage_cookie_t)vol_end ();

    // find first blank page
    while (page <= vol_last_page () && !is_blank_page (page))
      ++page;

    // Either the linear log is (as good as) full, or the circular log does
    // not contain its expected blank page. In either case, we will not support
    // writing more data to it!
    if (page > vol_last_page())
      return (storage_cookie_t)vol_end ();

    // back up to previous page, to see if there is any space left in it
    if (circular || page>vol_first_data_page ())
      page = VOL_PREV_PAGE (page);

    // read records of header.record_size bytes
    //   until all-ones record returned
    addr = page * EEPROM_PAGE_SIZE;
    while (EEPROM_PAGE(addr) == page && is_valid_record (addr))
      addr += header.record_size;

    // if the blank page was the first page, and the last page was full,
    // carefully wrap around to the first page
    if (EEPROM_PAGE(addr) != page)
      addr = VOL_NEXT_PAGE(page) * EEPROM_PAGE_SIZE;

    return (storage_cookie_t)addr;
  }

  storage_cookie_t discover_read_position ()
  {
    if (!circular)
      return (storage_cookie_t)vol_data ();
    else
    {
      uint8_t page = vol_first_data_page ();
      uint8_t looped;

      // Find the blank page
      while (page <= vol_last_page () && !is_blank_page (page))
        ++page;

      // If we don't find a blank page, we can't work out the beginning!
      if (page > vol_last_page ())
        return (storage_cookie_t)vol_end ();

      // Find the next page with data in it (if any)
      looped = page;
      do {
        page = VOL_NEXT_PAGE (page);
      } while (page != looped && is_blank_page (page));

      if (page == looped) // entire log is empty, there is no beginning
        return (storage_cookie_t)vol_end ();
      else
        return (storage_cookie_t)(page * EEPROM_PAGE_SIZE);
    }
  }

/// Append helpers ////////////////////////////////////////////////////////

  void handle_log_rotation (storage_len_t len)
  {
    uint8_t read_page  = EEPROM_PAGE (pos_read);
    uint8_t write_page = EEPROM_PAGE (pos_write);
    uint8_t blank_page = VOL_NEXT_PAGE (write_page);

    // update to next write position
    if ((pos_write += len) >= vol_end ())
      pos_write = vol_data ();

    write_page = EEPROM_PAGE(pos_write);

    // if we're about to write into the blank page, erase the following page
    if (write_page == blank_page)
    {
      blank_page = VOL_NEXT_PAGE (blank_page);

      // do we actually need to erase it?
      if (!is_blank_page (blank_page))
      {
        appended.lost = TRUE;
        current_op = ERASE_ERASE_BUFFER_AND_APPEND;
        tag_page ();
        while (call Eeprom.erasePage (blank_page * EEPROM_PAGE_SIZE) != SUCCESS)
        {
          // We need this to commence, so retry until NVM not busy. This
          // will only be encountered if the application attempts to have
          // multiple NVM operations in-flight at the same time.
        }
        wait_for_eeprom();

        // adjust the read position if it's in the to-be-erased page
        if (read_page == blank_page)
          pos_read = SEEK_BEGINNING;
      }
    }
  }

  task void append_record ()
  {
    int i;
    uint8_t *p = appended.buf;
    uint8_t offs = pos_append % EEPROM_PAGE_SIZE;
    for (i = 0; i < appended.len; ++i, ++p)
    {
      if (call Eeprom.bufferLoadByte (offs + i, *p) != SUCCESS)
      {
        signal LogWrite.appendDone (appended.buf, appended.len, FALSE, FAIL);
        goto failed;
      }
    }
    if (call Eeprom.eraseWritePage (pos_append) != SUCCESS)
      goto failed;
    wait_for_eeprom();
    return;

  failed:
    erase_buffer ();
  }


/// Read helpers //////////////////////////////////////////////////////////

  void task seek_done ()
  {
    signal LogRead.seekDone (SUCCESS);
  }

  void task read_done ()
  {
    // only advance read pointer if the read was successful
    if (read.result == SUCCESS)
    {
      pos_read += header.record_size;
      if (circular && pos_read >= vol_end ())
        pos_read = vol_data ();
    }

    current_op = NONE;
    signal LogRead.readDone (read.buf, read.len, read.result);
  }

/// Second half of split-phase EEPROM ops /////////////////////////////////

  task void eeprom_done ()
  {
    if (!am_waiting_for_eeprom)
      return;
    am_waiting_for_eeprom=FALSE;
    
    switch (current_op)
    {
      case ERASE:
      {
        if (erase_progress >= vol_end ())
        {
          pos_write = pos_read = SEEK_BEGINNING;
          header.magic = 0; // header no longer cached
          current_op = ERASE_FINALISE;
          // We MUST clear the buffer before moving on, so wait on NVM if needed
          while (call Eeprom.bufferErase () != SUCCESS) {}
          wait_for_eeprom();
        }
        else
        {
          erase_progress += EEPROM_PAGE_SIZE;
          post erase_page ();
        }
        break;
      }
      case ERASE_FINALISE:
      {
        current_op = NONE;
        signal LogWrite.eraseDone (SUCCESS);
        break;
      }
      case APPEND:
      {
        bool lost = appended.lost;
        appended.lost = FALSE;
        current_op = NONE;
        signal LogWrite.appendDone (appended.buf, appended.len, lost, SUCCESS);
        break;
      }
      case ERASE_ERASE_BUFFER_AND_APPEND:
      {
        current_op = ERASE_BUFFER_AND_APPEND;
        // We MUST clear the buffer before moving on, so wait on NVM if needed
        while (call Eeprom.bufferErase () != SUCCESS) {}
        wait_for_eeprom();
        break;
      }
      case HEADER_AND_APPEND:
      case ERASE_BUFFER_AND_APPEND:
      {
        current_op = APPEND;
        post append_record ();
        break;
      }
      case BUFFER_ERASE:
      {
        current_op = NONE;
        break;
      }
      case READ: // EEPROM read isn't done split-phase, so won't hit this one
      case NONE:
      default: break;
    }
  }

  async event void Eeprom.done ()
  {
    post eeprom_done ();
  }

/// Provided interface /////////////////////////////////////////////////////

  command error_t LogWrite.append (void *buf, storage_len_t len)
  {
    volume_state_t volstate = volume_header_state ();
    // Enforce our constraints to avoid corruption
    switch (len)
    {
      case 1: case 2: case 4: case 8: case 16: case 32: break;
      default: return EINVAL;
    }
    if (volstate == VOLHDR_VALID && header.record_size != len)
      return EINVAL;

    if (current_op != NONE)
      return EBUSY;

    // Get our cached header into a good state, if possible
    switch (volstate)
    {
      case VOLHDR_MISSING:
        current_op = HEADER_AND_APPEND;
        header.magic = MAGIC_ID;
        header.volume_size = vol_size ();
        header.record_size = len;
        post update_volume_header ();
        break;
      case VOLHDR_VALID:
        current_op = APPEND;
        break;
      case VOLHDR_INVALID: return EINVAL;
    }

#ifdef LSL_TESTING
    if (!buf)
    {
      pos_read=pos_write=SEEK_BEGINNING;
      current_op=NONE;
      return EINVAL;
    }
#endif
    
    if (pos_write == SEEK_BEGINNING)
      pos_write = discover_write_position ();

    if (pos_write >= vol_end ())
      goto failed; // Linear log full, or circular log corrupted

    pos_append = pos_write;
    appended.buf = buf;
    appended.len = len;

    if (circular)
      handle_log_rotation (len); // note: may change current_op
    else
    {
      pos_write += len;
      if (pos_write > vol_end ())
        goto failed;
    }

    // only post the append task if that's the only thing we're doing
    if (current_op == APPEND)
      post append_record ();

    return SUCCESS;

  failed:
    current_op = NONE;
    return EINVAL;
  }

  command storage_cookie_t LogWrite.currentOffset () { return pos_write; }

  command error_t LogWrite.erase ()
  {
    if (current_op != NONE)
      return EBUSY;

    current_op = ERASE;
    erase_progress = vol_start ();
    post erase_page ();
    return SUCCESS;
  }

  task void sync_done () { signal LogWrite.syncDone (SUCCESS); }
  command error_t LogWrite.sync ()
  {
    // Due to the limitations we impose, we're always synced, so this is in
    // effect a no-op.
    post sync_done ();
    return SUCCESS;
  }


  command error_t LogRead.read (void *buf, storage_len_t len)
  {
    int i;

    if (current_op != NONE)
      return EBUSY;

    if (volume_header_state () != VOLHDR_VALID)
    {
      read.result = FAIL;
      goto out;
    }

    current_op = READ;

    if (pos_read == SEEK_BEGINNING)
      pos_read = discover_read_position ();

    if (pos_write == SEEK_BEGINNING)
      pos_write = discover_write_position ();

    if (len == header.record_size &&
        pos_read < vol_end () &&
        pos_read != pos_write)
    {
      uint8_t *dst = buf;

      read.result = SUCCESS;
      for (i = 0; i < len; ++i)
      {
        if (call Eeprom.readByte (pos_read + i, dst + i) != SUCCESS)
        {
          read.result = FAIL;
          break;
        }
      }
    }
    else read.result = FAIL;

  out:
    read.buf = buf;
    read.len = len;

    post read_done ();

    return SUCCESS;
  }

  command storage_cookie_t LogRead.currentOffset () { return pos_read; }
  
  command error_t LogRead.seek (storage_cookie_t pos)
  {
    if (current_op != NONE)
      return EBUSY;

    // TODO: sanity check pos (over in seek_done?)
    pos_read = pos;
    post seek_done ();
    return SUCCESS;
  }

  command storage_len_t LogRead.getSize ()
  {
    return vol_size () - EEPROM_PAGE_SIZE;
  }
}
