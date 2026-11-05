// same_va_diff_pa.c
//
// The opposite case: each core has its own context, and the same virtual address maps to a
// different physical page for each. These are not synonyms, so a write by one core must
// not disturb another core's line, whatever the virtual address. An invalidate that
// cleared the whole set, not just the matching line, would remove it.
//
// To tell whether a line is still cached, each core changes its own page behind its
// cache, with a bypass store, which leaves its own copy alone. A plain load then returns
// the old value only if the line is still there.
//
// The word is in the middle of the page. The barrier is at the start of a page, and in a
// small enough cache it would evict a line there, whatever an invalidate did.
//
// Every core checks:
//   0. it reads the value it wrote to its own page
//   1. after core 0's write to the same virtual address, its line is still cached
//      (core 0 sees its own new value)
//   2. after a flush, it reads what the bypass store wrote
#include "../mmu_coherence_common.h"

#define WORD_IN_PAGE 0x800u

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	volatile uint32_t* mine = (volatile uint32_t*) (VA(0) + WORD_IN_PAGE);

	if (id == 0)
	{
		uint32_t c;
		for (c = 0; c < NUM_CORES; c++)
		{
			build_context(c);
			map_page(c, VA(0), other_frames[c]);
		}
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(id);
	sync_cores();

	*mine = 0x100 + id;
	if (*mine == 0x100 + id) ok |= 1 << 0;
	sync_cores();

	if (id == 0)
		*mine = 0x200;
	sync_cores();

	__ajit_store_word_mmu_bypass__(0x300 + id, (uint32_t) other_frames[id] + WORD_IN_PAGE);
	if (*mine == (id == 0 ? 0x200u : 0x100u + id)) ok |= 1 << 1;

	flush_caches();
	if (*mine == 0x300 + id) ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}
