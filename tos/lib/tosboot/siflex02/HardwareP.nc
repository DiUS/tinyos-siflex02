module HardwareP {
  provides interface Hardware;
  uses interface Init as PlatformInit;
}
implementation {

  command void Hardware.init()
  {
    // Move interrupt vectors to the boot section
    uint8_t tmp = PMIC.CTRL | PMIC_IVSEL_bm;
    CCP = CCP_IOREG_gc;
    PMIC.CTRL = tmp;

    // FIXME - we get a spurious TCD0 OVF interrupt after handover to the application, but can't seem to shut down TCD0?
    TCD0.CTRLA = 0;
    TCD0.INTCTRLA = 0;
    TCD0.INTFLAGS = 1;

    call PlatformInit.init ();
  }

  command void Hardware.reboot() {
    wdt_enable(1);
    while(1);
  }

}

