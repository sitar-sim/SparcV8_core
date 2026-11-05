// mixed_instructions.c
//
// One lock, taken by each core with a different atomic instruction: LDSTUB,
// SWAP, LDSTUBA and SWAPA. The alternate-space forms use ASI 0x20 (MMU
// bypass) and ASI 0x0B (supervisor data). All four take the same path through
// the bus, so they must exclude one another, and the counter must be exact.
//
// The word is big-endian, and LDSTUB looks only at its first byte, so a SWAP
// of the value 1 would change only the last byte and leave the lock looking
// free to LDSTUB. The SWAP forms therefore write all ones. A program that
// mixes the two instructions on one lock has to do the same.
//
// Every core checks:
//   0. it finished every iteration
//   1. every core finished, and the total is NUM_CORES * ITERATIONS
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ITERATIONS 100

// A word, so that it is aligned for the SWAP forms. LDSTUB uses its first byte.
static volatile uint32_t lock;

#define COUNTER ((volatile uint32_t*) SHARED_BASE)
#define DONE    ((volatile uint32_t*) (SHARED_BASE + 0x10))

// One attempt at the lock. Returns nonzero if it was already held.
static uint32_t try_lock(uint32_t id)
{
	uint32_t old = 0xFFFFFFFFu;
	switch (id)
	{
		case 0:
			__asm__ __volatile__("ldstub [%1], %0" : "=r"(old) : "r"(&lock) : "memory");
			break;
		case 1:
			__asm__ __volatile__("swap [%1], %0" : "=r"(old) : "r"(&lock), "0"(old) : "memory");
			break;
		case 2:
			__asm__ __volatile__("ldstuba [%1] 0x20, %0" : "=r"(old) : "r"(&lock) : "memory");
			break;
		default:
			__asm__ __volatile__("swapa [%1] 0x0b, %0" : "=r"(old) : "r"(&lock), "0"(old) : "memory");
			break;
	}
	return old;
}

int main(void)
{
	uint32_t ok = 0, id = this_core_id(), mine = 0, i;
	for (i = 0; i < ITERATIONS; i++)
	{
		while (try_lock(id) != 0)
			;
		*COUNTER = read_shared(COUNTER) + 1;
		mine++;
		lock = 0;
	}
	if (mine == ITERATIONS) ok |= 1 << 0;
	if (finish_and_wait_for_all(DONE) && read_shared(COUNTER) == NUM_CORES * ITERATIONS) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
