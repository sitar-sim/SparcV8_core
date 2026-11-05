// multicore_core.h
//
// What a program running on several cores needs first: which core it is
// on, and how to read what another core has written. Every routine here
// is a small inline function, so there is nothing to link.
//
// The caches are not coherent by default, so a plain load can return this
// core's own old cached copy of a location another core has since written. The
// "shared" reads below never use the cache. They use the MMU-bypass ASI,
// which takes a physical address. The MMU is off when a program starts, so
// by default a variable's address is its physical address. This matters only
// if a program turns the MMU on and maps shared data at a different physical
// address.

#ifndef MULTICORE_CORE_H
#define MULTICORE_CORE_H

#include <stdint.h>
#include "ajit_access_routines.h"

static inline uint32_t this_core_id(void)
{
	uint8_t core_id, thread_id;
	ajit_get_core_and_thread_id(&core_id, &thread_id);
	return core_id;
}

// Reads a word another core writes, without using the cache.
static inline uint32_t read_shared(volatile uint32_t* p)
{
	return __ajit_load_word_mmu_bypass__((uint32_t) p);
}

// Reads a byte another core writes, without using the cache.
static inline uint8_t read_shared_byte(volatile uint8_t* p)
{
	uint32_t value;
	__asm__ __volatile__("lduba [%1] 0x20, %0" : "=r"(value) : "r"(p) : "memory");
	return (uint8_t) value;
}

// Empties this core's own L1 caches (a store with ASI 0x10 flushes both,
// Ref model/cpp_common_code/cache/L1CachesCore.h). After it, the core's
// next load of any address comes from main memory, so it sees every
// write another core has made so far.
static inline void flush_caches(void)
{
	__asm__ __volatile__("sta %%g0, [%%g0] 0x10" : : : "memory");
}

#endif
