// ipi_ping_pong.c
//
// Two pairs of cores, 0 with 1 and 2 with 3, pass an IPI back and forth at the same time. Both
// pairs change the same IPI registers, so these are changed under the library's lock.
//
// Every core checks:
//   0. it took every IPI, within the wait limit
//   1. every IPI came from its partner
//   2. every IPI carried the partner's pointer for that round
#include "../../multicore_common.h"
#include "multicore_platform.h"

#define ROUNDS 50

volatile uint32_t taken[NUM_CORES];
volatile uint32_t wrong_source[NUM_CORES];
volatile uint32_t wrong_pointer[NUM_CORES];
static barrier_t barrier;

static void handler(void)
{
	uint32_t id = this_core_id(), source;
	uint32_t pointer = (uint32_t) ipi_receive(&source);
	if (source != (id ^ 1))
		wrong_source[id]++;
	if (pointer != (source << 16) + taken[id])
		wrong_pointer[id]++;
	taken[id]++;
}

static int wait_for(uint32_t id, uint32_t count)
{
	uint32_t polls;
	for (polls = 0; taken[id] < count; polls++)
		if (polls >= WAIT_LIMIT)
			return 0;
	return 1;
}

int main(void)
{
	uint32_t ok = 0, id = this_core_id(), partner = id ^ 1, round, all_taken = 1;

	ipi_start_on_this_core(handler);
	barrier_wait(&barrier, NUM_CORES);

	for (round = 0; round < ROUNDS; round++)
	{
		if ((id & 1) == 0)
		{
			ipi_send(partner, (void*) ((id << 16) + round));
			all_taken &= wait_for(id, round + 1);
		}
		else
		{
			all_taken &= wait_for(id, round + 1);
			ipi_send(partner, (void*) ((id << 16) + round));
		}
	}
	barrier_wait(&barrier, NUM_CORES);

	if (all_taken && taken[id] == ROUNDS) ok |= 1 << 0;
	if (wrong_source[id] == 0) ok |= 1 << 1;
	if (wrong_pointer[id] == 0) ok |= 1 << 2;
	report_and_halt(ok, 3);
	return 0;
}
