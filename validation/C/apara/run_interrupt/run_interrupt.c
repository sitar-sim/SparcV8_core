// run_interrupt.c
//
// The engine's interrupt (IRL 14) when a thread stops: ask for it, take
// it in a trap handler.
//   0. the completion command is still waiting right after it was given
//   1. the handler runs exactly once
//   2. the handler finds the completion word valid with the halt bit
//   3. the thread ran its whole loop ($r1 = -1)

#include "../apara_common.h"
#include "ajit_mt_irc.h"
#include "kernel.mcode.h"

volatile uint32_t engine_interrupts = 0;
volatile uint32_t completion_in_handler = 0;

void engine_handler(void)
{
	completion_in_handler = apara_thread_completion(0);
	apara_clear_interrupt(0);
	engine_interrupts++;
}

int main(void)
{
	uint32_t ok = 0;
	ajit_initialize_interrupt_handlers_to_null();
	ajit_set_interrupt_handler(EXTERNAL_IRL, engine_handler);
	writeInterruptControlRegister(0, 0, (1u << EXTERNAL_IRL) | 1u);

	apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
	apara_write_thread_register(0, 1, 300);
	apara_start_thread(0, KERNEL_LOOP);
	apara_request_completion_interrupt(0);
	if (!apara_ccu_command_done(0)) ok |= 1 << 0;

	int polls = 0;
	while (engine_interrupts == 0 && polls < WAIT_LIMIT)
		polls++;
	int i;
	for (i = 0; i < 200; i++) ; //time for a (wrong) second interrupt
	if (engine_interrupts == 1) ok |= 1 << 1;
	if (completion_in_handler == (APARA_COMPLETION_VALID | APARA_ERROR_HALT)) ok |= 1 << 2;
	if (apara_read_thread_register(0, 1) == 0xffffffffffffffffULL) ok |= 1 << 3;

	report_and_halt(ok, 4);
	return 0;
}
