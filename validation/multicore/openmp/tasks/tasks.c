// tasks.c
//
//   0. a task's firstprivate is captured when it is created
//   1. tasks from one `single` all run, and taskwait sees them finished
//   2. recursive tasks compute a Fibonacci number
//   3. if(0) and a struct passed by value, which needs copying with the right alignment
//   4. tasks from every thread in a region
#include "../openmp_common.h"

static int fibonacci(int n)
{
	int a, b;
	if (n < 2)
		return n;
#pragma omp task shared(a) firstprivate(n)
	a = fibonacci(n - 1);
#pragma omp task shared(b) firstprivate(n)
	b = fibonacci(n - 2);
#pragma omp taskwait
	return a + b;
}

struct pair
{
	double d;
	int i;
};

int main(void)
{
	unsigned ok = 0;

	{
		static volatile int got[6];
		int i, right = 1;
#pragma omp parallel
		{
#pragma omp single
			for (i = 0; i < 6; i++)
			{
#pragma omp task firstprivate(i)
				got[i] = i + 100;
			}
		}
		for (i = 0; i < 6; i++) if (got[i] != i + 100) right = 0;
		if (right) ok |= 1 << 0;
	}

	{
		volatile int done = 0;
		int seen = -1;
#pragma omp parallel
		{
#pragma omp single
			{
				int i;
				for (i = 0; i < 10; i++)
				{
#pragma omp task
					{
#pragma omp atomic
						done += 1;
					}
				}
#pragma omp taskwait
				seen = done;
			}
		}
		if (seen == 10) ok |= 1 << 1;
	}

	{
		int result = 0;
#pragma omp parallel
		{
#pragma omp single
			result = fibonacci(10);
		}
		if (result == 55) ok |= 1 << 2;
	}

	{
		struct pair p;
		volatile int sum = 0;
		p.d = 1.5;
		p.i = 2;
#pragma omp parallel num_threads(2)
		{
#pragma omp single
			{
#pragma omp task firstprivate(p) if(0)
				{
					if (((unsigned long) &p) % __alignof__(struct pair) == 0 && p.d == 1.5)
						sum += p.i;
				}
#pragma omp task firstprivate(p)
				{
					if (((unsigned long) &p) % __alignof__(struct pair) == 0 && p.d == 1.5)
						sum += p.i * 10;
				}
#pragma omp taskwait
			}
		}
		if (sum == 22) ok |= 1 << 3;
	}

	{
		volatile int total = 0;
#pragma omp parallel
		{
			int me = omp_get_thread_num();
#pragma omp task firstprivate(me)
			{
#pragma omp atomic
				total += me + 1;
			}
#pragma omp taskwait
		}
		if (total == 10) ok |= 1 << 4;
	}

	report(ok, 5);
	return 0;
}
