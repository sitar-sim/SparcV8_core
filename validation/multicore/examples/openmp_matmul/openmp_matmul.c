// openmp_matmul.c
//
// Multiplies two matrices with one OpenMP pragma, then checks the result against the same
// product computed by core 0 alone. THREADS sets the team's size, to see how the cycle
// count changes with it.
//
// A cached run with coherent caches gives the most realistic timing:
//   sparc_sim_sitar_multicore openmp_matmul.hex "" 50000000 --always-cacheable --coherent
#include <omp.h>
#include <stdint.h>

#ifndef THREADS
#define THREADS 4
#endif
#define N 32

static int32_t a[N][N], b[N][N], c[N][N];

int main(void)
{
	int i, j, k;
	int32_t serial_sum = 0, parallel_sum = 0;

	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
		{
			a[i][j] = i + j;
			b[i][j] = i - j;
		}

	omp_set_num_threads(THREADS);
#pragma omp parallel for private(j, k) schedule(static)
	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
		{
			int32_t sum = 0;
			for (k = 0; k < N; k++)
				sum += a[i][k] * b[k][j];
			c[i][j] = sum;
		}

	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
		{
			int32_t sum = 0;
			for (k = 0; k < N; k++)
				sum += a[i][k] * b[k][j];
			serial_sum += sum;
			parallel_sum += c[i][j];
		}

	omp_end_program(serial_sum == parallel_sum, (uint32_t) parallel_sum);
	return 0;
}
