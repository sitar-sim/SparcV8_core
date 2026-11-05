// deep_calls_mmu_on.c
//
// Deep calls spill register windows to the stack, starting with the very first frame
// on it, and with the MMU on. A window overflow writes 64 bytes at %sp and upward, so the
// startup file must leave room above its first stack pointer. Otherwise the spill writes
// past the top of the stack, to an unmapped address, and the core stops with a trap
// inside a trap, which is a hang on the other cores. With the MMU off the same write
// goes unnoticed, so this test turns the MMU on.
//
// Every core checks:
//   0. a call chain deeper than the register windows returns the right value
#include "../../multicore_common.h"
#include "../../../C/mmu/mmu_common.h"

#define DEPTH 40

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

// Scratch-pad word 12, set by core 0 once the tables are ready.
#define TABLES_READY 0xFFFF2C30u

static uint32_t sum_down_to_zero(uint32_t n)
{
	if (n == 0)
		return 0;
	return n + sum_down_to_zero(n - 1);
}

int main(void)
{
	uint32_t ok = 0;

	if (this_core_id() == 0)
	{
		setup_safe_l1_table(l1_table, 0);
		context_table[0] = make_ptd(l1_table);
		__ajit_store_word_mmu_bypass__(1, TABLES_READY);
	}
	else
		while (__ajit_load_word_mmu_bypass__(TABLES_READY) != 1)
			;
	store_word_mmureg(make_ptd(context_table), MMU_REG_CTX_TBL_PTR);
	store_word_mmureg(MMU_CONTROL_E_BIT, MMU_REG_CONTROL);

	if (sum_down_to_zero(DEPTH) == DEPTH * (DEPTH + 1) / 2) ok |= 1 << 0;

	report_and_halt(ok, 1);
	return 0;
}
