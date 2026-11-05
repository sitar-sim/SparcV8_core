// litmus_iriw.c
//
// Independent reads of independent writes. Core 0 writes X and core 1 writes Y. Cores 2
// and 3 read them in opposite orders. All cores must agree on one order of the two
// writes. Forbidden: core 2 sees X new and Y old, while core 3 sees Y new and X old.
//
// Every core checks:
//   0. the forbidden outcome never happened
//   1. after every round, a plain load sees the writes (a stale cache forbids nothing
//      above, since it only ever shows old values, so this is checked separately)
#include "../coherence_common.h"

static barrier_t iriw_barrier;

int main(void)
{
	uint32_t ok = (1 << 0) | (1 << 1), id = this_core_id(), round;
	volatile uint32_t* results = (volatile uint32_t*) SHARED_WORD(2);
	turn_caching_on();

	for (round = 0; round < LITMUS_ROUNDS; round++)
	{
		litmus_start(round);
		if (id == 0)
			*X = 1;
		else if (id == 1)
			*Y = 1;
		else if (id == 2)
		{
			uint32_t first = *X, second = *Y;
			results[0] = first;
			results[1] = second;
		}
		else
		{
			uint32_t first = *Y, second = *X;
			results[2] = first;
			results[3] = second;
		}
		litmus_end();
		if (!(*X == 1 && *Y == 1))
			ok &= ~(1u << 1);
		barrier_wait(&litmus_barrier, NUM_CORES);  //the next round clears X and Y
		if (read_shared(&results[0]) == 1 && read_shared(&results[1]) == 0 &&
		    read_shared(&results[2]) == 1 && read_shared(&results[3]) == 0)
			ok &= ~(1u << 0);
		barrier_wait(&iriw_barrier, NUM_CORES);
	}
	report_and_halt(ok, 2);
	return 0;
}
