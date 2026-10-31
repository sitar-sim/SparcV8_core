// staggered_halt.c
//
// The run ends only once every core has halted, however far apart they
// halt. Core i counts to (i + 1) * 3000 before halting, so core 3 halts
// long after core 0. Each core stores its final count in the shared
// area (m[] checks in the .vprj) and reports:
//   0: its count reached the target;
//   1: it stored the count where the .vprj looks for it.

#include "../../multicore_common.h"

int main(void)
{
	uint32_t ok = 0;
	uint32_t id = this_core_id();
	uint32_t target = (id + 1) * 3000;

	volatile uint32_t count = 0;
	while (count < target)
		count++;
	if (count == target) ok |= 1 << 0;

	volatile uint32_t* counts = (volatile uint32_t*) SHARED_BASE;
	counts[id] = count;
	if (counts[id] == target) ok |= 1 << 1;

	report_and_halt(ok, 2);
	return 0;
}
