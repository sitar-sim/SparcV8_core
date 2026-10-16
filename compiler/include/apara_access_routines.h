// apara_access_routines.h
// Original author: Madhav Desai, IITB
// Model Author: Claude Opus 5.5 (high)
// This model code was adapted from the APARA engine specification and
// reference C implementation developed by Prof. Madhav Desai, IITB
//
// Routines for a bare-metal SPARC C program to use an APARA engine: load
// its program, set and read its threads' registers, run them and learn
// when they stop (by polling, or by the engine interrupt, IRL 14), move
// data with its DMA unit, and read and write its data memory directly.
//
// Our own design, in the style of ajit_access_routines.h (AJIT has no
// engine routines). The registers they use are the engine's control unit
// (CCU) and DMA unit, at the addresses of the system's AJIT_APARA layout
// (Ref docs/source/apara/system.md for the registers, and
// model/cpp_common_code/apara/AparaControlCore.h, AparaDmaCore.h). Every
// access uses the MMU-bypass ASI, so it reaches the physical address,
// uncached, whether or not the MMU is enabled.
//
// The engine is engine 0 of cluster 0 unless APARA_CLUSTER / APARA_ENGINE
// are defined before this header.
//
// Everything is static inline, for single-file test programs.

#ifndef APARA_ACCESS_ROUTINES_H
#define APARA_ACCESS_ROUTINES_H

#include <stdint.h>
#include "ajit_access_routines.h"

#ifndef APARA_CLUSTER
#define APARA_CLUSTER 0
#endif
#ifndef APARA_ENGINE
#define APARA_ENGINE 0
#endif

#define APARA_DMEM_BASE (0x01000000u + APARA_CLUSTER * 0x40000u + APARA_ENGINE * 0x10000u)
#define APARA_CCU_BASE  (0xFFFE0000u + APARA_CLUSTER * 0x200u + APARA_ENGINE * 0x80u)
#define APARA_DMA_BASE  (0xFFFE2000u + APARA_CLUSTER * 0x200u + APARA_ENGINE * 0x80u)
#define APARA_DMEM_BYTES 0x10000u

// CCU commands and flags (R0: [31:16] sequence, [11:8] command, [7:0] flags).
#define APARA_CMD_READ_IMEM       1
#define APARA_CMD_WRITE_IMEM      2
#define APARA_CMD_RESET_THREAD    3
#define APARA_CMD_RUN_THREAD      4
#define APARA_CMD_READ_REGISTER   5
#define APARA_CMD_WRITE_REGISTER  6
#define APARA_CMD_COMPLETION      7
#define APARA_CMD_STEP            8
#define APARA_CMD_READ_RAS_STATE  9
#define APARA_CMD_READ_TIMER      10

#define APARA_FLAG_START            (1u << 0)
#define APARA_FLAG_STARTED          (1u << 1)
#define APARA_FLAG_COMPLETED        (1u << 2)
#define APARA_FLAG_INTERRUPT_ENABLE (1u << 3)
#define APARA_FLAG_RUN_INTERPRETER  (1u << 4)

// A thread's completion word (CCU R5), and its ERROR bits.
#define APARA_COMPLETION_VALID (1u << 31)
#define APARA_ERROR_RAS        (1u << 26)
#define APARA_ERROR_HALT       (1u << 25)
#define APARA_ERROR_EXCEPTION  (1u << 24)
#define APARA_ERROR_CODE(word, slot) (((word) >> (3 * (slot))) & 7u)

// DMA operations and flags (R0: [31:24] operation, [23:20] and [19:16]
// the top address bits, [15:8] sequence, [7:0] flags).
#define APARA_DMA_LOAD  1  // system memory to DMEM
#define APARA_DMA_STORE 2  // DMEM to system memory
#define APARA_DMA_FLAG_SCHEDULED        (1u << 0)
#define APARA_DMA_FLAG_STARTED          (1u << 1)
#define APARA_DMA_FLAG_COMPLETED        (1u << 2)
#define APARA_DMA_FLAG_INTERRUPT_ENABLE (1u << 3)
#define APARA_DMA_FLAG_ERROR            (1u << 4)

//------------------------------------------------------------------------
// Registers
//------------------------------------------------------------------------

static inline uint32_t apara_ccu_read(uint32_t thread, uint32_t reg)
{
	return __ajit_load_word_mmu_bypass__(APARA_CCU_BASE + 32 * thread + 4 * reg);
}

static inline void apara_ccu_write(uint32_t thread, uint32_t reg, uint32_t value)
{
	__ajit_store_word_mmu_bypass__(value, APARA_CCU_BASE + 32 * thread + 4 * reg);
}

static inline uint32_t apara_dma_read(uint32_t channel, uint32_t reg)
{
	return __ajit_load_word_mmu_bypass__(APARA_DMA_BASE + 32 * channel + 4 * reg);
}

static inline void apara_dma_write(uint32_t channel, uint32_t reg, uint32_t value)
{
	__ajit_store_word_mmu_bypass__(value, APARA_DMA_BASE + 32 * channel + 4 * reg);
}

//------------------------------------------------------------------------
// CCU commands: each thread has its own CCU registers and command.
//------------------------------------------------------------------------

// Start a command (with extra R0 flags) without waiting for it.
static inline void apara_ccu_start_command(uint32_t thread, uint32_t command, uint32_t flags)
{
	apara_ccu_write(thread, 0, (command << 8) | APARA_FLAG_START | APARA_FLAG_RUN_INTERPRETER | flags);
}

static inline int apara_ccu_command_done(uint32_t thread)
{
	return (apara_ccu_read(thread, 0) & APARA_FLAG_COMPLETED) != 0;
}

// Run a command and wait for it.
static inline void apara_ccu_command(uint32_t thread, uint32_t command)
{
	apara_ccu_start_command(thread, command, 0);
	while (!apara_ccu_command_done(thread))
		;
}

//------------------------------------------------------------------------
// IMEM (shared by the threads; written through thread 0's CCU)
//------------------------------------------------------------------------

static inline void apara_write_imem(uint32_t index, uint32_t word)
{
	apara_ccu_write(0, 2, index);
	apara_ccu_write(0, 3, word);
	apara_ccu_command(0, APARA_CMD_WRITE_IMEM);
}

static inline uint32_t apara_read_imem(uint32_t index)
{
	apara_ccu_write(0, 2, index);
	apara_ccu_command(0, APARA_CMD_READ_IMEM);
	return apara_ccu_read(0, 4);
}

// IMEM words 0 .. n-1 (Ref compiler/apara/apara_obj_to_c.py).
static inline void apara_load_program(const uint32_t* words, uint32_t n)
{
	uint32_t i;
	for (i = 0; i < n; i++)
		apara_write_imem(i, words[i]);
}

//------------------------------------------------------------------------
// Threads
//------------------------------------------------------------------------

static inline void apara_write_thread_register(uint32_t thread, uint32_t reg, uint64_t value)
{
	apara_ccu_write(thread, 2, reg);
	apara_ccu_write(thread, 6, (uint32_t) (value >> 32));
	apara_ccu_write(thread, 7, (uint32_t) value);
	apara_ccu_command(thread, APARA_CMD_WRITE_REGISTER);
}

static inline uint64_t apara_read_thread_register(uint32_t thread, uint32_t reg)
{
	apara_ccu_write(thread, 2, reg);
	apara_ccu_command(thread, APARA_CMD_READ_REGISTER);
	return ((uint64_t) apara_ccu_read(thread, 6) << 32) | apara_ccu_read(thread, 7);
}

// Start a thread at pc (an IMEM word index). Its registers are kept.
static inline void apara_start_thread(uint32_t thread, uint32_t pc)
{
	apara_ccu_write(thread, 1, pc);
	apara_ccu_command(thread, APARA_CMD_RUN_THREAD);
}

// Stop a thread: inactive, PC 0, return-address stack and ERROR cleared.
static inline void apara_reset_thread(uint32_t thread)
{
	apara_ccu_command(thread, APARA_CMD_RESET_THREAD);
}

// The thread's completion word: APARA_COMPLETION_VALID and its ERROR once
// it has stopped (each stop is reported once), else 0.
static inline uint32_t apara_poll_thread(uint32_t thread)
{
	apara_ccu_command(thread, APARA_CMD_COMPLETION);
	return apara_ccu_read(thread, 5);
}

// Wait (polling) until the thread stops; its completion word.
static inline uint32_t apara_wait_thread(uint32_t thread)
{
	uint32_t w;
	while (!((w = apara_poll_thread(thread)) & APARA_COMPLETION_VALID))
		;
	return w;
}

// Where a stopped thread stopped (after a completion with the valid bit).
static inline uint32_t apara_thread_stop_pc(uint32_t thread)
{
	return apara_ccu_read(thread, 6);
}

// Ask for the engine interrupt (IRL 14) when the thread stops. The
// command completes then; apara_ccu_command_done() tells, and R5 holds
// the completion word (apara_thread_completion()).
static inline void apara_request_completion_interrupt(uint32_t thread)
{
	apara_ccu_start_command(thread, APARA_CMD_COMPLETION, APARA_FLAG_INTERRUPT_ENABLE);
}

static inline uint32_t apara_thread_completion(uint32_t thread)
{
	return apara_ccu_read(thread, 5);
}

// Clear the CCU's interrupt (call in the IRL 14 handler).
static inline void apara_clear_interrupt(uint32_t thread)
{
	apara_ccu_write(thread, 0, APARA_FLAG_RUN_INTERPRETER);
}

// The engine's cycle counter.
static inline uint64_t apara_read_timer(void)
{
	apara_ccu_command(0, APARA_CMD_READ_TIMER);
	return ((uint64_t) apara_ccu_read(0, 3) << 32) | apara_ccu_read(0, 4);
}

//------------------------------------------------------------------------
// DMEM, directly (the window: DMEM byte offset o at APARA_DMEM_BASE + o)
//------------------------------------------------------------------------

static inline void apara_dmem_write_word(uint32_t offset, uint32_t value)
{
	__ajit_store_word_mmu_bypass__(value, APARA_DMEM_BASE + offset);
}

static inline uint32_t apara_dmem_read_word(uint32_t offset)
{
	return __ajit_load_word_mmu_bypass__(APARA_DMEM_BASE + offset);
}

// The DMEM words a C engine program's initialized globals need: the
// (offset, value) pairs apara_obj_to_c.py writes as <name>_dmem_image[],
// <NAME>_DMEM_IMAGE_WORDS of them.
static inline void apara_load_dmem_image(const uint32_t* pairs, uint32_t n)
{
	uint32_t i;
	for (i = 0; i < n; i++)
		apara_dmem_write_word(pairs[2 * i], pairs[2 * i + 1]);
}

// A 64-bit DMEM word (big-endian: the high half at the lower address).
static inline uint64_t apara_dmem_read_dword(uint32_t offset)
{
	return ((uint64_t) apara_dmem_read_word(offset) << 32) | apara_dmem_read_word(offset + 4);
}

//------------------------------------------------------------------------
// DMA
//------------------------------------------------------------------------

// Start channel `channel`: `bursts` bursts of `bytes_per_burst` bytes.
// A load gathers (source bursts `gap` bytes apart, packed in DMEM), a
// store scatters (packed in DMEM, destination bursts `gap` apart). The
// DMEM side is a DMEM byte offset, the other a physical address.
static inline void apara_dma_start(uint32_t channel, uint32_t operation, uint32_t source, uint32_t destination,
                                   uint32_t bursts, uint32_t gap, uint32_t bytes_per_burst, uint32_t interrupt_enable)
{
	apara_dma_write(channel, 1, source);
	apara_dma_write(channel, 2, destination);
	apara_dma_write(channel, 3, bursts * bytes_per_burst);
	apara_dma_write(channel, 4, bursts);
	apara_dma_write(channel, 5, gap);
	apara_dma_write(channel, 6, bytes_per_burst);
	apara_dma_write(channel, 0, (operation << 24) | APARA_DMA_FLAG_SCHEDULED
	                            | (interrupt_enable ? APARA_DMA_FLAG_INTERRUPT_ENABLE : 0));
}

static inline int apara_dma_done(uint32_t channel)
{
	return (apara_dma_read(channel, 0) & APARA_DMA_FLAG_COMPLETED) != 0;
}

// Wait for the channel; its control word (APARA_DMA_FLAG_ERROR if it failed).
static inline uint32_t apara_dma_wait(uint32_t channel)
{
	while (!apara_dma_done(channel))
		;
	return apara_dma_read(channel, 0);
}

// One contiguous copy each way, waiting for it.
static inline uint32_t apara_dma_load(uint32_t channel, uint32_t dmem_offset, uint32_t source, uint32_t bytes)
{
	apara_dma_start(channel, APARA_DMA_LOAD, source, dmem_offset, 1, 0, bytes, 0);
	return apara_dma_wait(channel);
}

static inline uint32_t apara_dma_store(uint32_t channel, uint32_t destination, uint32_t dmem_offset, uint32_t bytes)
{
	apara_dma_start(channel, APARA_DMA_STORE, dmem_offset, destination, 1, 0, bytes, 0);
	return apara_dma_wait(channel);
}

// Clear the DMA interrupt (call in the IRL 14 handler).
static inline void apara_dma_clear_interrupt(uint32_t channel)
{
	apara_dma_write(channel, 0, 0);
}

#endif
