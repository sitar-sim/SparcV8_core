// mutex_routines.c
//
// The AJIT-named mutex routines. Two counters, one protected by each kind of
// mutex. Each core also uses try_acquire_mutex_using_ldstub() once, while the
// lock is held by that core itself, where it must report failure.
//
// Every core checks:
//   0. it finished every iteration
//   1. trying a mutex this core already holds fails
//   2. every core finished, and both totals are NUM_CORES * ITERATIONS
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 50

static volatile uint8_t  ldstub_mutex;
static volatile uint32_t swap_mutex;

#define COUNTER_A ((volatile uint32_t*) SHARED_BASE)
#define COUNTER_B ((volatile uint32_t*) (SHARED_BASE + 4))
#define DONE      ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 1 << 1, mine = 0, i;
	for (i = 0; i < ITERATIONS; i++)
	{
		acquire_mutex_using_ldstub((int) &ldstub_mutex);
		if (try_acquire_mutex_using_ldstub((int) &ldstub_mutex))
			ok &= ~(1u << 1);
		*COUNTER_A = read_shared(COUNTER_A) + 1;
		release_mutex_using_ldstub((int) &ldstub_mutex);

		acquire_mutex_using_swap((int) &swap_mutex);
		*COUNTER_B = read_shared(COUNTER_B) + 1;
		release_mutex_using_swap((int) &swap_mutex);
		mine++;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(DONE)
	    && read_shared(COUNTER_A) == NUM_CORES * ITERATIONS
	    && read_shared(COUNTER_B) == NUM_CORES * ITERATIONS)
		ok |= 1 << 2;
	report_and_halt(ok, 3);
	return 0;
}
