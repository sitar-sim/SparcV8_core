// single_and_nowait.c
//
// `single`, copyprivate, and work-shares that threads go through at different speeds.
//   0. single runs once in each region, with its implied barrier
//   1. fifty `single nowait` in a row run once each, on more work-shares than the ring holds
//   2. copyprivate gives every thread the value single set
//   3. several copyprivate variables, repeated
//   4. a thread can run many `for nowait` loops ahead of a slow one, and all iterations run
//   5. two loops after each other with a plain `for` barrier see all of the first's writes
#include "../openmp_common.h"

#define SINGLES 50

static volatile int single_ran[SINGLES];

int main(void)
{
	unsigned ok = 0;

	{
		volatile int count = 0;
		int right = 1;
#pragma omp parallel
		{
#pragma omp single
			{
				int v = count;
				count = v + 1;
			}
			if (count != 1) right = 0;
		}
		if (right && count == 1) ok |= 1 << 0;
	}

	{
		int i, right = 1;
#pragma omp parallel private(i)
		{
			for (i = 0; i < SINGLES; i++)
			{
#pragma omp single nowait
				{
					int v = single_ran[i];
					single_ran[i] = v + 1;
				}
			}
		}
		for (i = 0; i < SINGLES; i++)
			if (single_ran[i] != 1) right = 0;
		if (right) ok |= 1 << 1;
	}

	{
		int right = 1;
#pragma omp parallel
		{
			int value = -1;
#pragma omp single copyprivate(value)
			value = 1234;
			if (value != 1234) right = 0;
		}
		if (right) ok |= 1 << 2;
	}

	{
		int right = 1;
#pragma omp parallel
		{
			int round, a, b, c[3];
			for (round = 0; round < 12; round++)
			{
				a = -1; b = -1; c[0] = c[1] = c[2] = -1;
#pragma omp single copyprivate(a, b, c)
				{
					a = round; b = round * 2; c[0] = 1; c[1] = 2; c[2] = round + 3;
				}
				if (a != round || b != round * 2 || c[0] != 1 || c[1] != 2 || c[2] != round + 3)
					right = 0;
			}
		}
		if (right) ok |= 1 << 3;
	}

	{
		// Thread 3 starts only after the others have finished eight loops, which fills the
		// runtime's ring of work-shares. They must wait for it, not take over its slots.
		static volatile int ran[30][8];
		static volatile int loops_finished;
		int l, i, right = 1;
#pragma omp parallel private(l, i)
		{
			if (omp_get_thread_num() == 3)
			{
				volatile int d;
				while (loops_finished < 8)
					;
				for (d = 0; d < 500; d++)
					;
			}
			for (l = 0; l < 30; l++)
			{
#pragma omp for schedule(dynamic) nowait
				for (i = 0; i < 8; i++)
				{
					int v = ran[l][i];
					ran[l][i] = v + 1;
				}
				if (l + 1 > loops_finished)
					loops_finished = l + 1;
			}
		}
		for (l = 0; l < 30; l++)
			for (i = 0; i < 8; i++)
				if (ran[l][i] != 1) right = 0;
		if (right) ok |= 1 << 4;
	}

	{
		static volatile int first[16];
		volatile int wrong = 0;
		int i;
#pragma omp parallel private(i)
		{
#pragma omp for schedule(dynamic)
			for (i = 0; i < 16; i++) first[i] = i + 1;
#pragma omp for schedule(dynamic)
			for (i = 0; i < 16; i++) if (first[15 - i] != 16 - i) wrong = 1;
		}
		if (!wrong) ok |= 1 << 5;
	}

	report(ok, 6);
	return 0;
}
