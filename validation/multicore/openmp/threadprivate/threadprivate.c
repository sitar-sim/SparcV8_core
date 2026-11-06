// threadprivate.c
//
//   0. each thread has its own copy of a threadprivate variable
//   1. a thread's copy keeps its value from one region to the next
//   2. an initialized threadprivate variable starts with its value on every thread
//   3. copyin gives every thread the value core 0 has
//   4. the copies of an array do not overlap
#include "../openmp_common.h"

static int counter;
static int initialized = 77;
static int block[8];
#pragma omp threadprivate(counter, initialized, block)

int main(void)
{
	unsigned ok = 0;

	{
		int right = 1;
#pragma omp parallel
		{
			counter = omp_get_thread_num() + 1;
#pragma omp barrier
			if (counter != omp_get_thread_num() + 1) right = 0;
		}
		if (right) ok |= 1 << 0;
	}

	{
		int right = 1;
#pragma omp parallel
		{
			if (counter != omp_get_thread_num() + 1) right = 0;
		}
		if (right) ok |= 1 << 1;
	}

	{
		int right = 1;
#pragma omp parallel
		{
			if (initialized != 77) right = 0;
			initialized = omp_get_thread_num();
		}
		if (right) ok |= 1 << 2;
	}

	{
		int right = 1;
		counter = 500;
#pragma omp parallel copyin(counter)
		{
			if (counter != 500) right = 0;
		}
		if (right) ok |= 1 << 3;
	}

	{
		int right = 1;
#pragma omp parallel
		{
			int i, me = omp_get_thread_num();
			for (i = 0; i < 8; i++) block[i] = me * 10 + i;
#pragma omp barrier
			for (i = 0; i < 8; i++) if (block[i] != me * 10 + i) right = 0;
		}
		if (right) ok |= 1 << 4;
	}

	report(ok, 5);
	return 0;
}
