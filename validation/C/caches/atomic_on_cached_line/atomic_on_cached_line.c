// atomic_on_cached_line.c
//
// An atomic load-store (LDSTUB) on a line that is in the data cache: the
// atomic itself bypasses the cache (its locked read goes to memory), and
// the byte it stores updates the cached copy too.
//   0. LDSTUB returns the old byte
//   1. a cached read afterwards sees 0xFF
//   2. memory holds 0xFF too

#include "../caches_common.h"

volatile uint8_t lock_byte = 0x05;

int main(void)
{
	uint32_t ok = 0;
	uint32_t old;

	set_always_cacheable();
	(void) lock_byte; //bring the line into the cache

	__asm__ __volatile__("ldstub [%1], %0" : "=r"(old) : "r"(&lock_byte) : "memory");
	if (old == 0x05) ok |= 1 << 0;
	if (lock_byte == 0xFF) ok |= 1 << 1;
	if (__ajit_load_ubyte_mmu_bypass__((uint32_t) &lock_byte) == 0xFF) ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}
