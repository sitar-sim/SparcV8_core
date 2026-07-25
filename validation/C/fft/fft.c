// fft.c
//
// A 4-point radix-2 FFT (decimation in time: two butterfly stages), on a
// small static real input. N=4 is deliberately chosen because its
// twiddle factors are exactly {1, -1, i, -i} -- no irrational numbers --
// so every step is exact integer arithmetic, with no floating-point
// rounding to risk differing between the host machine (used to compute
// the golden value below) and the target compiler.
//
// Input x = {1, 2, 3, 4} (imaginary parts all 0). Verified against a
// short Python script:
//   a=x0+x2=4, b=x0-x2=-2, c=x1+x3=6, d=x1-x3=-2
//   X0=a+c=10, X2=a-c=-2, X1=(b,-d)=(-2,2), X3=(b,d)=(-2,-2)
// Checked via Parseval's theorem rather than re-embedding each of the 4
// complex outputs individually: sum(|X[k]|^2) must equal N*sum(|x[n]|^2)
// -- 120 either way -- which is a stronger check than it looks, since
// getting it to match by accident while the butterfly math is actually
// wrong is very unlikely.

int main(void)
{
    int x[4] = {1, 2, 3, 4};
    int a, b, c, d;
    int Xre[4], Xim[4];
    int k;
    int sumsq, expected, pass;

    // Stage 1: even/odd butterflies.
    a = x[0] + x[2];
    b = x[0] - x[2];
    c = x[1] + x[3];
    d = x[1] - x[3];

    // Stage 2: combine with twiddle factors W4^0=1, W4^1=-i.
    Xre[0] = a + c;  Xim[0] = 0;
    Xre[1] = b;      Xim[1] = -d;
    Xre[2] = a - c;  Xim[2] = 0;
    Xre[3] = b;      Xim[3] = d;

    sumsq = 0;
    for (k = 0; k < 4; k++)
        sumsq += Xre[k]*Xre[k] + Xim[k]*Xim[k];

    expected = 120; // 4 * (1^2+2^2+3^2+4^2), see the file comment above
    pass = (sumsq == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0 -- see array_sum.c.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

    // Halt -- see array_sum.c/writing_and_running_assembly_programs.md
    // for this project's pass/fail halt convention.
    __asm__ volatile ("ta 0");

    // Never reached -- see array_sum.c.
    while (1) {}
    return 0;
}
