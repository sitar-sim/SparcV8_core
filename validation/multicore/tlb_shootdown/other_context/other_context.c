// other_context.c
//
// The other cores are running in context 2 when core 0 changes a page of context 1. A
// shootdown names the context, so their translation for context 1 goes, and the one for
// context 2, at the same virtual address, is still right.
//
// Every core checks:
//   0. (others) in context 2, after the shootdown, it still reads context 2's page
//   1. (others) back in context 1, it reads the new page
//   2. (core 0) every core answered the shootdown
#include "../tlb_shootdown_common.h"

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	volatile uint32_t* va = (volatile uint32_t*) VA(0);

	if (id == 0)
	{
		build_context(0);
		build_context(1);
		build_context(2);
		map_page(1, VA(0), frame);
		map_page(2, VA(0), other_frames[0]);
		frame[0] = 0xA;
		other_frames[0][0] = 0xC;
		other_frames[1][0] = 0xB;
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(id == 0 ? 0 : 1);
	tlb_shootdown_start_on_this_core();
	sync_cores();

	if (id != 0)
	{
		(void) *va;              //in the TLB, for context 1
		set_context(2);
		(void) *va;              //and for context 2
	}
	sync_cores();

	if (id == 0)
	{
		write_pte(1, VA(0), other_frames[1], ACC_RWX_RWX);
		ok = 3;
		if (tlb_shootdown_page(VA(0), 1, NUM_CORES) == 0)
			ok |= 1 << 2;
	}
	sync_cores();

	if (id != 0)
	{
		ok = 1u << 2;
		if (*va == 0xC) ok |= 1 << 0;
		set_context(1);
		if (*va == 0xB) ok |= 1 << 1;
	}
	report_and_halt(ok, 3);
	return 0;
}
