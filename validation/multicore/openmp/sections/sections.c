// sections.c
//
//   0. each section runs once, in a team of four
//   1. more sections than threads, and each still runs once
//   2. `parallel sections` as one construct
//   3. lastprivate takes its value from the last section in the source
//   4. sections nowait, followed by more work-shares
//   5. a region with one thread runs every section in order
#include "../openmp_common.h"

static volatile int ran[8];

static void clear_ran(void)
{
	int i;
	for (i = 0; i < 8; i++)
		ran[i] = 0;
}

static int each_ran_once(int n)
{
	int i, right = 1;
	for (i = 0; i < 8; i++)
		if (ran[i] != (i < n ? 1 : 0)) right = 0;
	return right;
}

#define SECTION(n) _Pragma("omp section") ran[n]++;

int main(void)
{
	unsigned ok = 0;

	clear_ran();
#pragma omp parallel
	{
#pragma omp sections
		{
			SECTION(0) SECTION(1) SECTION(2)
		}
	}
	if (each_ran_once(3)) ok |= 1 << 0;

	clear_ran();
#pragma omp parallel
	{
#pragma omp sections
		{
			SECTION(0) SECTION(1) SECTION(2) SECTION(3) SECTION(4) SECTION(5) SECTION(6) SECTION(7)
		}
	}
	if (each_ran_once(8)) ok |= 1 << 1;

	clear_ran();
#pragma omp parallel sections
	{
		SECTION(0) SECTION(1) SECTION(2) SECTION(3) SECTION(4)
	}
	if (each_ran_once(5)) ok |= 1 << 2;

	{
		int value = 0;
#pragma omp parallel sections lastprivate(value)
		{
#pragma omp section
			value = 1;
#pragma omp section
			value = 2;
#pragma omp section
			value = 3;
		}
		if (value == 3) ok |= 1 << 3;
	}

	{
		static volatile int after[4];
		int i, right = 1;
		clear_ran();
#pragma omp parallel private(i)
		{
#pragma omp sections nowait
			{
				SECTION(0) SECTION(1)
			}
#pragma omp for schedule(dynamic)
			for (i = 0; i < 4; i++) after[i] = 1;
		}
		for (i = 0; i < 4; i++) if (!after[i]) right = 0;
		if (right && each_ran_once(2)) ok |= 1 << 4;
	}

	{
		int order = 0, right = 1;
#pragma omp parallel num_threads(1)
		{
#pragma omp sections
			{
#pragma omp section
				{ if (order != 0) right = 0; order = 1; }
#pragma omp section
				{ if (order != 1) right = 0; order = 2; }
			}
		}
		if (right && order == 2) ok |= 1 << 5;
	}

	report(ok, 6);
	return 0;
}
