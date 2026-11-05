// flush_inside_lock.c
//
// A lock protects data, but it does not refresh the cache, since the caches
// are not coherent. This program shares a counter under a mutex the other way
// the docs describe, with a plain load after flushing this core's caches inside
// the critical section, not with an uncached load. With
// SPARC_ALWAYS_CACHEABLE=1, each core would otherwise keep reading its own
// old cached copy, and the total would come up short.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and the total is NUM_CORES * ITERATIONS
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 25

static volatile uint8_t mutex;

#define COUNTER ((volatile uint32_t*) SHARED_BASE)
#define DONE    ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 0, mine = 0, i;
	for (i = 0; i < ITERATIONS; i++)
	{
		acquire_mutex_using_ldstub((int) &mutex);
		flush_caches();
		*COUNTER = *COUNTER + 1;
		release_mutex_using_ldstub((int) &mutex);
		mine++;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(DONE) && read_shared(COUNTER) == NUM_CORES * ITERATIONS) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
