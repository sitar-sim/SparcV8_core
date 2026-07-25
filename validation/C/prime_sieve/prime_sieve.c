// prime_sieve.c
//
// Sieve of Eratosthenes up to a small static N, counting the primes
// found. Verified on the host: 15 primes <= 50 (2, 3, 5, 7, 11, 13, 17,
// 19, 23, 29, 31, 37, 41, 43, 47).

int main(void)
{
    int N = 50;
    int is_prime[51];
    int i, j;
    int count;
    int expected, pass;

    for (i = 0; i <= N; i++)
        is_prime[i] = 1;
    is_prime[0] = 0;
    is_prime[1] = 0;

    for (i = 2; i * i <= N; i++)
    {
        if (is_prime[i])
        {
            for (j = i * i; j <= N; j += i)
                is_prime[j] = 0;
        }
    }

    count = 0;
    for (i = 0; i <= N; i++)
        if (is_prime[i])
            count++;

    expected = 15; // primes <= 50, computed on the host
    pass = (count == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0 -- see array_sum.c.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

    // Halt -- see array_sum.c/writing_and_running_assembly_programs.md
    // for this project's pass/fail halt convention.
    __asm__ volatile ("ta 0");

    // Never reached -- see array_sum.c.
    while (1) {}
    return 0;
}
