// caches_common.h
//
// Shared by every test in validation/C/caches/. These tests only make
// sense on a configuration with L1 caches (core_l1cache_mmu_devices and
// up), and some of them (stale_until_flush) deliberately show behavior
// that only a non-coherent cache has.
//
// Reporting is the same as validation/C/devices/: %o0 = 1 if every check
// passed, %o1 = one bit per check.

#ifndef CACHES_COMMON_H
#define CACHES_COMMON_H

#include <stdint.h>
#include "ajit_access_routines.h"

#define ASI_MMU_REGISTER_ASI 0x04
#define ASI_FLUSH_I_AND_D    0x10

// With the MMU disabled, nothing is cached unless the MMU Control
// Register's "always cacheable" bit (bit 8) is set, as in AJIT. The MMU
// itself stays disabled (bit 0 clear).
static inline void set_always_cacheable(void)
{
	uint32_t value = 0x100;
	__asm__ __volatile__("sta %0, [%%g0] %1" : : "r"(value), "i"(ASI_MMU_REGISTER_ASI) : "memory");
}

// A store with ASI 0x10 flushes both L1 caches entirely.
static inline void flush_both_caches(void)
{
	__asm__ __volatile__("sta %%g0, [%%g0] %0" : : "i"(ASI_FLUSH_I_AND_D) : "memory");
}

static inline void report_and_halt(uint32_t checks_passed_bits, uint32_t number_of_checks)
{
	uint32_t all  = (number_of_checks >= 32) ? 0xffffffffu : ((1u << number_of_checks) - 1);
	uint32_t pass = (checks_passed_bits == all) ? 1 : 0;
	__asm__ __volatile__("mov %0, %%o0\n\tmov %1, %%o1\n\tta 0"
	                     : : "r"(pass), "r"(checks_passed_bits) : "o0", "o1");
	while (1) {}
}

#endif
