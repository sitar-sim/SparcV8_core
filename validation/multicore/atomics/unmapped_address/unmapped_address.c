// unmapped_address.c
//
// An atomic instruction to an address that maps to nothing must not leave the
// bus locked. The bridge reads such an address as 0 and ignores the write, and
// the lock taken by the read has to be released like any other. Core 3 does
// LDSTUB and SWAP on an unmapped address over and over, while the other cores
// use the bus normally. If the lock were left held, they would stop for ever,
// and the test would fail at its cycle limit.
//
// The run prints a warning for each access to the unmapped address, as it does
// for any such access.
//
// Every core checks:
//   0. core 3: every read returned 0. Others: they finished every iteration
//   1. every core finished, and the total is what cores 0 to 2 added
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 50
#define UNMAPPED   0x80000000u

static volatile uint8_t lock;

#define COUNTER ((volatile uint32_t*) SHARED_BASE)
#define DONE    ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), i;
	for (i = 0; i < ITERATIONS; i++)
	{
		if (id == 3)
		{
			if (atomic_ldstub((volatile uint8_t*) UNMAPPED) != 0)
				ok &= ~(1u << 0);
			if (atomic_swap((volatile uint32_t*) UNMAPPED, 1) != 0)
				ok &= ~(1u << 0);
		}
		else
		{
			while (atomic_ldstub(&lock) != 0)
				;
			*COUNTER = read_shared(COUNTER) + 1;
			lock = 0;
		}
	}
	if (finish_and_wait_for_all(DONE) && read_shared(COUNTER) == 3 * ITERATIONS) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
