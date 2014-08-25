module VoltageC
{
  provides interface Voltage;
}
implementation
{
  command bool Voltage.okToProgram() {
    // TODO: check voltage via ADC, for now assume we have enough juice
    return TRUE;
  }
}
