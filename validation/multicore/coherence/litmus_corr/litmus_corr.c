// litmus_corr.c
//
// Coherence of read-read. Core 0 writes X twice. A core reading X twice must never see
// the writes go backwards. Forbidden: the first read returns 2 and the second returns 1.
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
			*X = 2;
		}
		else
		{
			uint32_t first = *X;
			uint32_t second = *X;
			if (second < first)
				ok &= ~(1u << 0);
		}
		litmus_end();
		if (!(*X == 2))
			ok &= ~(1u << 1);
		barrier_wait(&litmus_barrier, NUM_CORES);  //the next round clears X and Y
	}
	report_and_halt(ok, 2);
	return 0;
}
