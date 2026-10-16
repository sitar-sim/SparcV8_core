// The sieve of Eratosthenes below 100: the primes, and how many.
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

#define LIMIT 100
uint8_t composite[LIMIT];
int16_t primes[32];
int64_t count;

void main(void)
{
    int64_t n = 0;
    for (int64_t i = 2; i < LIMIT; i++) {
        if (composite[i])
            continue;
        primes[n] = i;
        n++;
        for (int64_t j = i * i; j < LIMIT; j += i)
            composite[j] = 1;
    }
    count = n;
}
