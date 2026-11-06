// ordered_loops.c
//
// An `ordered` block in a loop runs in the loop's order, whichever thread has the iteration.
//   0. schedule(static), no chunk
//   1. schedule(static, 2)
//   2. schedule(dynamic)
//   3. schedule(dynamic, 3)
//   4. schedule(guided)
//   5. schedule(runtime)
//   6. a loop counting down
//   7. iterations that skip the ordered block hold nobody up
//   8. the work outside the block really runs in parallel
//   9. a chunk that skips the block, finishing before an older chunk, keeps the order
#include "../openmp_common.h"

#define PRAGMA(x) _Pragma(#x)

#define N 24
static volatile int sequence[N];
static volatile int filled;

static void clear_sequence(void)
{
	int i;
	for (i = 0; i < N; i++)
		sequence[i] = -1;
	filled = 0;
}

static int in_order(int n)
{
	int i, right = filled == n;
	for (i = 0; i < n; i++)
		if (sequence[i] != i) right = 0;
	return right;
}

#define CHECK_ORDERED(sched, bit) do { int i_; clear_sequence(); \
	_Pragma("omp parallel") { \
		PRAGMA(omp for ordered sched) \
		for (i_ = 0; i_ < N; i_++) { \
			_Pragma("omp ordered") \
			{ sequence[filled] = i_; filled = filled + 1; } \
		} } \
	if (in_order(N)) ok |= 1 << (bit); } while (0)

int main(void)
{
	unsigned ok = 0;
	int i;

	CHECK_ORDERED(schedule(static), 0);
	CHECK_ORDERED(schedule(static, 2), 1);
	CHECK_ORDERED(schedule(dynamic), 2);
	CHECK_ORDERED(schedule(dynamic, 3), 3);
	CHECK_ORDERED(schedule(guided), 4);
	omp_set_schedule(omp_sched_dynamic, 2);
	CHECK_ORDERED(schedule(runtime), 5);

	clear_sequence();
#pragma omp parallel
	{
#pragma omp for ordered schedule(dynamic)
		for (i = N - 1; i >= 0; i--)
		{
#pragma omp ordered
			{
				sequence[filled] = N - 1 - i;
				filled = filled + 1;
			}
		}
	}
	if (in_order(N)) ok |= 1 << 6;

	clear_sequence();
#pragma omp parallel
	{
#pragma omp for ordered schedule(dynamic, 2)
		for (i = 0; i < N; i++)
		{
			if (i % 3 == 0)
			{
#pragma omp ordered
				{
					sequence[filled] = i / 3;
					filled = filled + 1;
				}
			}
		}
	}
	if (in_order(N / 3)) ok |= 1 << 7;

	{
		// Each chunk has one thread, so every thread with a static chunk gets iterations.
		volatile int who[TEAM];
		int t, right = 1;
		for (t = 0; t < TEAM; t++) who[t] = 0;
#pragma omp parallel
		{
#pragma omp for ordered schedule(static)
			for (i = 0; i < N; i++)
			{
				who[omp_get_thread_num()] = 1;
#pragma omp ordered
				filled = filled;
			}
		}
		for (t = 0; t < TEAM; t++) if (!who[t]) right = 0;
		if (right) ok |= 1 << 8;
	}

	{
		// Iteration 1 skips the block and finishes while iteration 0 is still held back, so
		// its thread asks for more work before the turn has reached it.
		static volatile int skipped;
		clear_sequence();
#pragma omp parallel
		{
#pragma omp for ordered schedule(dynamic)
			for (i = 0; i < 9; i++)
			{
				if (i == 0)
				{
					volatile int d;
					while (!skipped)
						;
					for (d = 0; d < 500; d++)
						;
				}
				if (i == 1)
					skipped = 1;
				else
				{
#pragma omp ordered
					{
						sequence[filled] = i == 0 ? 0 : i - 1;
						filled = filled + 1;
					}
				}
			}
		}
		if (in_order(8)) ok |= 1 << 9;
	}

	report(ok, 10);
	return 0;
}
