// code_through_another_address.c
//
// Invalidates reach the instruction caches when each core runs the code at its own
// virtual address. Core 0 changes a function through a data address. The others must run
// the new code with no flush. As on one core, the writer's own instruction cache gets no
// invalidate, so core 0 executes FLUSH.
//
// Every core checks:
//   0. the first version returns 1
//   1. the second version returns 2
#include "../mmu_coherence_common.h"

#define RETL      0x81C3E008u
#define MOV_TO_O0 0x90102000u

typedef uint32_t (*function_t)(void);

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	function_t function = (function_t) VA(id);

	if (id == 0)
	{
		uint32_t c;
		build_context(0);
		for (c = 0; c < NUM_CORES; c++)
			map_page(0, VA(c), frame);
		map_page(0, VA(NUM_CORES), frame);  //the data address
		frame[0] = RETL;
		frame[1] = MOV_TO_O0 | 1;
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	sync_cores();

	if (function() == 1) ok |= 1 << 0;
	sync_cores();

	if (id == 0)
	{
		volatile uint32_t* code = (volatile uint32_t*) VA(NUM_CORES);
		code[1] = MOV_TO_O0 | 2;
		__asm__ __volatile__("flush %0" : : "r"(function) : "memory");
	}
	sync_cores();

	if (function() == 2) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
