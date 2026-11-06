// multicore_platform.h
//
// Devices and the MMU, shared by several cores: a console under a lock, sending and taking
// inter-processor interrupts (IPIs), and TLB shootdown. Include this instead of
// ajit_mt_irc.h, which it includes.
//
// Limits. The locks and the shootdown's shared words are read and written at their physical
// addresses, so with the MMU on the program's data must be identity-mapped. A shootdown
// waits for every other core, so those cores must have called
// tlb_shootdown_start_on_this_core(), must not be halted, and must not hold their interrupts
// off for long. The shootdown installs its own IPI handler, so a program cannot use it
// alongside IPIs of its own. A handler must not send IPIs or start a shootdown.

#ifndef MULTICORE_PLATFORM_H
#define MULTICORE_PLATFORM_H

#include <stdint.h>
#include "multicore_core.h"
#include "multicore_sync.h"
#include "ajit_ipi.h"
#include "ajit_mt_irc.h"

//---------------------------------------------------------------------
// Holding interrupts off
//---------------------------------------------------------------------
// A lock a handler also takes must only be held with interrupts off. Otherwise a handler
// could interrupt the core holding it, and wait for it forever.

#define PSR_PIL_MASK 0xF00u

// Raises the processor interrupt level to 15, and returns the level it replaces.
static inline uint32_t interrupts_off(void)
{
	uint32_t psr, raised;
	__asm__ __volatile__("rd %%psr, %0\n\t"
	                     "or %0, %2, %1\n\t"
	                     "wr %1, %%psr\n\t"
	                     "nop\n\tnop\n\tnop"
	                     : "=&r"(psr), "=&r"(raised)
	                     : "r"(PSR_PIL_MASK)
	                     : "memory");
	return psr & PSR_PIL_MASK;
}

// Restores the level interrupts_off() returned. Only the level changes, since the current
// window and the condition codes are in the same register.
static inline void interrupts_restore(uint32_t level)
{
	uint32_t psr;
	__asm__ __volatile__("rd %%psr, %0\n\t"
	                     "andn %0, %2, %0\n\t"
	                     "or %0, %1, %0\n\t"
	                     "wr %0, %%psr\n\t"
	                     "nop\n\tnop\n\tnop"
	                     : "=&r"(psr)
	                     : "r"(level), "r"(PSR_PIL_MASK)
	                     : "memory", "cc");
}

static inline uint32_t platform_lock(volatile uint8_t* lock)
{
	uint32_t level = interrupts_off();
	acquire_mutex_using_ldstub((int) lock);
	return level;
}

static inline void platform_unlock(volatile uint8_t* lock, uint32_t level)
{
	release_mutex_using_ldstub((int) lock);
	interrupts_restore(level);
}

//---------------------------------------------------------------------
// A console shared by every core
//---------------------------------------------------------------------

static volatile uint8_t console_lock;

// One core calls this once, before any core prints.
static inline void console_start(void)
{
	__ajit_serial_configure_via_bypass__(1, 0, 0);
}

// Prints a string as one piece. Lines from several cores never mix.
static inline void console_puts(const char* s)
{
	uint32_t level = platform_lock(&console_lock);
	__ajit_serial_puts_via_bypass__((char*) s, 0xFFFFFFFFu);
	platform_unlock(&console_lock, level);
}

// Waits until the last character has gone. A run ends when every core has halted, so a
// program calls this before halting, or its last character can be lost.
static inline void console_wait_until_sent(void)
{
	while (__ajit_read_serial_control_register_via_bypass__() & TX_FULL)
		;
}

//---------------------------------------------------------------------
// Inter-processor interrupts
//---------------------------------------------------------------------
// The controller's IPI registers are changed by read-modify-write, so every change is made
// under one lock, including the one in a handler.

static volatile uint8_t ipi_lock;

#define PLATFORM_IPI_BASE ADDR_INTERRUPT_CONTROLLER_IPI_BASE

// Each core calls this once, before any core sends it an IPI.
static inline void ipi_start_on_this_core(void (*handler)(void))
{
	uint32_t id = this_core_id();
	uint32_t level = platform_lock(&ipi_lock);
	ajit_set_interrupt_handler(IPI_IRL, handler);
	__ajit_enable_ipi_interrupt__(PLATFORM_IPI_BASE, id, 0);
	platform_unlock(&ipi_lock, level);
	writeInterruptControlRegister(id, 0, readInterruptControlRegister(id, 0) | (1u << IPI_IRL) | 1u);
}

// Returns 0 if the IPI was sent, or 1 if the destination has one it has not yet taken.
static inline int ipi_try_send(uint32_t destination_core, void* pointer)
{
	uint32_t level = platform_lock(&ipi_lock);
	int busy = __ajit_set_ipi_interrupt__(PLATFORM_IPI_BASE, this_core_id(), 0, destination_core, 0, pointer);
	platform_unlock(&ipi_lock, level);
	return busy;
}

// True while the destination has an IPI it has not yet taken. Reads without the lock.
static inline int ipi_pending(uint32_t destination_core)
{
	uint32_t mask = __ajit_load_word_mmu_bypass__(PLATFORM_IPI_BASE);
	uint32_t vals = __ajit_load_word_mmu_bypass__(PLATFORM_IPI_BASE + 4);
	return (mask & vals & ajitIpiDestinationBit(destination_core, 0)) != 0;
}

// Sends an IPI, waiting while the destination has one it has not yet taken. Interrupts stay
// on while it waits, so two cores sending to each other cannot wait for each other for ever.
// It waits without the lock. The destination's handler needs that lock to clear the IPI, so
// senders that kept taking it could keep the handler out, and wait for it for ever.
static inline void ipi_send(uint32_t destination_core, void* pointer)
{
	do
	{
		while (ipi_pending(destination_core))
			;
	} while (ipi_try_send(destination_core, pointer));
}

// In a handler: returns the sender's pointer, sets *source_core if it is not null, and clears
// the IPI. The message is read first, since another core may write it once the IPI is clear.
static inline void* ipi_receive(uint32_t* source_core)
{
	uint32_t id  = this_core_id();
	uint32_t msg = ajitIpiMessageAddress(PLATFORM_IPI_BASE, id, 0);
	uint32_t ids = __ajit_load_word_mmu_bypass__(msg);
	void* pointer = (void*) __ajit_load_word_mmu_bypass__(msg + 4);
	uint32_t level = platform_lock(&ipi_lock);
	__ajit_clear_ipi_interrupt__(PLATFORM_IPI_BASE, id, 0);
	platform_unlock(&ipi_lock, level);
	if (source_core)
		*source_core = ids >> 24;
	return pointer;
}

//---------------------------------------------------------------------
// The MMU's context and TLB
//---------------------------------------------------------------------

#define PLATFORM_MMU_CONTEXT_REGISTER 0x200u
#define TLB_FLUSH_PAGE   0u
#define TLB_FLUSH_ENTIRE 4u

static inline uint32_t mmu_context(void)
{
	uint32_t context;
	__asm__ __volatile__("lda [%1] 0x04, %0" : "=r"(context) : "r"(PLATFORM_MMU_CONTEXT_REGISTER) : "memory");
	return context;
}

static inline void mmu_set_context(uint32_t context)
{
	__asm__ __volatile__("sta %0, [%1] 0x04" : : "r"(context), "r"(PLATFORM_MMU_CONTEXT_REGISTER) : "memory");
}

// Each of these also empties this core's L1 caches, since a store with ASI 3 does.
static inline void tlb_flush_entire(void)
{
	__asm__ __volatile__("sta %%g0, [%0] 0x03" : : "r"(TLB_FLUSH_ENTIRE << 8) : "memory");
}

// Drops this core's translation of the page at va in the given context.
static inline void tlb_flush_page(uint32_t va, uint32_t context)
{
	uint32_t level = interrupts_off();
	uint32_t current = mmu_context();
	mmu_set_context(context);
	__asm__ __volatile__("sta %%g0, [%0] 0x03" : : "r"((va & 0xFFFFF000u) | (TLB_FLUSH_PAGE << 8)) : "memory");
	mmu_set_context(current);
	interrupts_restore(level);
}

//---------------------------------------------------------------------
// TLB shootdown
//---------------------------------------------------------------------
// A TLB is private to its core, so a core that changes a page table entry must get every
// other core to drop its copy before relying on the change. One shootdown runs at a time.
// Its starter spins with interrupts on, so it can take another core's shootdown while
// waiting for the lock.

#ifndef SHOOTDOWN_WAIT_LIMIT
#define SHOOTDOWN_WAIT_LIMIT 2000000u
#endif

static volatile uint8_t  shootdown_lock;
static volatile uint32_t shootdown_va;
static volatile uint32_t shootdown_context;
static volatile uint32_t shootdown_number;
static volatile uint32_t shootdown_done[MULTICORE_MAX_CORES];

static void tlb_shootdown_ipi_handler(void)
{
	uint32_t number;
	ipi_receive(0);
	tlb_flush_page(read_shared(&shootdown_va), read_shared(&shootdown_context));
	number = read_shared(&shootdown_number);
	__ajit_store_word_mmu_bypass__(number, (uint32_t) &shootdown_done[this_core_id()]);
}

// Each core calls this once, before any core starts a shootdown.
static inline void tlb_shootdown_start_on_this_core(void)
{
	ipi_start_on_this_core(tlb_shootdown_ipi_handler);
}

// Sends a shootdown's IPI. A core still holding an earlier IPI may never take it, so this gives
// up after the wait limit, where ipi_send() would wait for ever. Returns 1 if it was sent.
static inline int tlb_shootdown_send_ipi(uint32_t destination_core)
{
	uint32_t tries;
	for (tries = 0; tries < SHOOTDOWN_WAIT_LIMIT; tries++)
		if (!ipi_pending(destination_core) && !ipi_try_send(destination_core, 0))
			return 1;
	return 0;
}

// Call after changing the page table entry for the page at va in the given context. When it
// returns, no core that answered can use the old translation. Returns the number of cores among
// the first num_cores that did not answer, which is 0 unless one has halted or stopped taking
// interrupts. Such a core can still use the old translation.
static inline uint32_t tlb_shootdown_page(uint32_t va, uint32_t context, uint32_t num_cores)
{
	uint32_t c, tries, number, unanswered = 0, id = this_core_id();
	uint32_t not_sent = 0;

	tlb_flush_page(va, context);

	acquire_mutex_using_ldstub((int) &shootdown_lock);
	number = read_shared(&shootdown_number) + 1;
	__ajit_store_word_mmu_bypass__(va, (uint32_t) &shootdown_va);
	__ajit_store_word_mmu_bypass__(context, (uint32_t) &shootdown_context);
	__ajit_store_word_mmu_bypass__(number, (uint32_t) &shootdown_number);
	for (c = 0; c < num_cores; c++)
		if (c != id && !tlb_shootdown_send_ipi(c))
			not_sent |= 1u << c;
	for (c = 0; c < num_cores; c++)
	{
		if (c == id)
			continue;
		if (not_sent & (1u << c))
		{
			unanswered++;
			continue;
		}
		for (tries = 0; read_shared(&shootdown_done[c]) != number; tries++)
			if (tries >= SHOOTDOWN_WAIT_LIMIT)
			{
				unanswered++;
				break;
			}
	}
	release_mutex_using_ldstub((int) &shootdown_lock);
	return unanswered;
}

#endif
