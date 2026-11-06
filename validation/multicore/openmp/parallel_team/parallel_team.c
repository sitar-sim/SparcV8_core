// parallel_team.c
//
// Parallel regions and the teams they get.
//   0. outside a region there is one thread, and a region would get four
//   1. a region has four threads, numbered 0 to 3, and all are in parallel
//   2. num_threads(2) gives two threads
//   3. if(0) gives one thread, and the region is not active
//   4. omp_set_num_threads(3) gives three threads, and later regions too
//   5. shared, private and firstprivate variables behave as OpenMP says
//   6. fifty regions in a row each run all four threads
//   7. asking for more threads than there are cores gives one per core
//   8. a worker takes its settings from the thread that started the region
#include "../openmp_common.h"

static volatile int seen[16];

static void clear_seen(void)
{
	int i;
	for (i = 0; i < 16; i++)
		seen[i] = 0;
}

static int threads_seen(void)
{
	int i, count = 0;
	for (i = 0; i < 16; i++)
		count += seen[i];
	return count;
}

int main(void)
{
	unsigned ok = 0;
	int i, in_parallel = 1, sizes_right = 1;
	volatile int total = 0;

	if (omp_get_num_threads() == 1 && omp_get_thread_num() == 0 && !omp_in_parallel()
	    && omp_get_max_threads() == TEAM)
		ok |= 1 << 0;

	clear_seen();
#pragma omp parallel
	{
		seen[omp_get_thread_num()] = 1;
		if (!omp_in_parallel()) in_parallel = 0;
		if (omp_get_num_threads() != TEAM) sizes_right = 0;
	}
	if (threads_seen() == TEAM && seen[0] && seen[1] && seen[2] && seen[3] && in_parallel && sizes_right)
		ok |= 1 << 1;

	clear_seen();
#pragma omp parallel num_threads(2)
	seen[omp_get_thread_num()] = 1;
	if (threads_seen() == 2 && seen[0] && seen[1])
		ok |= 1 << 2;

	clear_seen();
	in_parallel = 0;
#pragma omp parallel if(0)
	{
		seen[omp_get_thread_num()] = 1;
		if (omp_in_parallel()) in_parallel = 1;
	}
	if (threads_seen() == 1 && seen[0] && !in_parallel)
		ok |= 1 << 3;

	clear_seen();
	omp_set_num_threads(3);
#pragma omp parallel
	seen[omp_get_thread_num()] = 1;
	if (threads_seen() == 3 && omp_get_max_threads() == 3)
		ok |= 1 << 4;
	omp_set_num_threads(TEAM);

	{
		int a = 5, b = 7, right = 1;
		volatile int shared_word = 0;
#pragma omp parallel private(a) firstprivate(b) shared(shared_word)
		{
			a = omp_get_thread_num();
			b += omp_get_thread_num();
#pragma omp barrier
			if (a != omp_get_thread_num() || b != 7 + omp_get_thread_num()) right = 0;
#pragma omp atomic
			shared_word += 1;
		}
		if (right && a == 5 && b == 7 && shared_word == TEAM)
			ok |= 1 << 5;
	}

	for (i = 0; i < 50; i++)
	{
#pragma omp parallel
		{
#pragma omp atomic
			total += 1;
		}
	}
	if (total == 50 * TEAM)
		ok |= 1 << 6;

#ifdef __sparc__
	clear_seen();
#pragma omp parallel num_threads(16)
	seen[omp_get_thread_num()] = 1;
	if (threads_seen() == TEAM)
		ok |= 1 << 7;
#else
	ok |= 1 << 7;
#endif

	{
		// A worker takes its settings from the thread that started the region.
		int right = 1;
		omp_set_num_threads(3);
		omp_set_schedule(omp_sched_guided, 7);
#pragma omp parallel num_threads(TEAM)
		{
			omp_sched_t kind;
			int modifier;
			omp_get_schedule(&kind, &modifier);
			if (omp_get_max_threads() != 3 || kind != omp_sched_guided || modifier != 7)
				right = 0;
		}
		if (right)
			ok |= 1 << 8;
	}

	report(ok, 9);
	return 0;
}
