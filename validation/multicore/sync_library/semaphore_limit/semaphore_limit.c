// semaphore_limit.c
//
// A semaphore starting at LIMIT, so that at most LIMIT cores can be inside at
// once. Each core takes it, adds itself to a count of holders kept by an atomic
// counter, checks the count, does some work, removes itself, and posts. The
// count must never exceed LIMIT. The holders must also reach 2 at some point,
// or else the semaphore was behaving like a mutex. All four cores want it all the
// time, so that happens on any fair interleaving, but it is not checked,
// because a schedule that runs one core for long stretches need not produce it.
//
// Every core checks:
//   0. the count of holders never exceeded LIMIT
//   1. every core finished, nobody is left inside, and the semaphore is back at LIMIT
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define LIMIT  2
#define ROUNDS 25

static semaphore_t semaphore = SEMAPHORE_INITIALIZER(LIMIT);
static atomic_counter_t holders;

#define DONE ((volatile uint32_t*) SHARED_BASE)

int main(void)
{
	uint32_t ok = 1 << 0, i;
	for (i = 0; i < ROUNDS; i++)
	{
		volatile uint32_t work;
		semaphore_wait(&semaphore);
		if (atomic_fetch_and_add(&holders, 1) + 1 > LIMIT)
			ok &= ~(1u << 0);
		for (work = 0; work < 3; work++)
			;
		atomic_fetch_and_add(&holders, (uint32_t) -1);
		semaphore_post(&semaphore);
	}
	if (finish_and_wait_for_all(DONE)
	    && atomic_counter_read(&holders) == 0
	    && read_shared(&semaphore.count) == LIMIT)
		ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
