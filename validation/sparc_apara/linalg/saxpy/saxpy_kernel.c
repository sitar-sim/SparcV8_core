// saxpy_kernel.c: an engine program, compiled with apcc.py: y = a*x + y
// on 32 floats.

#define N 32
float x[N];
float y[N];
float a;

void main(void)
{
    float s = a;
    for (int64_t i = 0; i < N; i++)
        y[i] = s * x[i] + y[i];
}
