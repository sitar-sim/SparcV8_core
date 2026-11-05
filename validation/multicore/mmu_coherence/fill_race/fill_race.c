// fill_race.c
//
// coherence/fill_race with the MMU on, where the writer and each reader use different
// virtual addresses, and a fill may include a page table walk. Core 0 keeps writing an
// increasing number and publishing it through a word read without the cache. The others
// keep forcing fills of that line, by reading an address in the same cache set, and a plain
// load must then return at least the published number.
//
// Every core checks:
//   0. (readers) a plain load never returned less than the published number
//   1. every core finished, and a plain load then sees the last number written
#include "../mmu_coherence_common.h"

#define READS 200

static volatile uint32_t sequence;
static volatile uint32_t readers_done[NUM_CORES];
static volatile uint32_t all_done[NUM_CORES];

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), i;
	volatile uint32_t* value    = (volatile uint32_t*) VA(id);
	volatile uint32_t* conflict = (volatile uint32_t*) (VA(id) + 0x8000);

	if (id == 0)
	{
		uint32_t c;
		build_context(0);
		for (c = 0; c < NUM_CORES; c++)
		{
			map_page(0, VA(c), frame);
			map_page(0, VA(c) + 0x8000, other_frames[c]);
		}
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	sync_cores();

	if (id == 0)
	{
		uint32_t c, count = 0, more = 1;
		while (more)
		{
			count++;
			*value = count;
			sequence = count;
			more = 0;
			for (c = 1; c < NUM_CORES; c++)
				if (read_shared(&readers_done[c]) != 1)
					more = 1;
		}
	}
	else
	{
		for (i = 0; i < READS; i++)
		{
			uint32_t published;
			(void) *conflict;  //evicts the line
			(void) *value;     //a fill, racing with core 0's write
			published = read_shared(&sequence);
			if (*value < published)
				ok &= ~(1u << 0);
		}
		readers_done[id] = 1;
	}
	if (finish_and_wait_for_all(all_done) && *value == read_shared(&sequence)) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
