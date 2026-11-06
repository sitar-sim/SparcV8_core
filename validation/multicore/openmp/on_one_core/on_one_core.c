// on_one_core.c
//
// With --run-cores 1 only core 0 runs. The census at startup finds that, and every region
// gets a team of one. The program must still finish and get the right answers.
//   0. one processor, and a region would get one thread
//   1. a region and a `parallel for` run in full on one thread
//   2. every kind of work-share, and a barrier, on that one thread
#include "../openmp_common.h"

int main(void)
{
	unsigned ok = 0;
	int sum = 0, i;

	if (omp_get_num_procs() == 1 && omp_get_max_threads() == 1 && omp_get_thread_limit() == 1)
		ok |= 1 << 0;

#pragma omp parallel for reduction(+:sum) schedule(dynamic, 2)
	for (i = 1; i <= 10; i++) sum += i;
	if (sum == 55 && omp_get_num_threads() == 1) ok |= 1 << 1;

	{
		volatile int ran = 0;
#pragma omp parallel
		{
#pragma omp single
			ran += 1;
#pragma omp sections
			{
#pragma omp section
				ran += 10;
#pragma omp section
				ran += 100;
			}
#pragma omp for schedule(guided)
			for (i = 0; i < 4; i++) ran += 1000;
#pragma omp barrier
#pragma omp critical
			ran += 10000;
		}
		if (ran == 14111) ok |= 1 << 2;
	}

	report(ok, 3);
	return 0;
}
