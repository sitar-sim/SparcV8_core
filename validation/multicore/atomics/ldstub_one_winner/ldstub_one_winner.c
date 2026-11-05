// ldstub_one_winner.c
//
// A row of BYTES bytes, all 0. Every core walks along the row doing one
// LDSTUB on each byte, and counts the ones that returned 0. Since LDSTUB
// sets the byte, exactly one core can ever see 0 for each byte, so the wins
// of all the cores must add up to exactly BYTES. Without atomicity, two
// cores can both read 0 from the same byte, and the sum comes out too high.
//
// The cores run the same code in step, so they often reach the same byte at
// nearly the same time. No lock is used, so this tests LDSTUB directly.
//
// Every core checks:
//   0. it saw only 0 or 0xFF from every byte
//   1. every core finished, and the wins add up to BYTES
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define BYTES 256

#define ROW  ((volatile uint8_t*)  SHARED_BASE)
#define WINS ((volatile uint32_t*) (SHARED_BASE + 0x200))
#define DONE ((volatile uint32_t*) (SHARED_BASE + 0x210))

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), wins = 0, total = 0, i;
	for (i = 0; i < BYTES; i++)
	{
		uint8_t old = atomic_ldstub(&ROW[i]);
		if (old == 0)
			wins++;
		else if (old != 0xFF)
			ok &= ~(1u << 0);
	}
	WINS[id] = wins;
	if (finish_and_wait_for_all(DONE))
	{
		for (i = 0; i < NUM_CORES; i++)
			total += read_shared(&WINS[i]);
		if (total == BYTES) ok |= 1 << 1;
	}
	report_and_halt(ok, 2);
	return 0;
}
