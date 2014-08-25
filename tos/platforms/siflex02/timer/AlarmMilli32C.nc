generic configuration AlarmMilli32C ()
{
  provides interface Alarm<TMilli, uint32_t> as AlarmMilli32;
}
implementation
{
#if 0
  // FIXME - Allowing anything except HilTimerMilliC to use the RTC as a basis
  // for alarms does not work properly for some reason.
  // Timeouts may not fire at all, fire too frequently at times, and/or
  // eventually settle down or die altogether. Instantiating further timers and
  // setting short timeouts on them sometimes alleviates the problem...
  // Even when only HilTimerMilliC is using it, things can go badly awry.
  // For a quick demonstration, change the Timer1 and Timer2 values in
  // apps/Blink/BlinkC.nc to something like 261 and 333 and the timers will
  // stop firing after only a few seconds...

  components new RtcAlarmMilli32C() as RtcAlarm;
  Alarm = RtcAlarm;

#else
  // Use a non-RTC alarm for now. This prevents entering power-saving mode too.

  components new Alarm32kHz16C () as AlarmFrom;
  components CounterMilli32C as Counter;
  components new TransformAlarmC (TMilli, uint32_t, T32khz, uint16_t, 5) as Transform;

  AlarmMilli32 = Transform;

  Transform.AlarmFrom -> AlarmFrom;
  Transform.Counter -> Counter;
#endif
}
