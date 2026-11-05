// litmus_2plus2w.c
//
// 2+2W. Two cores each write both words, in opposite orders, with different values.
// Writes to one word have one order, and a core's own writes stay in order. Forbidden:
// X = 1 and Y = 1 at the end, which would need each core's first write to come after
// the other core's second write, a cycle.
//
// Every core checks:
//   0. the forbidden outcome never happened
//   1. after every round, a plain load sees the writes (a stale cache forbids nothing
//      above, since it only ever shows old values, so this is checked separately)
#include "../coherence_common.h"

int main(void)
{
	uint32_t ok = (1 << 0) | (1 << 1), id = this_core_id(), round;
	turn_caching_on();

	for (round = 0; round < LITMUS_ROUNDS; round++)
	{
		litmus_start(round);
		if (id == 0)
		{
			*X = 1;
			*Y = 2;
		}
		else if (id == 1)
		{
			*Y = 1;
			*X = 2;
		}
		litmus_end();
		if (!(*X != 0 && *Y != 0))
			ok &= ~(1u << 1);
		barrier_wait(&litmus_barrier, NUM_CORES);  //the next round clears X and Y
		if (*X == 1 && *Y == 1)
			ok &= ~(1u << 0);
	}
	report_and_halt(ok, 2);
	return 0;
}
