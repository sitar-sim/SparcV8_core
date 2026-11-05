// ldstub_counter.c
//
// Every core adds 1 to one shared counter ITERATIONS times, holding a lock
// taken with a bare LDSTUB loop each time. If LDSTUB is atomic across cores,
// only one core at a time is ever inside, so no addition is lost and the
// total is exact. If another core's access can come between LDSTUB's read
// and its write, two cores can both see the lock free, and the counter
// comes up short.
//
// The loop deliberately retries the LDSTUB itself instead of waiting on a
// load first, which keeps the bus as busy with atomics as possible.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and the total is NUM_CORES * ITERATIONS
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 100

static volatile uint8_t lock;

#define COUNTER ((volatile uint32_t*) SHARED_BASE)
#define DONE    ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 0, mine = 0, i;
	for (i = 0; i < ITERATIONS; i++)
	{
		while (atomic_ldstub(&lock) != 0)
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
