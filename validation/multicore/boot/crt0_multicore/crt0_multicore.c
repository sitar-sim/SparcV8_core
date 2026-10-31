// crt0_multicore.c
//
// What compiler/crt0_multicore.s promises every core, by the time main()
// runs:
//   0: ASR29 holds the AJIT tag and this core's ID, thread 0;
//   1: this core's stack is its own 1 MB region (a local variable's
//      address lies inside it);
//   2: .bss has been cleared (by core 0, before releasing the others);
//   3: the boot release flag (scratch-pad word 0) is set.
// Each core also records its arrival in a shared array (m[] checks in
// the .vprj).

#include "../../multicore_common.h"

static volatile uint32_t zero_initialized[16]; // in .bss

int main(void)
{
	uint32_t ok = 0;
	uint32_t id = this_core_id();
	volatile uint32_t local = 0;

	uint32_t word = __ajit_read_core_thread_id_word__();
	if (word == (0x50520000u | (id << 8))) ok |= 1 << 0;

	uint32_t sp_top    = STACK_TOP - id * STACK_BYTES_PER_CORE;
	uint32_t sp_bottom = sp_top - STACK_BYTES_PER_CORE;
	uint32_t where     = (uint32_t) &local;
	if (where < sp_top && where > sp_bottom) ok |= 1 << 1;

	uint32_t i, sum = 0;
	for (i = 0; i < 16; i++)
		sum |= zero_initialized[i];
	if (sum == 0) ok |= 1 << 2;

	if (__ajit_load_word_mmu_bypass__(BOOT_RELEASE_FLAG) == 1) ok |= 1 << 3;

	volatile uint32_t* arrived = (volatile uint32_t*) SHARED_BASE;
	arrived[id] = 0xA0 + id;

	report_and_halt(ok, 4);
	return 0;
}
