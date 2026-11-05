// scratch_pad_across_cores.c
//
// The scratch-pad is one device, shared by every core, and it is never cached. A write by one
// core is seen by the others at once, with no flush, whatever they have read before.
//
// Every core checks:
//   0. it reads the word every core wrote
//   1. and through the alias 128 bytes on
//   2. byte stores by different cores to one word all take effect
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define SCRATCH_PAD ((volatile uint32_t*) 0xFFFF2C00u)
#define FIRST_WORD  4
#define BYTES_WORD  8

static barrier_t barrier;

int main(void)
{
	uint32_t ok = 7, id = this_core_id(), c;

	(void) SCRATCH_PAD[FIRST_WORD];
	barrier_wait(&barrier, NUM_CORES);

	SCRATCH_PAD[FIRST_WORD + id] = 0x100 + id;
	((volatile uint8_t*) &SCRATCH_PAD[BYTES_WORD])[id] = 0xA0 + id;
	barrier_wait(&barrier, NUM_CORES);

	for (c = 0; c < NUM_CORES; c++)
	{
		if (SCRATCH_PAD[FIRST_WORD + c] != 0x100 + c) ok &= ~(1u << 0);
		if (SCRATCH_PAD[FIRST_WORD + c + 32] != 0x100 + c) ok &= ~(1u << 1);
	}
	if (SCRATCH_PAD[BYTES_WORD] != 0xA0A1A2A3u) ok &= ~(1u << 2);

	report_and_halt(ok, 3);
	return 0;
}
