// ipi_from_core0.c
//
// Inter-processor interrupts from core 0 to every other core (Ref
// compiler/include/ajit_ipi.h). Core 0 enables the IPI mask bit of cores
// 1 to 3, then sends each of them an IPI in turn, with a pointer to that
// core's own payload word. It waits for each core to take its IPI before
// sending the next, because the IPI mask and value words are changed by
// read-modify-write, and two cores changing them at once could lose a
// bit. (A lock makes that safe once the cores have atomics.) A core
// reads what another core wrote with read_shared(), so the test also
// passes with SPARC_ALWAYS_CACHEABLE=1.
//
// Every core:
//   0. takes exactly the IPIs meant for it: one for cores 1 to 3, none
//      for core 0, whose mask bit stays clear;
//   1. (cores 1 to 3) finds the right message in its own message area:
//      source core 0, destination itself, and the pointer to its payload
//      (core 0: every IPI it sent was taken).

#include "../../multicore_common.h"
#include "ajit_ipi.h"

#define IPI_BASE ADDR_INTERRUPT_CONTROLLER_IPI_BASE

// In .bss, so core 0 has cleared them before any core reaches main().
volatile uint32_t ipis_taken[NUM_CORES];
volatile uint32_t message_ids[NUM_CORES];
volatile uint32_t message_pointer[NUM_CORES];
volatile uint32_t payload[NUM_CORES];

void ipi_handler(void)
{
	uint32_t id  = this_core_id();
	uint32_t msg = ajitIpiMessageAddress(IPI_BASE, id, 0);
	message_ids[id]     = __ajit_load_word_mmu_bypass__(msg);
	message_pointer[id] = __ajit_load_word_mmu_bypass__(msg + 4);
	__ajit_clear_ipi_interrupt__(IPI_BASE, id, 0); //clear the source
	ipis_taken[id]++;
}

int main(void)
{
	uint32_t ok = 0;
	uint32_t id = this_core_id();
	int k, polls, i;

	//The handler table is shared by every core. Core 0 cleared it with
	//.bss, and every core installs the same handler, so the writes agree.
	ajit_set_interrupt_handler(IPI_IRL, ipi_handler);
	writeInterruptControlRegister(id, 0, (1u << IPI_IRL) | 1u);

	if (id == 0)
	{
		int sent = 0;
		for (k = 1; k < NUM_CORES; k++)
			__ajit_enable_ipi_interrupt__(IPI_BASE, k, 0);
		for (k = 1; k < NUM_CORES; k++)
		{
			payload[k] = 0xC0DE0000u + k;
			if (__ajit_set_ipi_interrupt__(IPI_BASE, 0, 0, k, 0, (void*) &payload[k]) == 0)
				sent++;
			polls = 0;
			while (read_shared(&ipis_taken[k]) == 0 && polls < WAIT_LIMIT)
				polls++;
		}
		for (i = 0; i < 200; i++) ; //time for a (wrong) IPI to core 0 to show up
		if (ipis_taken[0] == 0) ok |= 1 << 0;
		if (sent == NUM_CORES - 1 && read_shared(&ipis_taken[1]) == 1 &&
		    read_shared(&ipis_taken[2]) == 1 && read_shared(&ipis_taken[3]) == 1)
			ok |= 1 << 1;
	}
	else
	{
		polls = 0;
		while (ipis_taken[id] == 0 && polls < WAIT_LIMIT)
			polls++;
		for (i = 0; i < 200; i++) ; //time for a (wrong) second IPI to show up
		if (ipis_taken[id] == 1) ok |= 1 << 0;
		if (message_ids[id] == ((id << 8) | 0) && message_pointer[id] == (uint32_t) &payload[id] &&
		    read_shared(&payload[id]) == 0xC0DE0000u + id)
			ok |= 1 << 1;
	}

	report_and_halt(ok, 2);
	return 0;
}
