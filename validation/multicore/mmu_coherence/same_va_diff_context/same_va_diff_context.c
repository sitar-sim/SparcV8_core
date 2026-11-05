// same_va_diff_context.c
//
// Each core runs in a context of its own, and all of them map the same virtual address to
// the same physical page. A line's tag includes its context, so the tags all differ. The
// invalidate must still find the line, by its physical address.
//
// Every core checks each kind of write (Ref check_every_kind_of_write()).
#include "../mmu_coherence_common.h"

int main(void)
{
	uint32_t id = this_core_id();

	if (id == 0)
	{
		uint32_t c;
		for (c = 0; c < NUM_CORES; c++)
		{
			build_context(c);
			map_page(c, VA(0), frame);
		}
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(id);
	sync_cores();

	report_and_halt(check_every_kind_of_write((volatile uint32_t*) VA(0), (volatile uint32_t*) VA(0)), 5);
	return 0;
}
