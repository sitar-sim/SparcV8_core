// lock_and_counter_with_plain_loads.c
//
// What coherence makes possible: a program written as if the caches were not there.
// Every core adds to one counter under a spinlock, and both the spin and the counter
// use plain cached loads. Without coherence, a core waiting on its cached copy of
// the lock would never see it released, and the total would come up short.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and the total is NUM_CORES * ITERATIONS
#include "../coherence_common.h"

#define ITERATIONS 100

static volatile uint8_t lock;

#define COUNTER SHARED_WORD(0)
#define DONE    ((volatile uint32_t*) SHARED_WORD(1))

int main(void)
{
	uint32_t ok = 0, mine = 0, i;
	turn_caching_on();

	for (i = 0; i < ITERATIONS; i++)
	{
		while (atomic_ldstub(&lock) != 0)
			while (lock != 0)
				;
		*COUNTER = *COUNTER + 1;
		mine++;
		lock = 0;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(DONE) && *COUNTER == NUM_CORES * ITERATIONS) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
