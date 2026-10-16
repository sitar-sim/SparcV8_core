// A 32-element int32 dot product, one element at a time, compiled
// with -O0 (one instruction per bundle): the same result.
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

#define N 32
int32_t A[N] = {-975, -39, -770, 564, -196, -712, 400, -912, -716, 946, -770, 96, -526, 457, 551, -715, -699, 516, -933, 356, -876, -721, -527, 97, 499, -84, 77, -156, -581, 214, -810, -759};
int32_t B[N] = {-842, 897, -563, -704, -380, 430, 843, -513, 16, -951, 475, -922, -795, -335, 42, -324, 726, -884, 70, 414, 934, 805, -40, -241, 231, -999, 110, 546, 600, -742, 74, -981};
int64_t result;

void main(void)
{
    int64_t sum = 0;
    for (int64_t i = 0; i < N; i++)
        sum += A[i] * B[i];
    result = sum;
}
