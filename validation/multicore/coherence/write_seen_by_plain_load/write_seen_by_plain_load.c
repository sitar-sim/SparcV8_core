// write_seen_by_plain_load.c
//
// The basic promise of coherence. Cores 1 to 3 read a word, so that it is in their
// caches. Core 0 then writes it. A plain load on each of the others must see the new
// value, with no flush and no uncached load.
//
// The same program with coherence off is stale_without_coherence, which shows the
// old value being read.
//
// Every core checks:
//   0. it read the old value first (core 0 has nothing to read)
//   1. after the write, a plain load sees the new value
#include "../coherence_common.h"

#define VALUE SHARED_WORD(0)

static barrier_t barrier;

int main(void)
{
	uint32_t ok = 0;
	turn_caching_on();

	if (*VALUE == 0) ok |= 1 << 0;
	barrier_wait(&barrier, NUM_CORES);  //every core has it cached

	if (this_core_id() == 0)
		*VALUE = 0x1234;
	barrier_wait(&barrier, NUM_CORES);  //the write is done

	if (*VALUE == 0x1234) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
