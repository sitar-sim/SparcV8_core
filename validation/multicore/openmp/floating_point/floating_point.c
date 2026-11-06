// floating_point.c
//
// Numeric work on every thread, which needs the FPU on, on every core.
//   0. a dot product with reduction(+) on a double
//   1. atomic on a double
//   2. critical around a float, and every thread can compute with floats
//   3. a double and a float keep their values across a barrier, on each thread
#include "../openmp_common.h"

#define N 40
static double x[N], y[N];

int main(void)
{
	unsigned ok = 0;
	int i;

	for (i = 0; i < N; i++)
	{
		x[i] = i + 0.5;
		y[i] = 2.0;
	}

	{
		double dot = 0.0;
#pragma omp parallel for schedule(dynamic, 3) reduction(+:dot)
		for (i = 0; i < N; i++)
			dot += x[i] * y[i];
		if (dot == 1600.0) ok |= 1 << 0;
	}

	{
		double total = 1.0;
#pragma omp parallel
		{
#pragma omp atomic
			total += 0.25;
		}
		if (total == 2.0) ok |= 1 << 1;
	}

	{
		float sum = 0.0f;
#pragma omp parallel
		{
			float mine = (omp_get_thread_num() + 1) * 1.5f;
#pragma omp critical
			sum += mine;
		}
		if (sum == 15.0f) ok |= 1 << 2;
	}

	{
		int right = 1;
#pragma omp parallel
		{
			double d = omp_get_thread_num() * 3.0;
			float f = omp_get_thread_num() * 0.5f;
#pragma omp barrier
			if (d != omp_get_thread_num() * 3.0 || f != omp_get_thread_num() * 0.5f) right = 0;
		}
		if (right) ok |= 1 << 3;
	}

	report(ok, 4);
	return 0;
}
