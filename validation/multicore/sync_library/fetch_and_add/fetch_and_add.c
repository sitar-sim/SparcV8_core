// fetch_and_add.c
//
// Each core calls atomic_fetch_and_add() TICKETS times, and marks the value it
// got in a table with one byte per value. If the counter is atomic, every value
// from 0 to NUM_CORES * TICKETS - 1 is handed out exactly once. A value handed out
// twice means an addition was lost.
//
// Every core checks:
//   0. no value it received was out of range, or already marked
//   1. every core finished, the counter is exact, and every value was handed out
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define TICKETS 50
#define TOTAL   (NUM_CORES * TICKETS)

static atomic_counter_t counter;

#define MARKS ((volatile uint8_t*)  SHARED_BASE)
#define DONE  ((volatile uint32_t*) (SHARED_BASE + 0x400))

int main(void)
{
	uint32_t ok = 1 << 0, all_marked = 1, i;
	for (i = 0; i < TICKETS; i++)
	{
		uint32_t value = atomic_fetch_and_add(&counter, 1);
		if (value >= TOTAL || read_shared_byte(&MARKS[value]) != 0)
			ok &= ~(1u << 0);
		else
			MARKS[value] = 1;
	}
	if (finish_and_wait_for_all(DONE) && atomic_counter_read(&counter) == TOTAL)
	{
		for (i = 0; i < TOTAL; i++)
			if (read_shared_byte(&MARKS[i]) != 1)
				all_marked = 0;
		if (all_marked) ok |= 1 << 1;
	}
	report_and_halt(ok, 2);
	return 0;
}
