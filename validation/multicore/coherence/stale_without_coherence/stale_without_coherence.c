// stale_without_coherence.c
//
// write_seen_by_plain_load with coherence off (see this test's RUN_OPTIONS line, which
// also overrides SPARC_COHERENT=1 in the environment). Cores 1 to 3 go on reading
// their old cached copy after core 0 has written the word, until they flush. This
// is why a program without coherence must use uncached loads or flushes, and it
// shows that write_seen_by_plain_load really tests something.
//
// Every core checks:
//   0. it read the old value first
//   1. after the write: core 0 sees its own write, and the others still see the old value
//   2. after a flush, a plain load sees the new value
#include "../coherence_common.h"

#define VALUE SHARED_WORD(0)

static barrier_t barrier;

int main(void)
{
	uint32_t ok = 0, id = this_core_id();
	turn_caching_on();

	if (*VALUE == 0) ok |= 1 << 0;
	barrier_wait(&barrier, NUM_CORES);

	if (id == 0)
		*VALUE = 0x1234;
	barrier_wait(&barrier, NUM_CORES);

	if (*VALUE == (id == 0 ? 0x1234u : 0u)) ok |= 1 << 1;
	flush_caches();
	if (*VALUE == 0x1234) ok |= 1 << 2;
	report_and_halt(ok, 3);
	return 0;
}
