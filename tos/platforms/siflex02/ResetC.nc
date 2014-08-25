module ResetC
{
  provides interface Reset;
}
implementation
{
  async command void Reset.softReset ()
  {
    cli ();
    asm ("jmp 0x40000");
  }
}
