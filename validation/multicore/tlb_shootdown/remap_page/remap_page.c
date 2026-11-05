// remap_page.c
//
// Core 0 keeps moving a page between two physical pages, with a shootdown each time. Each
// page holds a new value, written behind the caches, so a core that uses an old translation
// or an old cached line reads the wrong value.
//
// Every core checks:
//   0. in every round, it reads the value of the page chosen for that round
//   1. (core 0) every core answered every shootdown
#include "../tlb_shootdown_common.h"

#define ROUNDS 8

int main(void)
{
	uint32_t ok = 3, id = this_core_id(), round;
	volatile uint32_t* va = (volatile uint32_t*) VA(0);

	if (id == 0)
	{
		build_context(0);
		map_page(0, VA(0), frame);
		frame[0] = 0x100;
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	tlb_shootdown_start_on_this_core();
	sync_cores();

	for (round = 0; round < ROUNDS; round++)
	{
		if (*va != 0x100 + round)
			ok &= ~(1u << 0);
		sync_cores();
		if (id == 0)
		{
			void* next = (round & 1) ? (void*) frame : (void*) other_frames[0];
			__ajit_store_word_mmu_bypass__(0x100 + round + 1, (uint32_t) next);
			write_pte(0, VA(0), next, ACC_RWX_RWX);
			if (tlb_shootdown_page(VA(0), 0, NUM_CORES) != 0)
				ok &= ~(1u << 1);
		}
		sync_cores();
	}
	report_and_halt(ok, 2);
	return 0;
}
