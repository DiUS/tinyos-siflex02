#include "NetProg.h"
#include "TOSBoot_platform.h"

module NetProgM {
  provides {
    interface NetProg;
  }
  uses {
    interface InternalFlash;
    interface ReprogramGuard;
  }
}

implementation {

  uint32_t addr;
  
  command error_t NetProg.reboot()
  {
    netprog_reboot ();
    return FAIL;
  }
  
  command error_t NetProg.programImageAndReboot(uint32_t img_addr)
  {
    addr = img_addr;
    return call ReprogramGuard.okToProgram();
  }

  event void ReprogramGuard.okToProgramDone(bool ok)
  {
    BootArgs boot_args;

    if (!ok)
      return;

    atomic {
      if (SUCCESS != call InternalFlash.read (
        (void *)TOSBOOT_ARGS_ADDR, &boot_args, sizeof (boot_args)))
          return;

      boot_args.imageAddr = addr;
      boot_args.gestureCount = 0xff;
      boot_args.noReprogram = FALSE;

      if (SUCCESS != call InternalFlash.write (
        (void *)TOSBOOT_ARGS_ADDR, &boot_args, sizeof (boot_args)))
          return;

      call NetProg.reboot ();
    }
  }

}
