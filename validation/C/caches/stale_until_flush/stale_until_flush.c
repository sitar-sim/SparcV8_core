// stale_until_flush.c
//
// The L1 caches are not coherent with memory changed behind their back.
// A physical (bypass) store goes to memory without touching the data
// cache, so a cached copy of that line stays stale until software flushes
// the cache. Bare-metal code (and DMA, later) must allow for this.
//   0. the value is cached after the first read
//   1. after a bypass store, memory holds the new value
//   2. the cached read still returns the old value (stale)
//   3. after flushing, the read returns the new value

#include "../caches_common.h"

volatile uint32_t word_under_test = 0x11111111;

int main(void)
{
	uint32_t ok = 0;
	uint32_t address = (uint32_t) &word_under_test;

	set_always_cacheable();

	if (word_under_test == 0x11111111u) ok |= 1 << 0; //miss: the line is installed

	__ajit_store_word_mmu_bypass__(0x22222222u, address);
	if (__ajit_load_word_mmu_bypass__(address) == 0x22222222u) ok |= 1 << 1;
	if (word_under_test == 0x11111111u) ok |= 1 << 2; //hit: the stale copy

	flush_both_caches();
	if (word_under_test == 0x22222222u) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}
