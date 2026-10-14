// ajit_ipi.h
//
// Routines for inter-processor interrupts (IPI) through the Interrupt
// Controller's IPI registers, at ADDR_INTERRUPT_CONTROLLER_IPI_BASE:
//
//   word 0          IPI mask,  bit t for destination thread t = 2*core + thread
//   word 1          IPI value, bit t for destination thread t
//   words 2..17     8 bytes of software message per destination thread
//   word 18 (+72)   a lock word, for software
//
// Destination thread t sees an IPI (IRL 11) while bit t is set in both
// the mask and the value. Locking is the caller's responsibility, as in
// AJIT.
//
// Function names, signatures, and return values follow AJIT's own
// ajit_ipi.h / ajit_ipi.c (tools/ajit_access_routines_mt/ in the
// ajit-toolchain repo). The implementation is this project's own, and
// reaches the registers through MMU-bypass accesses rather than plain
// pointers, so it works whether or not the MMU is enabled.

#ifndef AJIT_IPI_H
#define AJIT_IPI_H

#include <stdint.h>
#include "device_addresses.h"
#include "ajit_access_routines.h"

#define __AJIT_IPI_LOCK_ADDRESS(x) (x + 72)

typedef struct __IpiMessage {
	uint8_t source_core_id;
	uint8_t source_thread_id;
	uint8_t dest_core_id;
	uint8_t dest_thread_id;
	void*   pointer;
} IpiMessage;

static inline uint32_t ajitIpiDestinationBit(uint8_t dest_core_id, uint8_t dest_thread_id)
{
	return 1u << ((2 * dest_core_id) + dest_thread_id);
}

// Address of the destination thread's 8-byte message area.
static inline uint32_t ajitIpiMessageAddress(uint32_t ipi_base_address, uint8_t dest_core_id, uint8_t dest_thread_id)
{
	return ipi_base_address + 8 + 8 * ((2 * dest_core_id) + dest_thread_id);
}

// Fills the destination's message and sets its IPI value bit. Returns 0
// on success, 1 if an IPI is already pending for that destination (mask
// and value both set).
static inline int __ajit_set_ipi_interrupt__(uint32_t ipi_base_address,
                                             uint8_t source_core_id, uint8_t source_thread_id,
                                             uint8_t dest_core_id, uint8_t dest_thread_id,
                                             void* ptr)
{
	uint32_t bit  = ajitIpiDestinationBit(dest_core_id, dest_thread_id);
	uint32_t mask = __ajit_load_word_mmu_bypass__(ipi_base_address);
	uint32_t vals = __ajit_load_word_mmu_bypass__(ipi_base_address + 4);

	uint32_t msg = ajitIpiMessageAddress(ipi_base_address, dest_core_id, dest_thread_id);
	uint32_t ids = ((uint32_t) source_core_id << 24) | ((uint32_t) source_thread_id << 16)
	             | ((uint32_t) dest_core_id << 8)    | (uint32_t) dest_thread_id;
	__ajit_store_word_mmu_bypass__(ids, msg);
	__ajit_store_word_mmu_bypass__((uint32_t) ptr, msg + 4);

	if (vals & mask & bit)
		return 1;
	__ajit_store_word_mmu_bypass__(vals | bit, ipi_base_address + 4);
	return 0;
}

// Clears the destination's IPI value bit. Returns 0 on success, 1 if
// that destination's IPI mask bit was not set.
static inline int __ajit_clear_ipi_interrupt__(uint32_t ipi_base_address, uint8_t dest_core_id, uint8_t dest_thread_id)
{
	uint32_t bit  = ajitIpiDestinationBit(dest_core_id, dest_thread_id);
	uint32_t mask = __ajit_load_word_mmu_bypass__(ipi_base_address);
	uint32_t vals = __ajit_load_word_mmu_bypass__(ipi_base_address + 4);
	__ajit_store_word_mmu_bypass__(vals & ~bit, ipi_base_address + 4);
	return (mask & bit) ? 0 : 1;
}

// Sets the destination's IPI mask bit. Returns 0 on success, 1 if it was
// already set.
static inline int __ajit_enable_ipi_interrupt__(uint32_t ipi_base_address, uint8_t dest_core_id, uint8_t dest_thread_id)
{
	uint32_t bit  = ajitIpiDestinationBit(dest_core_id, dest_thread_id);
	uint32_t mask = __ajit_load_word_mmu_bypass__(ipi_base_address);
	if (mask & bit)
		return 1;
	__ajit_store_word_mmu_bypass__(mask | bit, ipi_base_address);
	return 0;
}

// Clears the destination's IPI mask bit. Returns 0 on success, 1 if it
// was already clear.
static inline int __ajit_disable_ipi_interrupt__(uint32_t ipi_base_address, uint8_t dest_core_id, uint8_t dest_thread_id)
{
	uint32_t bit  = ajitIpiDestinationBit(dest_core_id, dest_thread_id);
	uint32_t mask = __ajit_load_word_mmu_bypass__(ipi_base_address);
	if (!(mask & bit))
		return 1;
	__ajit_store_word_mmu_bypass__(mask & ~bit, ipi_base_address);
	return 0;
}

#endif
