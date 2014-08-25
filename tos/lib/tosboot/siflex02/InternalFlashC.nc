configuration InternalFlashC
{
  provides interface InternalFlash;
}
implementation
{
  components InternalFlashP, HplAtxm256EepromP as Eeprom;
  InternalFlashP.Eeprom -> Eeprom;
  InternalFlashP.EepromInit -> Eeprom;

  InternalFlash = InternalFlashP;
}
