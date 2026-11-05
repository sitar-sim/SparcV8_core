// from_every_core.c
//
// Every core moves a page of its own at the same time, so shootdowns overlap. Only one runs
// at a time, and a core waiting for its turn must still take the one under way, or the two
// would wait for each other for ever.
//
// Every core checks:
//   0. in every round, it reads the right value through every core's page
//   1. every core answered each of its shootdowns
#include "../tlb_shootdown_common.h"

#define ROUNDS 6

static unsigned int pages[2][NUM_CORES][1024] __attribute__((aligned(4096)));

static inline uint32_t value_of(uint32_t core, uint32_t round)
{
	return (core << 8) | round;
}

int main(void)
{
	uint32_t ok = 3, id = this_core_id(), round, c;

	if (id == 0)
	{
		build_context(0);
		for (c = 0; c < NUM_CORES; c++)
			map_page(0, VA(c), pages[0][c]);
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	tlb_shootdown_start_on_this_core();
	sync_cores();

	for (round = 0; round < ROUNDS; round++)
	{
		void* next = pages[(round + 1) & 1][id];
		__ajit_store_word_mmu_bypass__(value_of(id, round), (uint32_t) next);
		write_pte(0, VA(id), next, ACC_RWX_RWX);
		if (tlb_shootdown_page(VA(id), 0, NUM_CORES) != 0)
			ok &= ~(1u << 1);
		sync_cores();
		for (c = 0; c < NUM_CORES; c++)
			if (*(volatile uint32_t*) VA(c) != value_of(c, round))
				ok &= ~(1u << 0);
		sync_cores();
	}
	report_and_halt(ok, 2);
	return 0;
}
