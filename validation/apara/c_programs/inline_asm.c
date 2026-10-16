// Inline mcode: __asm__ with %name for a variable's register. Here a
// $vreduce (no intrinsic needed) and a hand-written bundle.
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

int64_t out[2];

void main(void)
{
    int64_t v = 0x0102030405060708;
    int64_t s = 0;
    int64_t t = 0;
    __asm__("$vreduce + %s ($vi8) %v");      // 36
    __asm__("|| + %t ($i64) %s %s  - %v ($i64) %v %v ;");   // t = 72, v = 0 (both read the old values)
    out[0] = s + v;
    out[1] = t;
}
