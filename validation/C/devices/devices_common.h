// devices_common.h
//
// Shared by every test in validation/C/devices/. The device access
// routines themselves come from compiler/include/ (AJIT's API, this
// project's implementation): ajit_access_routines.h, ajit_mt_irc.h,
// ajit_ipi.h.
//
// Every test reports the same way: %o0 = 1 if every check passed, else
// 0, and %o1 = a bit per check (bit i set if check i passed), so a
// failing run's .vprj mismatch shows which check failed. Then it halts
// with `ta 0`, as every test here does.

#ifndef DEVICES_COMMON_H
#define DEVICES_COMMON_H

#include <stdint.h>
#include "ajit_access_routines.h"

// Generous bound for every "wait for the device" loop, so a broken model
// fails the test instead of spinning until the cycle limit.
#define WAIT_LIMIT 100000

static inline void report_and_halt(uint32_t checks_passed_bits, uint32_t number_of_checks)
{
	uint32_t all  = (number_of_checks >= 32) ? 0xffffffffu : ((1u << number_of_checks) - 1);
	uint32_t pass = (checks_passed_bits == all) ? 1 : 0;
	//One asm statement, with %o0/%o1 declared clobbered, so the compiler
	//never hands us either input already sitting in %o0 or %o1.
	__asm__ __volatile__("mov %0, %%o0\n\tmov %1, %%o1\n\tta 0"
	                     : : "r"(pass), "r"(checks_passed_bits) : "o0", "o1");
	while (1) {}
}

#endif
