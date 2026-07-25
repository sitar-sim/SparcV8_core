// dot_product.c
//
// Dot product of two small static integer vectors. Verified on the
// host: {1,2,3,4,5} . {5,4,3,2,1} = 5+8+9+8+5 = 35.

int main(void)
{
    int a[5] = {1, 2, 3, 4, 5};
    int b[5] = {5, 4, 3, 2, 1};
    int i;
    int sum;
    int expected, pass;

    sum = 0;
    for (i = 0; i < 5; i++)
        sum += a[i] * b[i];

    expected = 35; // computed on the host, see the file comment above
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
