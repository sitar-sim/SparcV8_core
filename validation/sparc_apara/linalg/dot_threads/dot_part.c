// dot_part.c: an engine program, compiled with apcc.py: thread t's part
// of a 1024-element int8 dot product, 8 elements per $dot. An __entry
// function's parameters arrive in $r1, $r2, $r3 (set by the SPARC).

#define N 1024
int8_t A[N];
int8_t B[N];
int64_t partial[4];

__entry void part(int64_t t, int64_t first, int64_t count)
{
    int64_t s = 0;
    for (int64_t i = first; i < first + count; i += 8)
        s = __dot_acc("vi8", s, __ld64(&A[i]), __ld64(&B[i]));
    partial[t] = s;
}
