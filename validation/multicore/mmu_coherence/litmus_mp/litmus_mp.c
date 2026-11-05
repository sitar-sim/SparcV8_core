// litmus_mp.c
//
// Message passing with the MMU on, where the writer and each reader reach the data and the
// flag through different virtual addresses. Core 0 writes the data and then the flag. A core
// that sees the flag must also see the data.
//
// Every core checks:
//   0. it never saw the flag without the data
//   1. after every round, a plain load sees both writes
#include "../mmu_coherence_common.h"

#define ROUNDS 50
#define DATA(core) ((volatile uint32_t*) VA(core))
#define FLAG(core) ((volatile uint32_t*) (VA(core) + 0x40))

int main(void)
{
	uint32_t ok = (1 << 0) | (1 << 1), id = this_core_id(), round;

	if (id == 0)
	{
		uint32_t c;
		build_context(0);
		for (c = 0; c < NUM_CORES; c++)
			map_page(0, VA(c), frame);
		release_tables();
	}
	else
		wait_for_tables();
	start_mmu(0);
	sync_cores();

	for (round = 0; round < ROUNDS; round++)
	{
		volatile uint32_t delay;
		if (id == 0)
		{
			*DATA(0) = 0;
			*FLAG(0) = 0;
		}
		sync_cores();
		(void) *DATA(id);
		(void) *FLAG(id);
		sync_cores();
		for (delay = 0; delay < (((round * 2654435761u + id * 40503u) >> 16) & 7); delay++)
			;
		if (id == 0)
		{
			*DATA(0) = 1;
			*FLAG(0) = 1;
		}
		else
		{
			uint32_t flag = *FLAG(id);
			uint32_t data = *DATA(id);
			if (flag == 1 && data == 0)
				ok &= ~(1u << 0);
		}
		sync_cores();
		if (!(*DATA(id) == 1 && *FLAG(id) == 1))
			ok &= ~(1u << 1);
		sync_cores();
	}
	report_and_halt(ok, 2);
	return 0;
}
