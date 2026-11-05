// litmus_mp.c
//
// Message passing. Core 0 writes the data X, then the flag Y. A core that sees the
// flag must also see the data. Forbidden: Y = 1 and then X = 0.
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
			*Y = 1;
		}
		else
		{
			uint32_t flag = *Y;
			uint32_t data = *X;
			if (flag == 1 && data == 0)
				ok &= ~(1u << 0);
		}
		litmus_end();
		if (!(*X == 1 && *Y == 1))
			ok &= ~(1u << 1);
		barrier_wait(&litmus_barrier, NUM_CORES);  //the next round clears X and Y
	}
	report_and_halt(ok, 2);
	return 0;
}
