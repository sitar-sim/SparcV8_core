// swap_counter.c
//
// The same test as ldstub_counter, with the lock taken by a bare SWAP loop.
// A word holding 0 is free. SWAP writes 1 and returns what was there.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and the total is NUM_CORES * ITERATIONS
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 100

static volatile uint32_t lock;

#define COUNTER ((volatile uint32_t*) SHARED_BASE)
#define DONE    ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 0, mine = 0, i;
	for (i = 0; i < ITERATIONS; i++)
	{
		while (atomic_swap(&lock, 1) != 0)
			;
		*COUNTER = read_shared(COUNTER) + 1;
		mine++;
		lock = 0;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(DONE) && read_shared(COUNTER) == NUM_CORES * ITERATIONS) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
