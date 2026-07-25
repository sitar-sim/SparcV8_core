// gcd.c
//
// Euclidean algorithm, run over three static pairs and summed into one
// checksum. Verified on the host (Python's math.gcd):
//   gcd(48,18)=6, gcd(1071,462)=21, gcd(270,192)=6 -- sum = 33

int main(void)
{
    int avals[3] = {48, 1071, 270};
    int bs[3]  = {18, 462, 192};
    int i;
    int a, b, t;
    int sum;
    int expected, pass;

    sum = 0;
    for (i = 0; i < 3; i++)
    {
        a = avals[i];
        b = bs[i];
        while (b != 0)
        {
            t = b;
            b = a % b;
            a = t;
        }
        sum += a;
    }

    expected = 33; // computed on the host, see the file comment above
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
