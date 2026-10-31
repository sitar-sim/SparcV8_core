/* sparc.ld
 *
 * Minimal linker script for standalone SPARC V8 test programs.
 *
 * Places .text at address 0 -- matching the SPARC V8 reset convention
 * (PC=0, nPC=4 after reset) -- with .rodata/.data/.bss following
 * immediately after, in the single flat address space modeled by MemCore.
 *
 * __bss_start/__bss_end mark .bss, for startup code that clears it
 * (crt0_multicore.s). Defining them does not move anything.
 */

ENTRY(main)

SECTIONS
{
	. = 0x00000000;
	.text   : { *(.text) *(.text.*) }
	.rodata : { *(.rodata) *(.rodata.*) }
	.data   : { *(.data) *(.data.*) }
	.bss    : { __bss_start = .; *(.bss) *(.bss.*) *(COMMON) __bss_end = .; }

	/DISCARD/ : { *(.comment) *(.note.*) }
}
