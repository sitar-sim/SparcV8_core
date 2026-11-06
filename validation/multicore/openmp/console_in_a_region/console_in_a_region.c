// console_in_a_region.c
//
// A program's output from every thread, through the console of multicore_platform.h, which
// takes its own lock. Each line must arrive whole, in any order.
#include "../openmp_common.h"
#include "multicore_platform.h"

int main(void)
{
	static const char* const lines[TEAM] =
	{
		"thread 0 says hello\n", "thread 1 says hello\n",
		"thread 2 says hello\n", "thread 3 says hello\n"
	};
	console_start();
#pragma omp parallel
	console_puts(lines[omp_get_thread_num()]);
	console_wait_until_sent();
	report(1, 1);
	return 0;
}
