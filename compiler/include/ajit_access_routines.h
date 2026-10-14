// ajit_access_routines.h
//
// Routines for bare-metal C programs to reach the processor's special
// registers and the peripheral devices: physical (MMU-bypass) loads and
// stores, the core/thread ID, the Timer, and the Serial device.
//
// Function names and signatures follow AJIT's own access routines
// (tools/ajit_access_routines_mt/include/ajit_access_routines.h in the
// ajit-toolchain repo), so code written for AJIT compiles here
// unchanged. The implementation is this project's own, and covers the
// routines for the devices this model implements, plus a few byte-access
// routines AJIT only has as macros.
//
// Everything is defined in this header (static inline), because each
// test program here is compiled as a single C file (Ref
// compiler/compile_c.sh).
//
// All device accesses use the MMU-bypass ASI (0x20), so they reach the
// device's physical address whether or not the MMU is enabled.

#ifndef AJIT_ACCESS_ROUTINES_H
#define AJIT_ACCESS_ROUTINES_H

#include <stdint.h>
#include "device_addresses.h"

#define ASI_MMU_BYPASS 0x20

//------------------------------------------------------------------------
// Physical (MMU-bypass) loads and stores
//------------------------------------------------------------------------

static inline void __ajit_store_word_mmu_bypass__(uint32_t value, uint32_t addr)
{
	__asm__ __volatile__("sta %0, [%1] %2" : : "r"(value), "r"(addr), "i"(ASI_MMU_BYPASS) : "memory");
}

static inline uint32_t __ajit_load_word_mmu_bypass__(uint32_t addr)
{
	uint32_t value;
	__asm__ __volatile__("lda [%1] %2, %0" : "=r"(value) : "r"(addr), "i"(ASI_MMU_BYPASS) : "memory");
	return value;
}

// Byte forms (AJIT provides these as macros only).
static inline void __ajit_store_ubyte_mmu_bypass__(uint8_t value, uint32_t addr)
{
	__asm__ __volatile__("stba %0, [%1] %2" : : "r"(value), "r"(addr), "i"(ASI_MMU_BYPASS) : "memory");
}

static inline uint8_t __ajit_load_ubyte_mmu_bypass__(uint32_t addr)
{
	uint32_t value;
	__asm__ __volatile__("lduba [%1] %2, %0" : "=r"(value) : "r"(addr), "i"(ASI_MMU_BYPASS) : "memory");
	return (uint8_t) value;
}

//------------------------------------------------------------------------
// Core and thread ID
//------------------------------------------------------------------------

// ASR29: (core_id << 8) | thread_id.
static inline uint32_t __ajit_read_core_thread_id_word__(void)
{
	uint32_t value;
	__asm__ __volatile__("rd %%asr29, %0" : "=r"(value));
	return value;
}

static inline void ajit_get_core_and_thread_id(uint8_t* core_id, uint8_t* thread_id)
{
	uint32_t word = __ajit_read_core_thread_id_word__();
	*core_id   = (word >> 8) & 0xff;
	*thread_id = word & 0xff;
}

//------------------------------------------------------------------------
// Timer. Control register: [31:1] max count, [0] enable.
//------------------------------------------------------------------------

static inline void __ajit_write_timer_control_register_via_bypass__(uint32_t val)
{
	__ajit_store_word_mmu_bypass__(val, ADDR_TIMER_CONTROL_REGISTER);
}

static inline uint32_t __ajit_read_timer_control_register_via_bypass__(void)
{
	return __ajit_load_word_mmu_bypass__(ADDR_TIMER_CONTROL_REGISTER);
}

//------------------------------------------------------------------------
// Serial device
//------------------------------------------------------------------------

#define TX_ENABLE   0x1
#define RX_ENABLE   0x2
#define INTR_ENABLE 0x4
#define TX_FULL     0x8
#define RX_FULL     0x10
#define UART_RESET  0x20

static inline void __ajit_write_serial_control_register_via_bypass__(uint32_t val)
{
	__ajit_store_word_mmu_bypass__(val, ADDR_SERIAL_CONTROL_REGISTER);
}

static inline uint32_t __ajit_read_serial_control_register_via_bypass__(void)
{
	return __ajit_load_word_mmu_bypass__(ADDR_SERIAL_CONTROL_REGISTER);
}

static inline void __ajit_write_serial_tx_register_via_bypass__(uint8_t val)
{
	__ajit_store_ubyte_mmu_bypass__(val, ADDR_SERIAL_TX_REGISTER);
}

// Tx is write-only. Kept for compatibility, always reads 0 here.
static inline uint8_t __ajit_read_serial_tx_register_via_bypass__(void)
{
	return __ajit_load_ubyte_mmu_bypass__(ADDR_SERIAL_TX_REGISTER);
}

static inline uint8_t __ajit_read_serial_rx_register_via_bypass__(void)
{
	return __ajit_load_ubyte_mmu_bypass__(ADDR_SERIAL_RX_REGISTER);
}

static inline void __ajit_write_serial_baud_limit_register_via_bypass__(uint32_t bcv)
{
	__ajit_store_word_mmu_bypass__(bcv, ADDR_SERIAL_BAUD_LIMIT_REGISTER);
}

static inline uint32_t __ajit_read_serial_baud_limit_register_via_bypass__(void)
{
	return __ajit_load_word_mmu_bypass__(ADDR_SERIAL_BAUD_LIMIT_REGISTER);
}

static inline void __ajit_write_serial_baud_frequency_register_via_bypass__(uint32_t bcv)
{
	__ajit_store_word_mmu_bypass__(bcv, ADDR_SERIAL_BAUD_FREQUENCY_REGISTER);
}

static inline uint32_t __ajit_read_serial_baud_frequency_register_via_bypass__(void)
{
	return __ajit_load_word_mmu_bypass__(ADDR_SERIAL_BAUD_FREQUENCY_REGISTER);
}

// Sets the Tx enable, Rx enable, and Rx interrupt enable bits, leaving
// the rest of the Control register as read.
static inline void __ajit_serial_configure_via_bypass__(uint8_t enable_tx, uint8_t enable_rx, uint8_t enable_intr)
{
	uint32_t cval = __ajit_read_serial_control_register_via_bypass__();
	cval = enable_tx   ? (cval | TX_ENABLE)   : (cval & ~TX_ENABLE);
	cval = enable_rx   ? (cval | RX_ENABLE)   : (cval & ~RX_ENABLE);
	cval = enable_intr ? (cval | INTR_ENABLE) : (cval & ~INTR_ENABLE);
	__ajit_write_serial_control_register_via_bypass__(cval);
}

static inline void __ajit_serial_set_uart_reset_via_bypass__(uint8_t reset_value)
{
	uint32_t cval = __ajit_read_serial_control_register_via_bypass__();
	cval = reset_value ? (cval | UART_RESET) : (cval & ~UART_RESET);
	__ajit_write_serial_control_register_via_bypass__(cval);
}

// Computes and writes the baud limit and baud frequency registers for
// the given baud rate and clock frequency (Ref the Serial Device page's
// "Baud rate" section). The model stores them, but its transmit timing
// is set by the model's own txTicksPerByte knob, not by these values.
static inline void __ajit_serial_set_baudrate_via_bypass__(uint32_t baud_rate, uint32_t clock_frequency)
{
	uint32_t a = 16 * baud_rate, b = clock_frequency;
	while (b != 0) { uint32_t t = a % b; a = b; b = t; }
	uint32_t gcd = a ? a : 1;
	uint32_t baud_frequency = (16 * baud_rate) / gcd;
	uint32_t baud_limit     = (clock_frequency / gcd) - baud_frequency;
	__ajit_write_serial_baud_limit_register_via_bypass__(baud_limit);
	__ajit_write_serial_baud_frequency_register_via_bypass__(baud_frequency);
}

// Returns 1 if the character was handed to the transmitter, 0 if the
// transmitter is disabled or still busy (Tx_full set). Does not wait.
static inline int __ajit_serial_putchar_via_bypass__(char c)
{
	uint32_t ctrl = __ajit_read_serial_control_register_via_bypass__();
	if ((ctrl & TX_ENABLE) && !(ctrl & TX_FULL))
	{
		__ajit_write_serial_tx_register_via_bypass__((uint8_t) c);
		return 1;
	}
	return 0;
}

// Waits for a received character and returns it. Can wait forever if
// the receiver is disabled or nothing arrives.
static inline int __ajit_serial_getchar_via_bypass__(void)
{
	while (!(__ajit_read_serial_control_register_via_bypass__() & RX_FULL))
		;
	return (char) __ajit_read_serial_rx_register_via_bypass__();
}

// Sends `length` characters (or up to a terminating 0), waiting for the
// transmitter between characters.
static inline void __ajit_serial_puts_via_bypass__(char* s, uint32_t length)
{
	uint32_t i;
	for (i = 0; i < length && s[i] != 0; i++)
		while (!__ajit_serial_putchar_via_bypass__(s[i]))
			;
}

// Reads at most `length` characters, stopping after a 0 character (which
// is stored).
static inline void __ajit_serial_gets_via_bypass__(char* s, uint32_t length)
{
	uint32_t i;
	for (i = 0; i < length; i++)
	{
		s[i] = (char) __ajit_serial_getchar_via_bypass__();
		if (s[i] == 0)
			break;
	}
}

#endif
