configuration NetProgC {
  provides interface NetProg;
}

implementation {
  components NetProgM, ReprogramGuardC, InternalFlashC;

  NetProgM.InternalFlash -> InternalFlashC;
  NetProgM.ReprogramGuard -> ReprogramGuardC;

  NetProg = NetProgM;
}
