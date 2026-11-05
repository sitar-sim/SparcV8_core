// diff_va_across_cores.c
//
// The case the MMU-off coherence tests cannot reach. All cores share one context and one
// physical page, but each core reads it through its own virtual address, in its own
// cache set. Core 0 writes through its address. The invalidate carries only a physical
// address, so each other core must find the line in a set the physical address alone
// does not name.
//
// Every core checks each kind of write (Ref check_every_kind_of_write()).
#include "../mmu_coherence_common.h"

int main(void)
{
	uint32_t id = this_core_id();

	if (id == 0)
	{
		uint32_t c;
		build_context(0);
		for (c = 0; c < NUM_CORES; c++)
			map_page(0, VA(c), frame);
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	sync_cores();

	report_and_halt(check_every_kind_of_write((volatile uint32_t*) VA(0), (volatile uint32_t*) VA(id)), 5);
	return 0;
}
