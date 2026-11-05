// instruction_cache.c
//
// Invalidates reach the instruction caches too. Core 0 writes a small function into
// memory, and every core calls it, so it is in their instruction caches. Core 0 then
// changes the function. Cores 1 to 3 must run the new code with no flush.
//
// A writer's own caches get no invalidate, as in AJIT, so core 0 must still do what
// self-modifying code always has to do on SPARC, and execute FLUSH first.
//
// Every core checks:
//   0. the first version returns 1
//   1. the second version returns 2
#include "../coherence_common.h"

#define CODE ((volatile uint32_t*) (SHARED_BASE + 0x1000))

// The function: retl, with `mov value, %o0` in its delay slot.
#define RETL      0x81C3E008u
#define MOV_TO_O0 0x90102000u

typedef uint32_t (*function_t)(void);

static barrier_t barrier;

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	function_t function = (function_t) CODE;
	turn_caching_on();

	if (id == 0)
	{
		CODE[0] = RETL;
		CODE[1] = MOV_TO_O0 | 1;
	}
	barrier_wait(&barrier, NUM_CORES);
	if (function() == 1) ok |= 1 << 0;
	barrier_wait(&barrier, NUM_CORES);

	if (id == 0)
	{
		CODE[1] = MOV_TO_O0 | 2;
		__asm__ __volatile__("flush %0" : : "r"(CODE) : "memory");
	}
	barrier_wait(&barrier, NUM_CORES);
	if (function() == 2) ok |= 1 << 1;

	report_and_halt(ok, 2);
	return 0;
}
