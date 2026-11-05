// litmus_sb.c
//
// Store buffering. Each of two cores writes one word and then reads the other. SPARC's
// TSO allows both to read 0, because a store can wait in a store buffer, but this model
// has no store buffer, so here it never happens. If a store buffer is ever added, this
// test's check must go. Forbidden in this model: both reads return 0.
//
// Every core checks:
//   0. the forbidden outcome never happened
//   1. after every round, a plain load sees the writes (a stale cache forbids nothing
//      above, since it only ever shows old values, so this is checked separately)
#include "../coherence_common.h"

static barrier_t sb_barrier;

int main(void)
{
	uint32_t ok = (1 << 0) | (1 << 1), id = this_core_id(), round;
	volatile uint32_t* results = (volatile uint32_t*) SHARED_WORD(2);
	turn_caching_on();

	for (round = 0; round < LITMUS_ROUNDS; round++)
	{
		litmus_start(round);
		if (id == 0)
		{
			*X = 1;
			results[0] = *Y;
		}
		else if (id == 1)
		{
			*Y = 1;
			results[1] = *X;
		}
		litmus_end();
		if (!(*X == 1 && *Y == 1))
			ok &= ~(1u << 1);
		barrier_wait(&litmus_barrier, NUM_CORES);  //the next round clears X and Y
		if (read_shared(&results[0]) == 0 && read_shared(&results[1]) == 0)
			ok &= ~(1u << 0);
		barrier_wait(&sb_barrier, NUM_CORES);
	}
	report_and_halt(ok, 2);
	return 0;
}
