// vector_stats.c: an engine program, compiled with apcc.py. The sum,
// minimum and maximum of 64 int32 values in DMEM.

#define N 64
int32_t data[N];
int64_t sum;
int64_t minimum;
int64_t maximum;

void main(void)
{
    int64_t s = 0;
    int64_t lo = data[0];
    int64_t hi = data[0];
    for (int64_t i = 0; i < N; i++) {
        int64_t v = data[i];
        s += v;
        if (v < lo)
            lo = v;
        if (v > hi)
            hi = v;
    }
    sum = s;
    minimum = lo;
    maximum = hi;
}
