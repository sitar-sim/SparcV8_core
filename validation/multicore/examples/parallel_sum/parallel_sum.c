// parallel_sum.c
//
// A worked example for the docs (Ref docs/source/multicore/examples.md):
// the four cores sum an array together. The array is split into four
// equal slices, and core i fills and sums slice i. Each core then
// publishes its partial sum in a word of its own and sets its own
// "done" flag. Core 0 waits for every flag, adds the partial sums, and
// stores the total in shared memory, where the .vprj checks it.
//
// Every shared word has exactly one writer, so no lock is needed. A
// core reads what another core wrote with read_shared(), so the program
// also works with SPARC_ALWAYS_CACHEABLE=1.
//
// Every core:
//   0. (core 0) saw every core's done flag and stored the right total
//      (other cores) summed its own slice correctly.

#include "../../multicore_common.h"

#define N         4096
#define SLICE     (N / NUM_CORES)
#define TOTAL_ADDR SHARED_BASE

int data[N];

// In .bss, so core 0 has cleared them before any core reaches main().
volatile uint32_t partial_sum[NUM_CORES];
volatile uint32_t done[NUM_CORES];

static uint32_t value_at(int i) { return (uint32_t)(i * 7 + 3); }

int main(void)
{
	uint32_t ok = 0;
	uint32_t id = this_core_id();
	int first = id * SLICE;
	int i, k, polls;
	uint32_t sum = 0, expected = 0;

	//Fill and sum this core's own slice.
	for (i = first; i < first + SLICE; i++)
		data[i] = value_at(i);
	for (i = first; i < first + SLICE; i++)
		sum += data[i];

	//Publish the partial sum first, then the flag. A core's stores reach
	//memory in program order, so a core that sees the flag sees the sum.
	partial_sum[id] = sum;
	done[id] = 1;

	if (id == 0)
	{
		uint32_t total = 0;
		int all_done = 1;
		for (k = 0; k < NUM_CORES; k++)
		{
			polls = 0;
			while (read_shared(&done[k]) == 0 && polls < WAIT_LIMIT)
				polls++;
			if (polls == WAIT_LIMIT)
				all_done = 0;
			total += read_shared(&partial_sum[k]);
		}
		*(volatile uint32_t*) TOTAL_ADDR = total;

		for (i = 0; i < N; i++)
			expected += value_at(i);
		if (all_done && total == expected) ok |= 1 << 0;
	}
	else
	{
		for (i = first; i < first + SLICE; i++)
			expected += value_at(i);
		if (sum == expected) ok |= 1 << 0;
	}

	report_and_halt(ok, 1);
	return 0;
}
