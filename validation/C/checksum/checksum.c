// checksum.c
//
// Byte-level checksum: sums every byte of a small static string
// (excluding its terminating '\0'), exercising unsigned char array
// access rather than the int arrays every other test here uses.
// Verified on the host: sum(bytes of "Hello, SPARC!") = 986.

int main(void)
{
    unsigned char data[] = "Hello, SPARC!";
    int i;
    int sum;
    int expected, pass;

    sum = 0;
    for (i = 0; data[i] != '\0'; i++)
        sum += data[i];

    expected = 986; // computed on the host, see the file comment above
    pass = (sum == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0 -- see array_sum.c.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

    // Halt -- see array_sum.c/writing_and_running_assembly_programs.md
    // for this project's pass/fail halt convention.
    __asm__ volatile ("ta 0");

    // Never reached -- see array_sum.c.
    while (1) {}
    return 0;
}
