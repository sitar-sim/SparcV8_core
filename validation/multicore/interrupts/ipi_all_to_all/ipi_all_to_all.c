// ipi_all_to_all.c
//
// Every core sends IPIs to every other core at once. A sender may find that its destination
// has not yet taken the last one, and must wait, leaving that IPI's message alone. Each message
// carries its sender and a sequence number, and these must agree.
//
// Every core checks:
//   0. it took all it was sent, within the wait limit
//   1. each message's pointer names the sender its header names
//   2. from each sender, the sequence numbers came in order, with none lost
#include "../../multicore_common.h"
#include "multicore_platform.h"

#define ROUNDS 20

volatile uint32_t taken[NUM_CORES];
volatile uint32_t wrong_sender[NUM_CORES];
volatile uint32_t wrong_sequence[NUM_CORES];
volatile uint32_t next_sequence[NUM_CORES][NUM_CORES];
static barrier_t barrier;

static void handler(void)
{
	uint32_t id = this_core_id(), source;
	uint32_t pointer = (uint32_t) ipi_receive(&source);
	uint32_t named = pointer >> 16, sequence = pointer & 0xFFFF;
	if (named != source)
		wrong_sender[id]++;
	else
	{
		if (sequence != next_sequence[id][named])
			wrong_sequence[id]++;
		next_sequence[id][named] = sequence + 1;
	}
	taken[id]++;
}

int main(void)
{
	uint32_t ok = 0, id = this_core_id(), round, c, polls;

	ipi_start_on_this_core(handler);
	barrier_wait(&barrier, NUM_CORES);

	for (round = 0; round < ROUNDS; round++)
		for (c = 0; c < NUM_CORES; c++)
			if (c != id)
				ipi_send(c, (void*) ((id << 16) + round));

	for (polls = 0; taken[id] < ROUNDS * (NUM_CORES - 1) && polls < WAIT_LIMIT; polls++)
		;
	barrier_wait(&barrier, NUM_CORES);

	if (taken[id] == ROUNDS * (NUM_CORES - 1)) ok |= 1 << 0;
	if (wrong_sender[id] == 0) ok |= 1 << 1;
	if (wrong_sequence[id] == 0) ok |= 1 << 2;
	report_and_halt(ok, 3);
	return 0;
}
