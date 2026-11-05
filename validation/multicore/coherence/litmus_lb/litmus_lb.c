// litmus_lb.c
//
// Load buffering. Each of two cores reads one word and then writes the other. A read
// cannot see a write that comes after it in both programs. Forbidden: both reads return 1.
//
// Every core checks:
//   0. the forbidden outcome never happened
//   1. after every round, a plain load sees the writes (a stale cache forbids nothing
//      above, since it only ever shows old values, so this is checked separately)
#include "../coherence_common.h"

static barrier_t lb_barrier;

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
			results[0] = *X;
			*Y = 1;
		}
		else if (id == 1)
		{
			results[1] = *Y;
			*X = 1;
		}
		litmus_end();
		if (!(*X == 1 && *Y == 1))
			ok &= ~(1u << 1);
		barrier_wait(&litmus_barrier, NUM_CORES);  //the next round clears X and Y
		if (read_shared(&results[0]) == 1 && read_shared(&results[1]) == 1)
			ok &= ~(1u << 0);
		barrier_wait(&lb_barrier, NUM_CORES);
	}
	report_and_halt(ok, 2);
	return 0;
}
