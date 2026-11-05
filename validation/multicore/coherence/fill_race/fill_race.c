// fill_race.c
//
// The hard case in the sitar_model. A line fill is 8 separate bus reads. If another
// core writes the line while a fill is on its way, the fill may already have read the
// old value, and the invalidate finds nothing to remove, since the line is not
// installed yet. Installing it then would leave a stale line that no later invalidate
// will ever remove.
//
// Core 0 keeps writing an increasing number to a word, then publishes that number
// through a sequence word that is read without the cache. It carries on until the
// others have finished, so that it is always writing during their fills. The others
// keep forcing fills of the line, by reading another address that maps to the same
// cache line and so evicts it, and then reading the word. Each then reads the sequence
// word, and a plain load after that must return at least that number. A stale line
// would return an older one. The word is the first in its line, which is read first,
// so it is the most exposed to a write during the fill.
//
// The eviction relies on the default data cache, 32 KB and direct mapped. It is not
// done with a flush, since that also empties the instruction cache, and slows the readers
// so much that few of their fills overlap a write.
//
// The cpp_model cannot have this race, since a fill never overlaps a write there.
//
// Every core checks:
//   0. (readers) a plain load never returned less than the published number
//   1. every core finished, and a plain load then sees the last number written
#include "../coherence_common.h"

#define READS 200

#define VALUE    SHARED_WORD(0)
#define SEQUENCE SHARED_WORD(1)
#define CONFLICT ((volatile uint32_t*) (SHARED_BASE + 0x8000))
#define READERS_DONE ((volatile uint32_t*) SHARED_WORD(2))
#define ALL_DONE     ((volatile uint32_t*) SHARED_WORD(3))

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), i;
	turn_caching_on();

	if (id == 0)
	{
		uint32_t c, value = 0, more = 1;
		while (more)
		{
			value++;
			*VALUE = value;
			*SEQUENCE = value;
			more = 0;
			for (c = 1; c < NUM_CORES; c++)
				if (read_shared(&READERS_DONE[c]) != 1)
					more = 1;
		}
	}
	else
	{
		for (i = 0; i < READS; i++)
		{
			uint32_t published;
			(void) *CONFLICT;                //evicts VALUE's line
			(void) *VALUE;                   //a fill, racing with core 0's write
			published = read_shared(SEQUENCE);
			if (*VALUE < published)          //a hit, if the fill installed its line
				ok &= ~(1u << 0);
		}
		READERS_DONE[id] = 1;
	}
	if (finish_and_wait_for_all(ALL_DONE) && *VALUE == read_shared(SEQUENCE)) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
