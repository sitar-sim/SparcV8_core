// lock_in_scratchpad.c
//
// Atomic instructions on a device rather than main memory. Two locks live in
// the scratch-pad, one taken with SWAP and one with LDSTUB, and each protects
// a counter in main memory. Devices are never cached, and the bridge's lock
// covers every target, so these must exclude one another just as in memory.
// This is how a program can have a lock before the MMU or caches are set up.
//
// Word 0 of the scratch-pad is the startup file's release flag, so the locks
// use words 1 and 2.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and both totals are NUM_CORES * ITERATIONS
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 50

#define SWAP_LOCK   ((volatile uint32_t*) 0xFFFF2C04u)
#define LDSTUB_LOCK ((volatile uint8_t*)  0xFFFF2C08u)

#define COUNTER_A ((volatile uint32_t*) SHARED_BASE)
#define COUNTER_B ((volatile uint32_t*) (SHARED_BASE + 4))
#define DONE      ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 0, mine = 0, i;
	for (i = 0; i < ITERATIONS; i++)
	{
		while (atomic_swap(SWAP_LOCK, 1) != 0)
			;
		*COUNTER_A = read_shared(COUNTER_A) + 1;
		*SWAP_LOCK = 0;

		while (atomic_ldstub(LDSTUB_LOCK) != 0)
			;
		*COUNTER_B = read_shared(COUNTER_B) + 1;
		*LDSTUB_LOCK = 0;
		mine++;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(DONE)
	    && read_shared(COUNTER_A) == NUM_CORES * ITERATIONS
	    && read_shared(COUNTER_B) == NUM_CORES * ITERATIONS)
		ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
