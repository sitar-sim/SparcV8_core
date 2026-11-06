// core_that_does_not_answer.c
//
// A core that never takes the IPI cannot answer. The shootdown must not wait for ever, and must
// report it. Core 3 holds its interrupts off until both shootdowns have returned.
//
// Every core checks:
//   0. (core 0) the shootdown returned, reporting one core that did not answer
//   1. every core got to the end, core 3 once it has let the IPI in
//   2. (core 0) a second shootdown also returned and reported it, though core 3 still holds the
//      first IPI, so that the second cannot even be sent to it
#define SHOOTDOWN_WAIT_LIMIT 3000u
#include "../tlb_shootdown_common.h"

#define SILENT_CORE (NUM_CORES - 1)

volatile uint32_t shootdown_returned;

int main(void)
{
	uint32_t ok = 7, id = this_core_id();

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

	if (id == SILENT_CORE)
	{
		uint32_t level = interrupts_off();
		sync_cores();
		while (read_shared(&shootdown_returned) != 1)
			;
		interrupts_restore(level);
	}
	else
	{
		sync_cores();
		if (id == 0)
		{
			if (tlb_shootdown_page(VA(0), 0, NUM_CORES) != 1)
				ok &= ~(1u << 0);
			if (tlb_shootdown_page(VA(0), 0, NUM_CORES) != 1)
				ok &= ~(1u << 2);
			__ajit_store_word_mmu_bypass__(1, (uint32_t) &shootdown_returned);
		}
	}
	sync_cores();
	report_and_halt(ok, 3);
	return 0;
}
