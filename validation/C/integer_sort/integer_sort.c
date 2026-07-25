// integer_sort.c
//
// Bubble sort of a small static integer array, checked with a
// position-weighted checksum (sum of sorted[i]*(i+1)) rather than just
// the plain sum -- the plain sum is invariant under any reordering of
// the same elements, so it wouldn't actually catch a sort that ran but
// produced the wrong order. Verified on the host:
//   input  = {5,3,8,1,9,2,7,4}
//   sorted = {1,2,3,4,5,7,8,9}
//   weighted checksum = 1*1+2*2+3*3+4*4+5*5+7*6+8*7+9*8 = 225

int main(void)
{
    int a[8] = {5, 3, 8, 1, 9, 2, 7, 4};
    int i, j, tmp;
    int checksum;
    int expected, pass;

    for (i = 0; i < 7; i++)
    {
        for (j = 0; j < 7 - i; j++)
        {
            if (a[j] > a[j+1])
            {
                tmp = a[j];
                a[j] = a[j+1];
                a[j+1] = tmp;
            }
        }
    }

    checksum = 0;
    for (i = 0; i < 8; i++)
        checksum += a[i] * (i + 1);

    expected = 225; // computed on the host, see the file comment above
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
