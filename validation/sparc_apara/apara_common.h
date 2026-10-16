// apara_common.h
//
// Shared by every test in validation/sparc_apara/ (the APARA engine, from the
// SPARC side, on the sparc_apara configuration). The engine routines come
// from compiler/include/apara_access_routines.h. Each test reports as the
// device tests do (Ref ../C/devices/devices_common.h): %o0 = 1 if every
// check passed, %o1 = a bit per check.

#ifndef APARA_COMMON_H
#define APARA_COMMON_H

#include "../C/devices/devices_common.h"
#include "apara_access_routines.h"

// A main-memory word read straight from memory (not from the data
// cache), for data the engine has written there.
static inline uint32_t physical_word(const volatile uint32_t* p)
{
	return __ajit_load_word_mmu_bypass__((uint32_t) p);
}

// A 64-bit engine result equals a 32-bit value the SPARC computed
// (sign-extended): the SPARC has no 64-bit multiply, so the tests check
// with 32-bit arithmetic.
static inline int dword_equals(uint32_t dmem_offset, int32_t expected)
{
	return apara_dmem_read_word(dmem_offset) == (expected < 0 ? 0xffffffffu : 0u) &&
	       apara_dmem_read_word(dmem_offset + 4) == (uint32_t) expected;
}

// Deterministic test data: a 32-bit linear congruential sequence.
static inline uint32_t next_random(uint32_t* state)
{
	*state = *state * 1664525u + 1013904223u;
	return *state >> 8;
}

// The startup code (compiler/crt0.s) leaves the FPU off (PSR.EF = 0), so
// a test that computes with floats on the SPARC turns it on first.
static inline void enable_fpu(void)
{
	__asm__ __volatile__("rd %%psr, %%g1\n\tset 0x1000, %%g2\n\tor %%g1, %%g2, %%g1\n\t"
	                     "wr %%g1, %%psr\n\tnop\n\tnop\n\tnop" : : : "g1", "g2");
}

// The completion word of a thread that ended with $halt.
#define HALTED (APARA_COMPLETION_VALID | APARA_ERROR_HALT)

#endif
