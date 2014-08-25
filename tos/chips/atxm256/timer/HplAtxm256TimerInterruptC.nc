/*
 * HplAtxm256TimerInterruptC.nc
 *
 * atxmega timer interrupts.
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

module HplAtxm256TimerInterruptC
{
  provides {
    interface HplAtxm256Interrupt as rtc_ovf;
    interface HplAtxm256Interrupt as rtc_comp;

    interface HplAtxm256Interrupt as tcc0_ovf;
    interface HplAtxm256Interrupt as tcc0_cca;
    interface HplAtxm256Interrupt as tcc0_ccb;
    interface HplAtxm256Interrupt as tcc0_ccc;
    interface HplAtxm256Interrupt as tcc0_ccd;

    interface HplAtxm256Interrupt as tcd0_ovf;
    interface HplAtxm256Interrupt as tcd0_cca;
    interface HplAtxm256Interrupt as tcd0_ccb;
    interface HplAtxm256Interrupt as tcd0_ccc;
    interface HplAtxm256Interrupt as tcd0_ccd;

    interface HplAtxm256Interrupt as tce0_ovf;
    interface HplAtxm256Interrupt as tce0_cca;
    interface HplAtxm256Interrupt as tce0_ccb;
    interface HplAtxm256Interrupt as tce0_ccc;
    interface HplAtxm256Interrupt as tce0_ccd;

    interface HplAtxm256Interrupt as tcf0_ovf;
    interface HplAtxm256Interrupt as tcf0_cca;
    interface HplAtxm256Interrupt as tcf0_ccb;
    interface HplAtxm256Interrupt as tcf0_ccc;
    interface HplAtxm256Interrupt as tcf0_ccd;

    interface HplAtxm256Interrupt as tcc1_ovf;
    interface HplAtxm256Interrupt as tcc1_cca;
    interface HplAtxm256Interrupt as tcc1_ccb;

    interface HplAtxm256Interrupt as tcd1_ovf;
    interface HplAtxm256Interrupt as tcd1_cca;
    interface HplAtxm256Interrupt as tcd1_ccb;

    interface HplAtxm256Interrupt as tce1_ovf;
    interface HplAtxm256Interrupt as tce1_cca;
    interface HplAtxm256Interrupt as tce1_ccb;
  }
}
implementation
{
  // === RTC ====
  ATXM256_ISR(rtc_ovf, RTC,
              INTCTRL, RTC_OVFINTLVL_LO_gc, RTC_OVFINTLVL_gm,
              INTFLAGS, RTC_OVFIF_bm, RTC_OVF_vect)
  ATXM256_ISR(rtc_comp, RTC,
              INTCTRL, RTC_COMPINTLVL_LO_gc, RTC_COMPINTLVL_gm,
              INTFLAGS, RTC_COMPIF_bm, RTC_COMP_vect);

  // ==== Timer C0 ====
  ATXM256_ISR(tcc0_ovf, TCC0, 
              INTCTRLA, TC_OVFINTLVL_LO_gc, TC0_OVFINTLVL_gm,
              INTFLAGS, TC0_OVFIF_bm, TCC0_OVF_vect)
  ATXM256_ISR(tcc0_cca, TCC0,
              INTCTRLB, TC_CCAINTLVL_LO_gc, TC0_CCAINTLVL_gm,
              INTFLAGS, TC0_CCAIF_bm, TCC0_CCA_vect)
  ATXM256_ISR(tcc0_ccb, TCC0,
              INTCTRLB, TC_CCBINTLVL_LO_gc, TC0_CCBINTLVL_gm,
              INTFLAGS, TC0_CCBIF_bm, TCC0_CCB_vect)
  ATXM256_ISR(tcc0_ccc, TCC0,
              INTCTRLB, TC_CCCINTLVL_LO_gc, TC0_CCCINTLVL_gm,
              INTFLAGS, TC0_CCCIF_bm, TCC0_CCC_vect)
  ATXM256_ISR(tcc0_ccd, TCC0,
              INTCTRLB, TC_CCDINTLVL_LO_gc, TC0_CCDINTLVL_gm,
              INTFLAGS, TC0_CCDIF_bm, TCC0_CCD_vect)

  // ==== Timer D0 ====
  ATXM256_ISR(tcd0_ovf, TCD0, 
              INTCTRLA, TC_OVFINTLVL_LO_gc, TC0_OVFINTLVL_gm,
              INTFLAGS, TC0_OVFIF_bm, TCD0_OVF_vect)
  ATXM256_ISR(tcd0_cca, TCD0,
              INTCTRLB, TC_CCAINTLVL_LO_gc, TC0_CCAINTLVL_gm,
              INTFLAGS, TC0_CCAIF_bm, TCD0_CCA_vect)
  ATXM256_ISR(tcd0_ccb, TCD0,
              INTCTRLB, TC_CCBINTLVL_LO_gc, TC0_CCBINTLVL_gm,
              INTFLAGS, TC0_CCBIF_bm, TCD0_CCB_vect)
  ATXM256_ISR(tcd0_ccc, TCD0,
              INTCTRLB, TC_CCCINTLVL_LO_gc, TC0_CCCINTLVL_gm,
              INTFLAGS, TC0_CCCIF_bm, TCD0_CCC_vect)
  ATXM256_ISR(tcd0_ccd, TCD0,
              INTCTRLB, TC_CCDINTLVL_LO_gc, TC0_CCDINTLVL_gm,
              INTFLAGS, TC0_CCDIF_bm, TCD0_CCD_vect)

  // ==== Timer E0 ====
  ATXM256_ISR(tce0_ovf, TCE0, 
              INTCTRLA, TC_OVFINTLVL_LO_gc, TC0_OVFINTLVL_gm,
              INTFLAGS, TC0_OVFIF_bm, TCE0_OVF_vect)
  ATXM256_ISR(tce0_cca, TCE0,
              INTCTRLB, TC_CCAINTLVL_LO_gc, TC0_CCAINTLVL_gm,
              INTFLAGS, TC0_CCAIF_bm, TCE0_CCA_vect)
  ATXM256_ISR(tce0_ccb, TCE0,
              INTCTRLB, TC_CCBINTLVL_LO_gc, TC0_CCBINTLVL_gm,
              INTFLAGS, TC0_CCBIF_bm, TCE0_CCB_vect)
  ATXM256_ISR(tce0_ccc, TCE0,
              INTCTRLB, TC_CCCINTLVL_LO_gc, TC0_CCCINTLVL_gm,
              INTFLAGS, TC0_CCCIF_bm, TCE0_CCC_vect)
  ATXM256_ISR(tce0_ccd, TCE0,
              INTCTRLB, TC_CCDINTLVL_LO_gc, TC0_CCDINTLVL_gm,
              INTFLAGS, TC0_CCDIF_bm, TCE0_CCD_vect)

  // ==== Timer F0 ====
  ATXM256_ISR(tcf0_ovf, TCF0, 
              INTCTRLA, TC_OVFINTLVL_LO_gc, TC0_OVFINTLVL_gm,
              INTFLAGS, TC0_OVFIF_bm, TCF0_OVF_vect)
  ATXM256_ISR(tcf0_cca, TCF0,
              INTCTRLB, TC_CCAINTLVL_LO_gc, TC0_CCAINTLVL_gm,
              INTFLAGS, TC0_CCAIF_bm, TCF0_CCA_vect)
  ATXM256_ISR(tcf0_ccb, TCF0,
              INTCTRLB, TC_CCBINTLVL_LO_gc, TC0_CCBINTLVL_gm,
              INTFLAGS, TC0_CCBIF_bm, TCF0_CCB_vect)
  ATXM256_ISR(tcf0_ccc, TCF0,
              INTCTRLB, TC_CCCINTLVL_LO_gc, TC0_CCCINTLVL_gm,
              INTFLAGS, TC0_CCCIF_bm, TCF0_CCC_vect)
  ATXM256_ISR(tcf0_ccd, TCF0,
              INTCTRLB, TC_CCDINTLVL_LO_gc, TC0_CCDINTLVL_gm,
              INTFLAGS, TC0_CCDIF_bm, TCF0_CCD_vect)

  // ==== Timer C1 ====
  ATXM256_ISR(tcc1_ovf, TCC1, 
              INTCTRLA, TC_OVFINTLVL_LO_gc, TC1_OVFINTLVL_gm,
              INTFLAGS, TC1_OVFIF_bm, TCC1_OVF_vect)
  ATXM256_ISR(tcc1_cca, TCC1,
              INTCTRLB, TC_CCAINTLVL_LO_gc, TC1_CCAINTLVL_gm,
              INTFLAGS, TC1_CCAIF_bm, TCC1_CCA_vect)
  ATXM256_ISR(tcc1_ccb, TCC1,
              INTCTRLB, TC_CCBINTLVL_LO_gc, TC1_CCBINTLVL_gm,
              INTFLAGS, TC1_CCBIF_bm, TCC1_CCB_vect)

  // ==== Timer D1 ====
  ATXM256_ISR(tcd1_ovf, TCD1, 
              INTCTRLA, TC_OVFINTLVL_LO_gc, TC1_OVFINTLVL_gm,
              INTFLAGS, TC1_OVFIF_bm, TCD1_OVF_vect)
  ATXM256_ISR(tcd1_cca, TCD1,
              INTCTRLB, TC_CCAINTLVL_LO_gc, TC1_CCAINTLVL_gm,
              INTFLAGS, TC1_CCAIF_bm, TCD1_CCA_vect)
  ATXM256_ISR(tcd1_ccb, TCD1,
              INTCTRLB, TC_CCBINTLVL_LO_gc, TC1_CCBINTLVL_gm,
              INTFLAGS, TC1_CCBIF_bm, TCD1_CCB_vect)

  // ==== Timer E1 ====
  ATXM256_ISR(tce1_ovf, TCE1, 
              INTCTRLA, TC_OVFINTLVL_LO_gc, TC1_OVFINTLVL_gm,
              INTFLAGS, TC1_OVFIF_bm, TCE1_OVF_vect)
  ATXM256_ISR(tce1_cca, TCE1,
              INTCTRLB, TC_CCAINTLVL_LO_gc, TC1_CCAINTLVL_gm,
              INTFLAGS, TC1_CCAIF_bm, TCE1_CCA_vect)
  ATXM256_ISR(tce1_ccb, TCE1,
              INTCTRLB, TC_CCBINTLVL_LO_gc, TC1_CCBINTLVL_gm,
              INTFLAGS, TC1_CCBIF_bm, TCE1_CCB_vect)
}
