// C = A x B as matmul.c, on three threads: each runs the same entry
// function for its own rows. An __entry function's parameters arrive in
// $r1, $r2, ... (the .vprj's INIT sets each thread's).
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

#define N 6
int32_t A[N][N] = {{8, 24, 17, -46, -19, -14}, {-2, -8, -21, -29, -1, 23}, {31, -36, -47, 44, -15, -19}, {-46, -14, 39, 47, -32, 9}, {2, 16, 19, 39, -36, -28}, {-16, 3, 12, -18, -40, -12}};
int32_t B[N][N] = {{13, -16, -4, 31, -19, 38}, {-19, 14, 20, -30, -19, -21}, {-16, -44, 42, 15, 11, -3}, {28, -23, 8, 14, 41, 11}, {-33, 6, 21, -12, 11, 12}, {-39, -25, -31, 44, -12, -40}};
int64_t C[N][N];

__entry void rows(int64_t first, int64_t count)
{
    for (int64_t i = first; i < first + count; i++)
        for (int64_t j = 0; j < N; j++) {
            int64_t sum = 0;
            for (int64_t k = 0; k < N; k++)
                sum += A[i][k] * B[k][j];
            C[i][j] = sum;
        }
}
