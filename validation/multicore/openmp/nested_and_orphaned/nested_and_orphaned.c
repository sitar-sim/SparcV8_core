// nested_and_orphaned.c
//
// A nested region has a team of one here, as it has by default with the host's OpenMP.
//   0. levels outside and inside one region
//   1. a nested region has one thread, and its thread number is 0, on every thread
//   2. back out of a nested region, a thread has its own number and team size again
//   3. a dynamic loop in a nested region runs in full, once per enclosing thread
//   4. nested regions three deep, each with work-shares of its own
//   5. a `for` in a function runs across the team when called in a region
//   6. the same `for` runs in full when called outside any region
//   7. single and barrier outside any region do no harm
//   8. a region with one thread, with another region and a dynamic loop inside it
//   9. omp_get_ancestor_thread_num and omp_get_team_size at each level
#include "../openmp_common.h"

static volatile int loop_runs;

static void orphaned_loop(int n)
{
	int i;
#pragma omp for schedule(dynamic)
	for (i = 0; i < n; i++)
	{
#pragma omp atomic
		loop_runs += 1;
	}
}

int main(void)
{
	unsigned ok = 0;

	if (omp_get_level() == 0 && omp_get_active_level() == 0)
	{
		int right = 1;
#pragma omp parallel
		{
			if (omp_get_level() != 1 || omp_get_active_level() != 1) right = 0;
		}
		if (right) ok |= 1 << 0;
	}

	{
		int inner_right = 1, outer_right = 1;
#pragma omp parallel
		{
			int me = omp_get_thread_num();
#pragma omp parallel
			{
				if (omp_get_num_threads() != 1 || omp_get_thread_num() != 0
				    || omp_get_level() != 2 || !omp_in_parallel())
					inner_right = 0;
			}
			if (omp_get_thread_num() != me || omp_get_num_threads() != TEAM || omp_get_level() != 1)
				outer_right = 0;
		}
		if (inner_right) ok |= 1 << 1;
		if (outer_right) ok |= 1 << 2;
	}

	{
		loop_runs = 0;
#pragma omp parallel
		{
#pragma omp parallel
			{
				int i;
#pragma omp for schedule(dynamic)
				for (i = 0; i < 10; i++)
				{
#pragma omp atomic
					loop_runs += 1;
				}
			}
		}
		if (loop_runs == 10 * TEAM) ok |= 1 << 3;
	}

	{
		loop_runs = 0;
#pragma omp parallel
		{
			int i;
#pragma omp for schedule(dynamic)
			for (i = 0; i < 8; i++)
			{
#pragma omp parallel
				{
					int j;
#pragma omp for schedule(guided)
					for (j = 0; j < 4; j++)
					{
#pragma omp parallel
						{
							int k;
#pragma omp for schedule(dynamic, 2)
							for (k = 0; k < 3; k++)
							{
#pragma omp atomic
								loop_runs += 1;
							}
						}
					}
				}
			}
		}
		if (loop_runs == 8 * 4 * 3) ok |= 1 << 4;
	}

	loop_runs = 0;
#pragma omp parallel
	orphaned_loop(40);
	if (loop_runs == 40) ok |= 1 << 5;

	loop_runs = 0;
	orphaned_loop(25);
	if (loop_runs == 25) ok |= 1 << 6;

	{
		int ran = 0;
#pragma omp single
		ran = 1;
#pragma omp barrier
		if (ran) ok |= 1 << 7;
	}

	{
		loop_runs = 0;
#pragma omp parallel num_threads(1)
		{
#pragma omp parallel
			{
				int i;
#pragma omp for schedule(dynamic)
				for (i = 0; i < 6; i++) loop_runs++;
			}
		}
		if (loop_runs == 6) ok |= 1 << 8;
	}

	{
		int right = 1;
		if (omp_get_ancestor_thread_num(0) != 0 || omp_get_team_size(0) != 1
		    || omp_get_ancestor_thread_num(1) != -1 || omp_get_team_size(1) != -1)
			right = 0;
#pragma omp parallel
		{
			int me = omp_get_thread_num();
#pragma omp parallel
			{
				if (omp_get_ancestor_thread_num(1) != me || omp_get_team_size(1) != TEAM
				    || omp_get_ancestor_thread_num(2) != 0 || omp_get_team_size(2) != 1
				    || omp_get_ancestor_thread_num(0) != 0 || omp_get_team_size(0) != 1)
					right = 0;
			}
		}
		if (right) ok |= 1 << 9;
	}

	report(ok, 10);
	return 0;
}
