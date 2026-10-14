// write_through_visible.c
//
// The data cache is write-through: a store to a cached line also reaches
// memory at once, so a physical (bypass) load sees it.
//   0. values written through the cache read back through the cache
//   1. the same values are already in memory (bypass loads)
//   2. a partial (byte) store merges correctly in both

#include "../caches_common.h"

volatile uint32_t buffer[16];

int main(void)
{
	uint32_t ok = 0, good_cached = 1, good_memory = 1;
	int i;

	set_always_cacheable();

	for (i = 0; i < 16; i++)
		buffer[i] = 0x1000 + i;
	for (i = 0; i < 16; i++)
	{
		if (buffer[i] != 0x1000u + i) good_cached = 0;
		if (__ajit_load_word_mmu_bypass__((uint32_t) &buffer[i]) != 0x1000u + i) good_memory = 0;
	}
	if (good_cached) ok |= 1 << 0;
	if (good_memory) ok |= 1 << 1;

	*((volatile uint8_t*) &buffer[3]) = 0xAB; //most significant byte of buffer[3]
	if (buffer[3] == 0xAB001003u && __ajit_load_word_mmu_bypass__((uint32_t) &buffer[3]) == 0xAB001003u)
		ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}
