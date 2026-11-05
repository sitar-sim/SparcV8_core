// multicore_common.h
//
// Shared by every C test in validation/multicore/. Every core runs the
// same main() (Ref compiler/crt0_multicore.s, which every test here
// starts from) and reports for itself, the way validation/C/devices/
// tests do on one core: %o0 = 1 if every one of its checks passed, else
// 0, and %o1 = a bit per check. Then it halts with `ta 0`. The run ends
// once every core has halted, and the .vprj checks each core's %o0/%o1
// (`core2.o0 = 1`).

#ifndef MULTICORE_COMMON_H
#define MULTICORE_COMMON_H

#include <stdint.h>
#include "ajit_access_routines.h"
#include "multicore_core.h"
// Defines ajit_generic_interrupt_handler(), which crt0_multicore.s's
// interrupt entry calls.
#include "ajit_mt_irc.h"

#define NUM_CORES 4

// The startup file's layout (Ref crt0_multicore.s).
#define STACK_TOP            0x0ffffff0u
#define STACK_BYTES_PER_CORE 0x00100000u
#define BOOT_RELEASE_FLAG    0xFFFF2C00u

// A shared area at a fixed address, for results a .vprj checks with
// m[...] lines. Well above any test program, well below the stacks.
#define SHARED_BASE 0x00100000u

// Generous bound for every "wait for another core or a device" loop, so
// a broken model fails the test instead of spinning until the cycle
// limit.
#define WAIT_LIMIT 100000

// Marks this core finished in a word of its own, then waits for all the
// others to do the same, so that a test can check a final result on
// every core. Returns 1 if they all finished within WAIT_LIMIT polls.
static inline uint32_t finish_and_wait_for_all(volatile uint32_t* done)
{
	uint32_t c, tries;
	done[this_core_id()] = 1;
	for (c = 0; c < NUM_CORES; c++)
	{
		for (tries = 0; read_shared(&done[c]) != 1; tries++)
			if (tries >= WAIT_LIMIT)
				return 0;
	}
	return 1;
}

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
