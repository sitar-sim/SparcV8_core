// num_procs.c
//
// What only the bare-metal runtime can promise.
//   0. the census finds all four cores
//   1. main() returning ends the run, with its value in %o0, and the workers halt
#include <omp.h>

int main(void)
{
	return (omp_get_num_procs() == 4 && omp_get_thread_limit() == 4) ? 0x2a : 0;
}
