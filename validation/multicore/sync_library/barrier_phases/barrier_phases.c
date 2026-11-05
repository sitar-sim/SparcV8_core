// barrier_phases.c
//
// The cores go through PHASES phases, meeting at one reused barrier after each.
// In a phase each core does a different amount of work, so they arrive at
// different times, and then records the phase in a word of its own. Right after
// the barrier, every core reads all four words. They must all show this phase,
// or some core got through before another had arrived.
//
// Every core checks:
//   0. after every barrier, every core had reached this phase
//   1. every core ended on the last phase
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define PHASES 25

static barrier_t barrier;

#define REACHED ((volatile uint32_t*) SHARED_BASE)

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), phase, c;
	for (phase = 1; phase <= PHASES; phase++)
	{
		volatile uint32_t work;
		for (work = 0; work < (id + 1) * 5; work++)
			;
		REACHED[id] = phase;
		barrier_wait(&barrier, NUM_CORES);
		for (c = 0; c < NUM_CORES; c++)
			if (read_shared(&REACHED[c]) != phase)
				ok &= ~(1u << 0);
	}
	barrier_wait(&barrier, NUM_CORES);
	if (read_shared(&REACHED[0]) == PHASES && read_shared(&REACHED[NUM_CORES - 1]) == PHASES)
		ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
