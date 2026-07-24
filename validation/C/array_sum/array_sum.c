// array_sum.c
//
// A first bare-metal C validation test: sums the elements of a small
// integer array in a loop, storing the result in a global variable, then
// halts. Exercises a local array (compound data type), a loop (a sequence
// of operations, rather than one opcode at a time), and a global variable
// store.
//
// See docs/writing_and_running_c_programs.md and compiler/crt0.s for how
// this gets a working stack, trap table, and pass/fail halt convention,
// the same way every validation/asm/ test does.

int result;

int main(void)
{
    int values[5] = {1, 2, 3, 4, 5};
    int sum = 0;
    int i;

    for (i = 0; i < 5; i++)
        sum += values[i];

    result = sum;

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
