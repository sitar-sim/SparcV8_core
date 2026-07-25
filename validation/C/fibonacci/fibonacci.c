// fibonacci.c
//
// Iterative Fibonacci (no recursion, so no stack-depth surprises), 20
// terms in, fib(0)=0. Verified on the host: fib(20) = 6765, well within
// a 32-bit int (no overflow risk at this N).

int main(void)
{
    int n = 20;
    int a = 0, b = 1;
    int i, t;
    int expected, pass;

    for (i = 0; i < n; i++)
    {
        t = a + b;
        a = b;
        b = t;
    }

    expected = 6765; // fib(20), computed on the host
    pass = (a == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0 -- see array_sum.c.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

    // Halt -- see array_sum.c/writing_and_running_assembly_programs.md
    // for this project's pass/fail halt convention.
    __asm__ volatile ("ta 0");

    // Never reached -- see array_sum.c.
    while (1) {}
    return 0;
}
