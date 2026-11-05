// pte_update_through_stale_tlb.c
//
// A first store to a page sets the M bit of its page table entry. A core whose TLB still
// holds an old copy of the entry must set that bit in the entry now in memory, and not
// write the old copy back over it. This is the window a TLB shootdown has to close, after
// core 0 has changed an entry and before every core has dropped its old copy.
//
//   Core 1 reads the page, so its TLB holds the entry, with R set and M clear.
//   Core 0 points the entry at another page.
//   Core 1 stores to the page, through its old copy.
//
// Every core checks:
//   0. the entry in memory still names the page core 0 chose
//   1. and has its M bit set
#include "../mmu_coherence_common.h"

#define PTE_M_BIT 0x40u

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	volatile uint32_t* va = (volatile uint32_t*) VA(0);
	uint32_t pte_address = (uint32_t) &l3_tables[0][(VA(0) >> 12) & 0x3F];
	uint32_t new_pte = make_pte((unsigned int) other_frames[0], ACC_RWX_RWX, 1), pte;

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

	if (id == 1)
		(void) *va;
	sync_cores();

	if (id == 0)
		__ajit_store_word_mmu_bypass__(new_pte, pte_address);
	sync_cores();

	if (id == 1)
		*va = 0x55;
	sync_cores();

	pte = __ajit_load_word_mmu_bypass__(pte_address);
	if ((pte >> 8) == (new_pte >> 8)) ok |= 1 << 0;
	if (pte & PTE_M_BIT) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
