// revoke_write.c
//
// Core 0 takes away write permission from a page every core has been writing, with a
// shootdown. A TLB entry holds the permissions, so without the shootdown a later store would
// still get through. The NF bit is set, so the fault can be read from the fault status
// register without a trap.
//
// Every core checks:
//   0. its store faults with a protection error
//   1. the store did not reach memory
//   2. (core 0) every core answered the shootdown
#include "../tlb_shootdown_common.h"

int main(void)
{
	uint32_t ok = 1u << 2, id = this_core_id(), fsr;
	volatile uint32_t* va = (volatile uint32_t*) VA(0);

	if (id == 0)
	{
		build_context(0);
		map_page(0, VA(0), frame);
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	store_word_mmureg(MMU_CONTROL_E_BIT | MMU_CONTROL_NF_BIT, MMU_REG_CONTROL);
	tlb_shootdown_start_on_this_core();
	sync_cores();

	*va = 0x10 + id;        //its TLB now allows this
	sync_cores();

	if (id == 0)
	{
		write_pte(0, VA(0), frame, ACC_RO_RO);
		if (tlb_shootdown_page(VA(0), 0, NUM_CORES) != 0)
			ok &= ~(1u << 2);
	}
	sync_cores();

	(void) load_word_mmureg(MMU_REG_FAULT_STATUS);
	*va = 0x77;
	fsr = load_word_mmureg(MMU_REG_FAULT_STATUS);
	if (FSR_FT(fsr) == FT_PROTECTION_ERROR) ok |= 1 << 0;
	sync_cores();

	if (read_shared((volatile uint32_t*) frame) != 0x77) ok |= 1 << 1;
	report_and_halt(ok, 3);
	return 0;
}
