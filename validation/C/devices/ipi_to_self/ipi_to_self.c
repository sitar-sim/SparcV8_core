// ipi_to_self.c
//
// An inter-processor interrupt from this thread to itself, using AJIT's
// IPI routines (Ref compiler/include/ajit_ipi.h).
//   0. enabling the IPI mask bit succeeds
//   1. setting the IPI succeeds, and its handler runs exactly once
//   2. the handler finds the message left for it (source ids, pointer)
//   3. the lock word is separate storage from the mask and value words

#include "../devices_common.h"
#include "ajit_mt_irc.h"
#include "ajit_ipi.h"

#define IPI_BASE ADDR_INTERRUPT_CONTROLLER_IPI_BASE

volatile uint32_t ipi_count = 0;
volatile uint32_t message_ids = 0, message_pointer = 0;
uint32_t payload = 0x5A5A;

void ipi_handler(void)
{
	uint32_t msg = IPI_BASE + 8; //destination thread 0's message area
	message_ids     = __ajit_load_word_mmu_bypass__(msg);
	message_pointer = __ajit_load_word_mmu_bypass__(msg + 4);
	__ajit_clear_ipi_interrupt__(IPI_BASE, 0, 0); //clear the source
	ipi_count++;
}

int main(void)
{
	uint32_t ok = 0;
	int i;

	ajit_initialize_interrupt_handlers_to_null();
	ajit_set_interrupt_handler(IPI_IRL, ipi_handler);
	writeInterruptControlRegister(0, 0, (1u << IPI_IRL) | 1u);

	if (__ajit_enable_ipi_interrupt__(IPI_BASE, 0, 0) == 0) ok |= 1 << 0;

	__ajit_store_word_mmu_bypass__(0x10C4u, __AJIT_IPI_LOCK_ADDRESS(IPI_BASE));
	int set = __ajit_set_ipi_interrupt__(IPI_BASE, 0, 0, 0, 0, &payload);

	int polls = 0;
	while (ipi_count == 0 && polls < WAIT_LIMIT)
		polls++;
	for (i = 0; i < 200; i++) ;
	if (set == 0 && ipi_count == 1) ok |= 1 << 1;
	if (message_ids == 0 && message_pointer == (uint32_t) &payload) ok |= 1 << 2;
	if (__ajit_load_word_mmu_bypass__(__AJIT_IPI_LOCK_ADDRESS(IPI_BASE)) == 0x10C4u &&
	    __ajit_load_word_mmu_bypass__(IPI_BASE) == 1u) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}
