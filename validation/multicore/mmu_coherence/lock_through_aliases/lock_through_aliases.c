// lock_through_aliases.c
//
// All of it together. Every core adds to one counter under one lock, reaching both through
// a virtual address and context of its own, with plain loads. LDSTUB, its invalidates, the
// bus lock and every core's own synonym handling all have to agree on one physical line.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and the total is NUM_CORES * ITERATIONS
#include "../mmu_coherence_common.h"

#define ITERATIONS 50

static volatile uint32_t done[NUM_CORES];

int main(void)
{
	uint32_t ok = 0, id = this_core_id(), mine = 0, i;
	volatile uint8_t*  lock    = (volatile uint8_t*)  VA(id);
	volatile uint32_t* counter = (volatile uint32_t*) (VA(id) + 0x40);

	if (id == 0)
	{
		uint32_t c;
		for (c = 0; c < NUM_CORES; c++)
		{
			build_context(c);
			map_page(c, VA(c), frame);
		}
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(id);
	sync_cores();

	for (i = 0; i < ITERATIONS; i++)
	{
		while (atomic_ldstub(lock) != 0)
			while (*lock != 0)
				;
		*counter = *counter + 1;
		mine++;
		*lock = 0;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(done) && *counter == NUM_CORES * ITERATIONS) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
