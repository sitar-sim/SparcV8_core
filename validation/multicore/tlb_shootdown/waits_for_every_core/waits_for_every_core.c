// waits_for_every_core.c
//
// A shootdown must not return before every core has dropped its copy. Here the other cores hold
// their interrupts off for a while after core 0 starts it, and only then let the IPI in. When
// the shootdown returns, each of them must already have done so.
//
// Every core checks:
//   0. (core 0) when the shootdown returned, every other core had finished waiting
//   1. (core 0) every core answered
#include "../tlb_shootdown_common.h"

#define HOLD 3000

volatile uint32_t finished_holding[NUM_CORES];

int main(void)
{
	uint32_t ok = 0, id = this_core_id(), c;

	if (id == 0)
	{
		build_context(0);
		map_page(0, VA(0), frame);
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	tlb_shootdown_start_on_this_core();
	sync_cores();

	if (id == 0)
	{
		uint32_t answered_late = 1;
		sync_cores();
		if (tlb_shootdown_page(VA(0), 0, NUM_CORES) == 0)
			ok |= 1 << 1;
		for (c = 1; c < NUM_CORES; c++)
			if (read_shared(&finished_holding[c]) != 1)
				answered_late = 0;
		if (answered_late) ok |= 1 << 0;
	}
	else
	{
		volatile uint32_t hold;
		uint32_t level = interrupts_off();
		sync_cores();
		for (hold = 0; hold < HOLD; hold++)
			;
		__ajit_store_word_mmu_bypass__(1, (uint32_t) &finished_holding[id]);
		interrupts_restore(level);
		ok = 3;
	}
	sync_cores();
	report_and_halt(ok, 2);
	return 0;
}
