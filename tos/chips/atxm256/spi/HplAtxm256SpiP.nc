/*
 * HplAtxm256SpiP.nc
 *
 * Generic Hpl SPI for atxmega.
 *
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
 */

generic module HplAtxm256SpiP(uint16_t spi_addr)
{
  provides interface HplAtxm256Spi;

  uses {
    interface HplAtxm256IO    as ss;   // Slave set line
    interface HplAtxm256IO    as sck;  // SPI clock line
    interface HplAtxm256IO    as mosi; // Master out, slave in
    interface HplAtxm256IO    as miso; // Master in, slave out
    interface HplAtxm256OnOff as Power;
    interface McuPowerState;
  }
}
implementation
{
#define spi ((SPI_t*)spi_addr)

  async command void HplAtxm256Spi.initMaster(uint8_t spiFlags) {
    call Power.on();
    call mosi.makeOutput();
    call miso.makeInput();
    call sck.makeOutput();
    call ss.makeOutput();
    spi->CTRL |= SPI_MASTER_bm | spiFlags | SPI_ENABLE_bm;
    call McuPowerState.update();
  }

  async command void HplAtxm256Spi.initSlave(uint8_t spiFlags) {
    call Power.on();
    call miso.makeOutput();
    call mosi.makeInput();
    call sck.makeInput();
    call ss.makeInput();
    spi->CTRL = (spi->CTRL & ~SPI_MASTER_bm) | spiFlags | SPI_ENABLE_bm;
    call McuPowerState.update();
  }

  async command void HplAtxm256Spi.shutdown() {
    spi->CTRL = 0x00;
    call miso.makeInput();
    call mosi.makeInput();
    call sck.makeInput();
    call ss.makeInput();
    call Power.off();
    call McuPowerState.update();
  }

  async command uint8_t HplAtxm256Spi.read() {
    return spi->DATA;
  }

  async command void HplAtxm256Spi.write(uint8_t data) {
    spi->DATA = data;
  }

}
