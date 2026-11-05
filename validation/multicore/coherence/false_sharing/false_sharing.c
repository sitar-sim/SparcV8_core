// false_sharing.c
//
// Each core writes only its own word, but all four words are in one cache line. Each
// write therefore removes the line from the other cores, though none of them cares
// about this word. That costs misses but must never change a value: every core keeps
// reading back exactly what it wrote. Running this with --stats shows the cost,
// in each core's "invalidates hit" and "read misses" counters.
//
// Every core checks:
//   0. every read of its own word returned what it last wrote
//   1. every core finished, and each core's final value is in its word
#include "../coherence_common.h"

#define ROUNDS 100

#define WORDS ((volatile uint32_t*) SHARED_WORD(0))
#define DONE  ((volatile uint32_t*) SHARED_WORD(1))

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), i;
	turn_caching_on();

	for (i = 1; i <= ROUNDS; i++)
	{
		WORDS[id] = i;
		if (WORDS[id] != i)
			ok &= ~(1u << 0);
	}
	if (finish_and_wait_for_all(DONE))
	{
		uint32_t c, all_there = 1;
		for (c = 0; c < NUM_CORES; c++)
			if (WORDS[c] != ROUNDS)
				all_there = 0;
		if (all_there) ok |= 1 << 1;
	}
	report_and_halt(ok, 2);
	return 0;
}
