interface Reset
{
  /**
   * Performs a soft reset by unconditionally jumping to the init vector.
   */
  async command void softReset ();
}
