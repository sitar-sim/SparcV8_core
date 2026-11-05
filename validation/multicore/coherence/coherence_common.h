// coherence_common.h
//
// Shared by the tests in validation/multicore/coherence/. They run with
// caching on, which each core turns on for itself, and with coherence on, which
// the simulator's --coherent option turns on (each test's .vprj has a RUN_OPTIONS
// line).
//
// The point of most of these tests is that they read shared data with ordinary
// cached loads, unlike the rest of validation/multicore/. Each also "primes" its
// cache first, by reading the shared data before another core writes it. A line
// that was never cached proves nothing, since a miss reads memory anyway.
//
// Shared words live one per cache line, so that nothing but the test's own
// accesses touch each line.

#ifndef COHERENCE_COMMON_H
#define COHERENCE_COMMON_H

#include "../multicore_common.h"
#include "multicore_sync.h"

#define LINE_BYTES 64
#define SHARED_WORD(n) ((volatile uint32_t*) (SHARED_BASE + (n) * LINE_BYTES))

// Nothing is cached with the MMU off unless the MMU Control Register's "always
// cacheable" bit is set. Each core has its own MMU, so each core does this.
static inline void turn_caching_on(void)
{
	uint32_t value = 0x100;
	__asm__ __volatile__("sta %0, [%%g0] 0x4" : : "r"(value) : "memory");
}

static inline void spin(uint32_t iterations)
{
	volatile uint32_t i;
	for (i = 0; i < iterations; i++)
		;
}

// A different short delay for each core and round, so that the cores meet in many
// different ways. A small linear congruential generator, enough to vary timing.
static inline uint32_t varied_delay(uint32_t round)
{
	return ((round * 2654435761u + this_core_id() * 40503u) >> 16) & 7;
}

//---------------------------------------------------------------------
// The shape of every litmus test
//---------------------------------------------------------------------
// A litmus test has the cores do a few reads and writes at the same moment, over
// and over, and checks an outcome that memory ordering forbids never happens.

#define LITMUS_ROUNDS 100

#define X SHARED_WORD(0)
#define Y SHARED_WORD(1)

static barrier_t litmus_barrier;

// Core 0 clears X and Y, and every core reads them into its cache. Then every core
// waits for the others and for its own short delay, so that they start together.
static inline void litmus_start(uint32_t round)
{
	if (this_core_id() == 0)
	{
		*X = 0;
		*Y = 0;
	}
	barrier_wait(&litmus_barrier, NUM_CORES);
	(void) *X;
	(void) *Y;
	barrier_wait(&litmus_barrier, NUM_CORES);
	spin(varied_delay(round));
}

static inline void litmus_end(void)
{
	barrier_wait(&litmus_barrier, NUM_CORES);
}

#endif
