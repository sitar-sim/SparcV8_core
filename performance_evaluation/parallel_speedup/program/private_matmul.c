// The parallel speedup demo's workload. Every core multiplies its own
// private N x N integer matrices REPS times, in nested loops, and shares
// no data with the other cores. Each core's three matrices (3 x 24 x 24
// words, about 7 KB) fit in its own D-cache, so with caching on the
// cores rarely use the bus, and the work per simulated cycle stays high.
//
// Core i writes a checksum of its product to RESULTS_BASE + 4*i and
// halts with %o0 = 1. REPS sets the run's length.
#include "../../../validation/multicore/multicore_common.h"

#define N    24
#define REPS 16

#define RESULTS_BASE 0x00100000u

int A[NUM_CORES][N][N], B[NUM_CORES][N][N], C[NUM_CORES][N][N];

int main(void)
{
	uint32_t id = this_core_id();
	int i, j, k, r;
	int (*a)[N] = A[id], (*b)[N] = B[id], (*c)[N] = C[id];

	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
		{
			a[i][j] = i + j + id;
			b[i][j] = i - j;
		}

	for (r = 0; r < REPS; r++)
		for (i = 0; i < N; i++)
			for (j = 0; j < N; j++)
			{
				int sum = 0;
				for (k = 0; k < N; k++)
					sum += a[i][k] * b[k][j];
				c[i][j] = sum + r;
			}

	uint32_t check = 0;
	for (i = 0; i < N; i++)
		for (j = 0; j < N; j++)
			check += c[i][j];
	((volatile uint32_t*) RESULTS_BASE)[id] = check;
	report_and_halt(1, 1);
	return 0;
}
