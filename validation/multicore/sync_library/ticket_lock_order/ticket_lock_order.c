// ticket_lock_order.c
//
// A ticket lock serves cores strictly in the order of their tickets. Inside
// the lock, each core appends its ticket to a shared log. The log must then
// read 0, 1, 2, and so on with nothing missing or out of order, and the lock
// must also have protected the log's own length.
//
// Every core checks:
//   0. each ticket it held matched the log's length when it got the lock
//   1. every core finished, and the log is exactly 0, 1, 2, ...
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ROUNDS 25
#define TOTAL  (NUM_CORES * ROUNDS)

static ticket_lock_t lock;

#define LENGTH ((volatile uint32_t*) SHARED_BASE)
#define DONE   ((volatile uint32_t*) (SHARED_BASE + 0x10))
#define LOG    ((volatile uint32_t*) (SHARED_BASE + 0x40))

int main(void)
{
	uint32_t ok = 1 << 0, in_order = 1, i;
	for (i = 0; i < ROUNDS; i++)
	{
		uint32_t ticket = ticket_lock_acquire(&lock);
		uint32_t length = read_shared(LENGTH);
		if (length != ticket)
			ok &= ~(1u << 0);
		if (length < TOTAL)
			LOG[length] = ticket;
		*LENGTH = length + 1;
		ticket_lock_release(&lock);
	}
	if (finish_and_wait_for_all(DONE) && read_shared(LENGTH) == TOTAL)
	{
		for (i = 0; i < TOTAL; i++)
			if (read_shared(&LOG[i]) != i)
				in_order = 0;
		if (in_order) ok |= 1 << 1;
	}
	report_and_halt(ok, 2);
	return 0;
}
