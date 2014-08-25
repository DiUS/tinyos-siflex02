module ReprogramGuardC
{
  provides interface ReprogramGuard;
}
implementation
{
  task void sendOk()
  {
    signal ReprogramGuard.okToProgramDone (TRUE);
  }

  command error_t ReprogramGuard.okToProgram ()
  {
    post sendOk ();
    return SUCCESS;
  }
}
