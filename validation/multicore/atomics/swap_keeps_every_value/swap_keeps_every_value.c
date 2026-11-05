// swap_keeps_every_value.c
//
// One shared word and four private ones hold five different values between
// them. Every core repeatedly swaps its private value with the shared word.
// A SWAP only ever exchanges two values, so however the cores interleave, the
// same five values must still exist at the end, once each. Without atomicity,
// two cores can read the same value before either writes, so one value is
// duplicated and another is lost for good.
//
// No lock is used, so this tests SWAP directly.
//
// Every core checks:
//   0. it finished every swap, and always held one of the five values
//   1. every core finished, and each of the five values exists exactly once
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define SWAPS 100

#define TOKEN(n) (0xA0000000u + (n))  /* n = 0 to 4 */

// Starts as TOKEN(4), so it is in .data, and already set when core 0 lets
// the other cores go.
static volatile uint32_t shared_word = TOKEN(4);

#define HELD ((volatile uint32_t*) SHARED_BASE)
#define DONE ((volatile uint32_t*) (SHARED_BASE + 0x20))

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), held = TOKEN(id), i, n, c;
	uint32_t seen = 0;
	for (i = 0; i < SWAPS; i++)
	{
		held = atomic_swap(&shared_word, held);
		if (held < TOKEN(0) || held > TOKEN(4))
			ok &= ~(1u << 0);
	}
	HELD[id] = held;
	if (finish_and_wait_for_all(DONE))
	{
		for (c = 0; c <= NUM_CORES; c++)
		{
			uint32_t v = (c < NUM_CORES) ? read_shared(&HELD[c]) : read_shared(&shared_word);
			n = v - TOKEN(0);
			if (n <= 4)
				seen += 1u << (n * 4); //a 4-bit count per value
		}
		if (seen == 0x11111u) ok |= 1 << 1;
	}
	report_and_halt(ok, 2);
	return 0;
}
