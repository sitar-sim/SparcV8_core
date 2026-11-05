// separate_page_tables.c
//
// Each core has page tables of its own, down to its own context table, and maps one
// physical page at its own virtual address, in context 0. The cores agree on nothing but
// the physical page, as separate operating systems sharing memory might.
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
			map_page(c, VA(c), frame);
			per_core_context_tables[c][0] = make_ptd(l1_tables[c]);
		}
		release_tables();
	}
	else
		wait_for_tables();

	store_word_mmureg(make_ptd(per_core_context_tables[id]), MMU_REG_CTX_TBL_PTR);
	set_context(0);
	store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);
	sync_cores();

	report_and_halt(check_every_kind_of_write((volatile uint32_t*) VA(0), (volatile uint32_t*) VA(id)), 5);
	return 0;
}
