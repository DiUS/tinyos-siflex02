module ExecC
{
  provides interface Exec;
}
implementation
{
  command void Exec.exec()
  {
    uint8_t tmp;

    cli ();

    // Move interrupt vectors over to the application section
    tmp = PMIC.CTRL & ~PMIC_IVSEL_bm;
    CCP = CCP_IOREG_gc;
    PMIC.CTRL = tmp;

    asm volatile ("jmp 0");
  }
}
