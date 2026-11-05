// line_in_another_context.c
//
// Each reader holds a line in context 1, then switches to context 2, where the same
// address means a different page. While it is away, core 0 writes the line. An invalidate
// goes by physical address, whatever context the reader is running in, so when the reader
// switches back its old copy must be gone.
//
// This runs with a 2-way data cache. In a direct-mapped one, the read in context 2 would
// evict the line from context 1, and it would be gone whatever an invalidate did. The word
// is in the middle of the page, since the barrier at the start of a page could evict it too.
//
// Every core checks:
//   0. (readers) in context 2, it reads the other page
//   1. back in context 1, a plain load sees core 0's write
#include "../mmu_coherence_common.h"

#define WORD_IN_PAGE 0x800u

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	volatile uint32_t* va = (volatile uint32_t*) (VA(0) + WORD_IN_PAGE);

	if (id == 0)
	{
		build_context(0);
		build_context(1);
		build_context(2);
		map_page(0, VA(1), frame);
		map_page(1, VA(0), frame);
		map_page(2, VA(0), other_frames[0]);
		other_frames[0][WORD_IN_PAGE / 4] = 0x77;
		frame[WORD_IN_PAGE / 4] = 0x11;
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(id == 0 ? 0 : 1);
	sync_cores();

	if (id == 0)
	{
		ok |= 1 << 0;
		sync_cores();
		*(volatile uint32_t*) (VA(1) + WORD_IN_PAGE) = 0x22;
		sync_cores();
		if (*(volatile uint32_t*) (VA(1) + WORD_IN_PAGE) == 0x22) ok |= 1 << 1;
	}
	else
	{
		(void) *va;        //cached in context 1
		set_context(2);
		if (*va == 0x77) ok |= 1 << 0;
		sync_cores();
		sync_cores();      //core 0 has written
		set_context(1);
		if (*va == 0x22) ok |= 1 << 1;
	}
	report_and_halt(ok, 2);
	return 0;
}
