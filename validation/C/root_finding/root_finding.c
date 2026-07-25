// root_finding.c
//
// Integer square root of a static constant via Newton-Raphson: iterate
// x_{k+1} = (x_k + n/x_k) / 2 (integer division throughout, so every step
// is exact and reproducible -- no floating point, unlike the textbook
// version of this method) until it stops decreasing, which is
// floor(sqrt(n)) for this iteration. Verified against Python's exact
// integer isqrt: isqrt(12345) = 111 (111^2=12321, 112^2=12544).

int main(void)
{
    int n = 12345;
    int xk, xk1;
    int expected, pass;

    xk = n;
    for (;;)
    {
        xk1 = (xk + n / xk) / 2;
        if (xk1 >= xk)
            break;
        xk = xk1;
    }

    expected = 111; // floor(sqrt(12345)), computed on the host
    pass = (xk == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0 -- see array_sum.c.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

    // Halt -- see array_sum.c/writing_and_running_assembly_programs.md
    // for this project's pass/fail halt convention.
    __asm__ volatile ("ta 0");

    // Never reached -- see array_sum.c.
    while (1) {}
    return 0;
}
