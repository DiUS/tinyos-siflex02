configuration HardwareC
{
  provides interface Hardware;
}
implementation
{
  components HardwareP, PlatformC, NoInitC;
  HardwareP.PlatformInit -> PlatformC;
  PlatformC.MoteInit -> NoInitC;

  Hardware = HardwareP;
}
