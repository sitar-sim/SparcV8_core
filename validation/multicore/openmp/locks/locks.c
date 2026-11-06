// locks.c
//
//   0. omp_set_lock and omp_unset_lock protect a counter
//   1. omp_test_lock takes a free lock and refuses a held one
//   2. a nested lock can be taken again by its owner, and stays held until the last unset
//   3. omp_test_nest_lock returns the depth for the owner, and 0 for another thread
//   4. a nested lock protects a counter across threads
#include "../openmp_common.h"

#define ROUNDS 50

int main(void)
{
	unsigned ok = 0;
	omp_lock_t lock;
	omp_nest_lock_t nest;
	volatile int counter = 0;

	omp_init_lock(&lock);
#pragma omp parallel
	{
		int i;
		for (i = 0; i < ROUNDS; i++)
		{
			int v;
			omp_set_lock(&lock);
			v = counter;
			counter = v + 1;
			omp_unset_lock(&lock);
		}
	}
	if (counter == ROUNDS * TEAM) ok |= 1 << 0;

	{
		volatile int refused = -1;
		int taken = omp_test_lock(&lock);
#pragma omp parallel num_threads(2)
		{
			if (omp_get_thread_num() == 1)
				refused = omp_test_lock(&lock);
		}
		omp_unset_lock(&lock);
		if (taken && refused == 0 && omp_test_lock(&lock))
			ok |= 1 << 1;
		omp_unset_lock(&lock);
	}
	omp_destroy_lock(&lock);

	omp_init_nest_lock(&nest);
	{
		volatile int refused_held = -1, refused_after_one = -1, taken_at_end = -1;
		omp_set_nest_lock(&nest);
		omp_set_nest_lock(&nest);
#pragma omp parallel num_threads(2)
		{
			if (omp_get_thread_num() == 1)
				refused_held = omp_test_nest_lock(&nest);
		}
		omp_unset_nest_lock(&nest);
#pragma omp parallel num_threads(2)
		{
			if (omp_get_thread_num() == 1)
				refused_after_one = omp_test_nest_lock(&nest);
		}
		omp_unset_nest_lock(&nest);
#pragma omp parallel num_threads(2)
		{
			if (omp_get_thread_num() == 1)
			{
				taken_at_end = omp_test_nest_lock(&nest);
				omp_unset_nest_lock(&nest);
			}
		}
		if (refused_held == 0 && refused_after_one == 0 && taken_at_end == 1)
			ok |= 1 << 2;
	}

	{
		int first = omp_test_nest_lock(&nest);
		int second = omp_test_nest_lock(&nest);
		omp_unset_nest_lock(&nest);
		omp_unset_nest_lock(&nest);
		if (first == 1 && second == 2) ok |= 1 << 3;
	}

	counter = 0;
#pragma omp parallel
	{
		int i;
		for (i = 0; i < ROUNDS; i++)
		{
			int v;
			omp_set_nest_lock(&nest);
			omp_set_nest_lock(&nest);
			v = counter;
			counter = v + 1;
			omp_unset_nest_lock(&nest);
			omp_unset_nest_lock(&nest);
		}
	}
	if (counter == ROUNDS * TEAM) ok |= 1 << 4;
	omp_destroy_nest_lock(&nest);

	report(ok, 5);
	return 0;
}
