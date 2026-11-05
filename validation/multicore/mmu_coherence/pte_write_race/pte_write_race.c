// pte_write_race.c
//
// A page walk that finds a page's R bit clear writes the page table entry back with R set.
// Software may rewrite that entry at any moment, so the walk's read and its write back must
// be atomic. If not, an entry core 0 has just written can be overwritten by the older one
// another core read a moment before, and the remap is lost for good.
//
// Core 0 keeps rewriting one entry, with R clear and a different page each time. The other
// cores keep walking to it, each walk first emptying the TLB entry. After each write,
// core 0 gives any walk under way time to end, and checks that the entry still names the
// page it wrote.
//
// Every core checks:
//   0. (core 0) no write was lost
//      (others) they walked at least once
#include "../mmu_coherence_common.h"

#define ROUNDS 3000
#define SETTLE 40

volatile uint32_t done;

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	volatile uint32_t* va = (volatile uint32_t*) VA(0);
	uint32_t pte_address = (uint32_t) &l3_tables[0][(VA(0) >> 12) & 0x3F];

	if (id == 0)
	{
		build_context(0);
		map_page(0, VA(0), frame);
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	sync_cores();

	if (id == 0)
	{
		uint32_t round, lost = 0;
		for (round = 0; round < ROUNDS; round++)
		{
			volatile uint32_t settle;
			uint32_t pte = make_pte((unsigned int) ((round & 1) ? frame : other_frames[0]), ACC_RWX_RWX, 1);
			__ajit_store_word_mmu_bypass__(pte, pte_address);
			for (settle = 0; settle < SETTLE; settle++)
				;
			if ((__ajit_load_word_mmu_bypass__(pte_address) >> 8) != (pte >> 8))
				lost++;
		}
		__ajit_store_word_mmu_bypass__(1, (uint32_t) &done);
		if (lost == 0) ok |= 1 << 0;
	}
	else
	{
		uint32_t walks = 0;
		while (read_shared(&done) == 0)
		{
			mmu_flush(flush_probe_addr(VA(0), FLUSH_PROBE_TYPE_PAGE));
			(void) *va;
			walks++;
		}
		if (walks > 0) ok |= 1 << 0;
	}
	report_and_halt(ok, 1);
	return 0;
}
