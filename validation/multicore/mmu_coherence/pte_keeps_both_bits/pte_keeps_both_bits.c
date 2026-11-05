// pte_keeps_both_bits.c
//
// Two cores walk to one page table entry at once, core 1 to store and core 2 to load. Each
// finds the entry with R and M clear. If each writes back what it read, with its own bits
// set, the load can clear the M bit the store has just set, and software would think the
// page clean. The bits must accumulate.
//
// Each round, core 0 clears the entry and the others empty their TLBs. Then core 1 and
// core 2 walk, each after a delay that changes each round, so that the walks overlap in
// every way. The barrier releases the cores some way apart, so the delays cover a wide range.
//
// Every core checks:
//   0. in every round, the entry ends with both R and M set
#include "../mmu_coherence_common.h"

#define ROUNDS 2500
#define DELAYS 50
#define PTE_R_BIT 0x20u
#define PTE_M_BIT 0x40u

int main(void)
{
	uint32_t ok = 0, id = this_core_id(), round, wrong = 0;
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

	for (round = 0; round < ROUNDS; round++)
	{
		volatile uint32_t wait;
		if (id == 0)
			__ajit_store_word_mmu_bypass__(make_pte((unsigned int) frame, ACC_RWX_RWX, 1), pte_address);
		else
			mmu_flush(flush_probe_addr(VA(0), FLUSH_PROBE_TYPE_PAGE));
		sync_cores();
		if (id == 1)
		{
			for (wait = 0; wait < round % DELAYS; wait++)
				;
			*va = round;
		}
		else if (id == 2)
		{
			for (wait = 0; wait < round / DELAYS; wait++)
				;
			(void) *va;
		}
		sync_cores();
		if ((__ajit_load_word_mmu_bypass__(pte_address) & (PTE_R_BIT | PTE_M_BIT)) != (PTE_R_BIT | PTE_M_BIT))
			wrong++;
		sync_cores();
	}
	if (wrong == 0) ok |= 1 << 0;
	report_and_halt(ok, 1);
	return 0;
}
