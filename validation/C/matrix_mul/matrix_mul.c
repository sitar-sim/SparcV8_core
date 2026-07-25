// matrix_mul.c
//
// Multiplies two small, static 3x3 integer matrices, sums every element
// of the result into a single checksum, and checks that against a golden
// value computed once on the host (via a short Python script -- see
// array_sum.c for the general self-validating convention this follows).
//
// A = [[1,2,3],[4,5,6],[7,8,9]], B = [[9,8,7],[6,5,4],[3,2,1]]
// A*B = [[30,24,18],[84,69,54],[138,114,90]], element sum = 621.

int main(void)
{
    int A[3][3] = {{1,2,3},{4,5,6},{7,8,9}};
    int B[3][3] = {{9,8,7},{6,5,4},{3,2,1}};
    int C[3][3];
    int i, j, k;
    int checksum;
    int expected;
    int pass;

    for (i = 0; i < 3; i++)
    {
        for (j = 0; j < 3; j++)
        {
            C[i][j] = 0;
            for (k = 0; k < 3; k++)
                C[i][j] += A[i][k] * B[k][j];
        }
    }

    checksum = 0;
    for (i = 0; i < 3; i++)
        for (j = 0; j < 3; j++)
            checksum += C[i][j];

    expected = 621; // computed on the host, see the file comment above
    pass = (checksum == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0 -- see array_sum.c.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

    // Halt -- see array_sum.c/writing_and_running_assembly_programs.md
    // for this project's pass/fail halt convention.
    __asm__ volatile ("ta 0");

    // Never reached -- see array_sum.c.
    while (1) {}
    return 0;
}
