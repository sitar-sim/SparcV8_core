// ajit_mt_irc.h
//
// Routines for the multi-thread Interrupt Controller, and the interrupt
// dispatch scheme bare-metal programs use with it.
//
// Function names, signatures, and behavior follow AJIT's own
// ajit_mt_irc.h / ajit_mt_irc.c (tools/ajit_access_routines_mt/ in the
// ajit-toolchain repo). The implementation is this project's own.
//
// The Interrupt Controller has one control register per hardware
// thread, at ADDR_INTERRUPT_CONTROLLER_MIN + 4*((2*core_id) + thread_id):
//   [31]     1 while that thread's slot is interrupting   (read only)
//   [30:16]  active interrupt sources, IRL i at bit 15+i  (read only)
//   [15:1]   per-level enable mask, bit i = IRL i
//   [0]      enable for that thread
//
// Interrupt dispatch: a program built with compiler/crt0_interrupts.s
// (select it with `STARTUP = crt0_interrupts.s` in the test's .vprj)
// sends every interrupt trap (trap types 0x11..0x1F) to
// ajit_generic_interrupt_handler() below. That function disables this
// thread's interrupt controller slot, calls the handler registered for
// the interrupt level with ajit_set_interrupt_handler() (which must
// clear the interrupt's source, e.g. disable the timer), then re-enables
// the slot. An interrupt with no handler registered halts the processor.
//
// The handler table and ajit_generic_interrupt_handler() are ordinary
// (not static) definitions, so the startup code can call the handler.
// Include this header from exactly one C file of a program.

#ifndef AJIT_MT_IRC_H
#define AJIT_MT_IRC_H

#include <stdint.h>
#include "device_addresses.h"
#include "ajit_access_routines.h"

static inline uint32_t ajitInterruptControlRegisterAddress(int core_id, int thread_id)
{
	return ADDR_INTERRUPT_CONTROLLER_MIN + 4 * ((2 * core_id) + thread_id);
}

static inline uint32_t readInterruptControlRegister(int core_id, int thread_id)
{
	return __ajit_load_word_mmu_bypass__(ajitInterruptControlRegisterAddress(core_id, thread_id));
}

static inline void writeInterruptControlRegister(int core_id, int thread_id, uint32_t value)
{
	__ajit_store_word_mmu_bypass__(value, ajitInterruptControlRegisterAddress(core_id, thread_id));
}

// The read-only bits [31:16] are never written back.
static inline uint32_t ajitInterruptControlWritableBits(uint32_t value)
{
	return value & 0xffff;
}

// Sets bit [0] (enable) for (core_id, thread_id).
static inline void enableInterruptController(int core_id, int thread_id)
{
	uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
	writeInterruptControlRegister(core_id, thread_id, cv | 0x1);
}

// Clears bit [0] (enable) for (core_id, thread_id).
static inline void disableInterruptController(int core_id, int thread_id)
{
	uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
	writeInterruptControlRegister(core_id, thread_id, cv & ~0x1u);
}

// Sets bit [interrupt_id] of the mask. Bit [0] is not touched.
static inline void enableInterrupt(int core_id, int thread_id, int interrupt_id)
{
	uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
	writeInterruptControlRegister(core_id, thread_id, cv | (1u << interrupt_id));
}

// Clears bit [interrupt_id] of the mask. Bit [0] is not touched.
static inline void disableInterrupt(int core_id, int thread_id, int interrupt_id)
{
	uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
	writeInterruptControlRegister(core_id, thread_id, cv & ~(1u << interrupt_id));
}

// Sets all 15 mask bits [15:1]. Bit [0] is not touched.
static inline void enableAllInterrupts(int core_id, int thread_id)
{
	uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
	writeInterruptControlRegister(core_id, thread_id, cv | 0xfffe);
}

// Sets bits [15:0]: enables the slot and every level.
static inline void enableInterruptControllerAndAllInterrupts(int core_id, int thread_id)
{
	writeInterruptControlRegister(core_id, thread_id, 0xffff);
}

// Writes mask[15:1] into the mask bits, leaving bit [0] as it is.
static inline void setInterruptMask(int core_id, int thread_id, uint32_t mask)
{
	uint32_t cv = ajitInterruptControlWritableBits(readInterruptControlRegister(core_id, thread_id));
	cv = (cv & 0x1) | (mask & 0xfffe);
	writeInterruptControlRegister(core_id, thread_id, cv);
}

//------------------------------------------------------------------------
// Interrupt dispatch
//------------------------------------------------------------------------

void (*ajit_global_interrupt_handlers[16])(void);

void ajit_initialize_interrupt_handlers_to_null(void)
{
	int i;
	for (i = 0; i < 16; i++)
		ajit_global_interrupt_handlers[i] = 0;
}

void ajit_set_interrupt_handler(uint32_t interrupt_level, void (*handler)(void))
{
	if (interrupt_level < 16)
		ajit_global_interrupt_handlers[interrupt_level] = handler;
}

// Called by compiler/crt0_interrupts.s on every interrupt trap, with the
// trap-time TBR (its trap type field, bits [11:4], gives the level).
void ajit_generic_interrupt_handler(uint32_t tbr_value)
{
	uint8_t core_id, thread_id;
	ajit_get_core_and_thread_id(&core_id, &thread_id);
	disableInterruptController(core_id, thread_id);

	int error = 1;
	uint32_t trap_type = (tbr_value >> 4) & 0xff;
	if (trap_type >= 0x11 && trap_type <= 0x1f)
	{
		void (*handler)(void) = ajit_global_interrupt_handlers[trap_type - 0x10];
		if (handler)
		{
			handler();
			error = 0;
		}
	}

	enableInterruptController(core_id, thread_id);

	if (error)
		__asm__ __volatile__("ta 0"); //traps are disabled here: the processor halts
}

#endif
