// array_sum.c
//
// A first bare-metal C validation test, and the template every other
// validation/C/ test follows: sums the elements of a small integer array
// in a loop, then checks the result against a golden value computed once
// on the host machine (here, by hand: 1+2+3+4+5=15) and hardcoded below.
// Self-validating this way means the .vprj only ever has to check one
// thing -- that %o0 is 1 -- rather than re-embedding (and risking a
// second, independent typo in) the actual expected sum.
//
// See docs/writing_and_running_c_programs.md and compiler/crt0.s for how
// this gets a working stack, trap table, and pass/fail halt convention,
// the same way every validation/asm/ test does.

int main(void)
{
    int values[5] = {1, 2, 3, 4, 5};
    int sum = 0;
    int i;
    int expected;
    int pass;

    for (i = 0; i < 5; i++)
        sum += values[i];

    expected = 15; // 1+2+3+4+5, computed on the host
    pass = (sum == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0 -- see the file comment above.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

    // Halt: traps are enabled (crt0.s), so this ta 0 is caught by its
    // trap-table slot, which re-traps with traps now disabled, forcing
    // the model into error_mode. That's this project's pass/fail halt
    // convention, see writing_and_running_assembly_programs.md.
    __asm__ volatile ("ta 0");

    // Never reached: ta 0 above always halts the simulation first. This
    // just satisfies the compiler, which otherwise warns that a
    // non-void main() falls off the end without returning a value.
    while (1) {}
    return 0;
}
