// core_that_does_not_answer.c
//
// A core that never takes the IPI cannot answer. The shootdown must not wait for ever, and must
// report it. Core 3 holds its interrupts off until the shootdown has returned.
//
// Every core checks:
//   0. (core 0) the shootdown returned, reporting one core that did not answer
//   1. every core got to the end, core 3 once it has let the IPI in
#define SHOOTDOWN_WAIT_LIMIT 3000u
#include "../tlb_shootdown_common.h"

#define SILENT_CORE (NUM_CORES - 1)

volatile uint32_t shootdown_returned;

int main(void)
{
	uint32_t ok = 3, id = this_core_id();

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
			__ajit_store_word_mmu_bypass__(1, (uint32_t) &shootdown_returned);
		}
	}
	sync_cores();
	report_and_halt(ok, 2);
	return 0;
}
