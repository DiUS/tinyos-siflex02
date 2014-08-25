configuration CounterMilli32C
{
  provides interface Counter<TMilli, uint32_t> as CounterMilli32;
}
implementation
{
  components RtcCounterMilli32C as Rtc;
  CounterMilli32 = Rtc;
}
