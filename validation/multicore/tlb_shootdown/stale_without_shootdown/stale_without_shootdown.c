// stale_without_shootdown.c
//
// Why a shootdown is needed. A core keeps using its TLB's copy of a page table entry after
// another core has changed the entry in memory. Emptying the caches does not help. Only
// dropping the TLB entry does.
//
// Every core checks:
//   0. it reads the first page
//   1. after core 0 points the entry at another page, and after emptying its caches, it
//      still reads the first page
//   2. after dropping its own TLB entry, it reads the second page
#include "../tlb_shootdown_common.h"

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	volatile uint32_t* va = (volatile uint32_t*) VA(0);

	if (id == 0)
	{
		build_context(0);
		map_page(0, VA(0), frame);
		frame[0] = 0xA;
		other_frames[0][0] = 0xB;
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	sync_cores();

	if (*va == 0xA) ok |= 1 << 0;
	sync_cores();

	if (id == 0)
		write_pte(0, VA(0), other_frames[0], ACC_RWX_RWX);
	sync_cores();

	flush_caches();
	if (*va == 0xA) ok |= 1 << 1;
	sync_cores();

	tlb_flush_page(VA(0), 0);
	if (*va == 0xB) ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}
