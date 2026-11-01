// parallel_matmul.c
//
// A worked example for the docs (Ref docs/source/multicore/examples.md):
// the four cores compute C = A x B together, for 16 x 16 matrices.
//
//   1. Core 0 fills in A and B, then sets the flag inputs_ready. The
//      other cores wait for the flag, then flush their own caches, so
//      that their loads of A and B come from main memory.
//   2. Core i computes rows 4i to 4i+3 of C, then sets its own done
//      flag.
//   3. Core 0 waits for every done flag, then flushes its caches and
//      checks every element of C, and stores a checksum of C in shared
//      memory, where the .vprj checks it.
//
// The flushes matter only when the caches are in use
// (SPARC_ALWAYS_CACHEABLE=1, or the MMU on). Core 0's flush is needed:
// core 0 cleared .bss, C included, so without it core 0 reads its own
// cached zeros instead of the other cores' rows. The other cores' flush
// is a safeguard. Their caches have never held A or B in this program,
// but a core that had read them before core 0 wrote them would need it.
//
// Every core:
//   0. (core 0) found every element of C right, and saw every done flag
//      (other cores) saw the inputs_ready flag.

#include "../../multicore_common.h"

#define N             16
#define ROWS_PER_CORE (N / NUM_CORES)
#define CHECKSUM_ADDR SHARED_BASE

int A[N][N], B[N][N], C[N][N];

// In .bss, so core 0 has cleared them before any core reaches main().
volatile uint32_t inputs_ready;
volatile uint32_t done[NUM_CORES];

static int a_at(int i, int j) { return i + 2 * j + 1; }
static int b_at(int i, int j) { return (i == j) ? 2 : (i - j) & 3; }

static int wait_for(volatile uint32_t* flag)
{
	int polls = 0;
	while (read_shared(flag) == 0 && polls < WAIT_LIMIT)
		polls++;
	return polls < WAIT_LIMIT;
}

int main(void)
{
	uint32_t ok = 0;
	uint32_t id = this_core_id();
	int i, j, k;

	//1. Core 0 produces the inputs, the others wait for them.
	if (id == 0)
	{
		for (i = 0; i < N; i++)
			for (j = 0; j < N; j++)
			{
				A[i][j] = a_at(i, j);
				B[i][j] = b_at(i, j);
			}
		inputs_ready = 1;
		ok |= 1 << 0;
	}
	else
	{
		if (wait_for(&inputs_ready))
			ok |= 1 << 0;
		flush_caches();
	}

	//2. Every core computes its own block of rows.
	for (i = id * ROWS_PER_CORE; i < (id + 1) * ROWS_PER_CORE; i++)
		for (j = 0; j < N; j++)
		{
			int sum = 0;
			for (k = 0; k < N; k++)
				sum += A[i][k] * B[k][j];
			C[i][j] = sum;
		}
	done[id] = 1;

	//3. Core 0 gathers and checks the result.
	if (id == 0)
	{
		int all_done = 1, all_right = 1;
		uint32_t checksum = 0;
		for (k = 0; k < NUM_CORES; k++)
			if (!wait_for(&done[k]))
				all_done = 0;
		flush_caches();
		for (i = 0; i < N; i++)
			for (j = 0; j < N; j++)
			{
				int expected = 0;
				for (k = 0; k < N; k++)
					expected += a_at(i, k) * b_at(k, j);
				if (C[i][j] != expected)
					all_right = 0;
				checksum = checksum * 31 + (uint32_t) C[i][j];
			}
		*(volatile uint32_t*) CHECKSUM_ADDR = checksum;
		if (!(all_done && all_right))
			ok = 0;
	}

	report_and_halt(ok, 1);
	return 0;
}
