// counter_without_lock.c
//
// What the other tests here are protecting against. Every core adds 1 to one
// shared counter ITERATIONS times with no lock at all. A core reads the
// counter, adds 1 and writes it back, and another core can read the same old
// value in between, so additions get lost. How many depends on how the cores
// interleave, so the total is not checked exactly. With the cores in step, as on
// the sitar_model, only 100 of the 400 survive. Some cpp_model schedules give
// more (--schedule rr:32 gives 215). Compare ldstub_counter, which is this
// program with a lock added.
//
// The final total is left at the start of the shared area, to look at.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and the total is at most NUM_CORES * ITERATIONS,
//      and not 0. The cores can only lose additions, never invent them.
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 100

#define COUNTER ((volatile uint32_t*) SHARED_BASE)
#define DONE    ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 0, mine = 0, i, total;
	for (i = 0; i < ITERATIONS; i++)
	{
		*COUNTER = read_shared(COUNTER) + 1;
		mine++;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(DONE))
	{
		total = read_shared(COUNTER);
		if (total != 0 && total <= NUM_CORES * ITERATIONS) ok |= 1 << 1;
	}
	report_and_halt(ok, 2);
	return 0;
}
