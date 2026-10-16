// dma_interrupt.c
//
// A DMA gather with its completion interrupt (IRL 14).
//   0. the handler runs exactly once
//   1. the control word in the handler shows the copy completed
//   2. DMEM holds the gathered bytes: 4 bursts of 3 bytes, 8 apart

#include "../../apara_common.h"
#include "ajit_mt_irc.h"

volatile uint32_t dma_interrupts = 0;
volatile uint32_t control_in_handler = 0;
uint8_t source[32] __attribute__((aligned(8)));

void engine_handler(void)
{
	control_in_handler = apara_dma_read(1, 0);
	apara_dma_clear_interrupt(1);
	dma_interrupts++;
}

int main(void)
{
	uint32_t ok = 0;
	int i;
	for (i = 0; i < 32; i++)
		source[i] = (uint8_t) (0xa0 + i);
	ajit_initialize_interrupt_handlers_to_null();
	ajit_set_interrupt_handler(EXTERNAL_IRL, engine_handler);
	writeInterruptControlRegister(0, 0, (1u << EXTERNAL_IRL) | 1u);

	apara_dma_start(1, APARA_DMA_LOAD, (uint32_t) source + 1, 0x40, 4, 8, 3, 1);
	int polls = 0;
	while (dma_interrupts == 0 && polls < WAIT_LIMIT)
		polls++;
	for (i = 0; i < 200; i++) ;
	if (dma_interrupts == 1) ok |= 1 << 0;
	if ((control_in_handler & APARA_DMA_FLAG_COMPLETED) && !(control_in_handler & APARA_DMA_FLAG_ERROR)) ok |= 1 << 1;

	//Expected DMEM bytes 0x40..0x4b: source[1+8b+k], b = 0..3, k = 0..2.
	uint32_t w[3] = {apara_dmem_read_word(0x40), apara_dmem_read_word(0x44), apara_dmem_read_word(0x48)};
	uint32_t good = 1;
	for (i = 0; i < 12; i++)
	{
		uint32_t byte = (w[i / 4] >> (8 * (3 - i % 4))) & 0xff;
		good &= byte == (uint32_t) (0xa0 + 1 + 8 * (i / 3) + i % 3);
	}
	if (good) ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}
