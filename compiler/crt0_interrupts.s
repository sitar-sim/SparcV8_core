! crt0_interrupts.s
!
! Startup stub for bare-metal C programs that take interrupts. Based on
! crt0.s (read that file's own header comment first), with three
! additions, all standard SPARC V8 trap machinery:
!
! 1. Register-window overflow and underflow handling. crt0.s leaves WIM
!    at 0 and has no window trap handlers, which is fine as long as calls
!    never nest deeper than the 8 register windows. An interrupt handler
!    runs on top of whatever was interrupted, so here WIM starts with one
!    invalid window (window 1) and window_overflow/window_underflow traps
!    (types 0x05/0x06) spill and refill windows to and from the stack.
!
! 2. Interrupts. The 15 interrupt trap entries (types 0x11..0x1F,
!    levels 1..15) jump to interrupt_trap_entry below, which calls the C
!    function
!
!        void ajit_generic_interrupt_handler(uint32_t tbr_value);
!
!    defined in compiler/include/ajit_mt_irc.h, AJIT's own dispatch
!    scheme: it looks up and calls the handler registered for the level.
!    The handler runs with traps enabled (so window traps can happen
!    inside it) but with PIL raised to 15, so no further maskable
!    interrupt is taken until it returns.
!
! 3. interrupt_trap_entry also keeps the window invariants a trap
!    handler must keep: if the trap window is the invalid window, it
!    spills the next window before calling C, and before returning it
!    refills the interrupted window if that one was spilled meanwhile
!    (RETT into an invalid window is not allowed).
!
! Every other trap still halts exactly as in crt0.s. A test selects this
! file instead of crt0.s with a `STARTUP = crt0_interrupts.s` line in
! its .vprj (Ref validation/build_hex.py).

.global _start
.global main

_start:
	nop
	nop

	! Enable traps: set PSR with ET=1, PS=1, S=1, all other fields=0
	mov 0xE0, %l0
	wr %l0, %psr
	nop	! insert nops here because
	nop	! writes to psr may be delayed
	nop

	! One invalid window: CWP is now 0, so mark window 1 invalid (the
	! standard choice, Ref this file's header comment).
	wr %g0, 0x2, %wim
	nop
	nop
	nop

	! Store base of trap table in TBR register
	set trap_table_base, %l0
	wr %l0, 0x0, %tbr
	nop	! insert nops here because
	nop	! writes to tbr may be delayed
	nop

	! Initialize the stack. STACK_TOP is comfortably inside the model's
	! 256MB memory (see MemCore.h), with plenty of headroom below it for
	! the stack to grow down into.
	set 0x0ffffff0, %sp

	! Initialize g1. Upon a trap, g1 should be
	! overwritten by the trap number
	mov 0xBAD, %g1

	call main
	nop			! delay slot

	!======================================
	! control should NOT reach here: main() must never return (see
	! writing_and_running_c_programs.md)
not_reached:
	set 0xDEAD, %g1
	ta 0
	nop
	nop

	!====================================
	! TRAP TABLE
	!====================================
	!NOTE: the trap table has to be aligned on 2^12 = 4096 bytes
	!because wr tbr instruction copies bits
	!31:12 of the result only into tbr register

	.align 4096

trap_table_base:
	! The trap handler for each trap does the following:
	!	- store the trap number in g1
	!	- do a restore operation so that we
	!	  go back to the original window
	!	- ta 0 (cause a trap in trap to go into ERROR mode)

hardware_trap_table_base:

HW_trap_0x00: mov 0x00, %g1; restore; ta 0; nop
HW_trap_0x01: mov 0x01, %g1; restore; ta 0; nop
HW_trap_0x02: mov 0x02, %g1; restore; ta 0; nop
HW_trap_0x03: mov 0x03, %g1; restore; ta 0; nop
HW_trap_0x04: mov 0x04, %g1; restore; ta 0; nop
HW_trap_0x05: rd %wim, %l3; ba window_overflow_handler; nop; nop
HW_trap_0x06: rd %wim, %l3; ba window_underflow_handler; nop; nop
HW_trap_0x07: mov 0x07, %g1; restore; ta 0; nop
HW_trap_0x08: mov 0x08, %g1; restore; ta 0; nop
HW_trap_0x09: mov 0x09, %g1; restore; ta 0; nop
HW_trap_0x0a: mov 0x0a, %g1; restore; ta 0; nop
HW_trap_0x0b: mov 0x0b, %g1; restore; ta 0; nop
HW_trap_0x0c: mov 0x0c, %g1; restore; ta 0; nop
HW_trap_0x0d: mov 0x0d, %g1; restore; ta 0; nop
HW_trap_0x0e: mov 0x0e, %g1; restore; ta 0; nop
HW_trap_0x0f: mov 0x0f, %g1; restore; ta 0; nop
HW_trap_0x10: mov 0x10, %g1; restore; ta 0; nop
HW_trap_0x11: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x12: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x13: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x14: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x15: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x16: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x17: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x18: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x19: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x1a: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x1b: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x1c: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x1d: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x1e: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x1f: rd %psr, %l0; ba interrupt_trap_entry; nop; nop
HW_trap_0x20: mov 0x20, %g1; restore; ta 0; nop
HW_trap_0x21: mov 0x21, %g1; restore; ta 0; nop
HW_trap_0x22: mov 0x22, %g1; restore; ta 0; nop
HW_trap_0x23: mov 0x23, %g1; restore; ta 0; nop
HW_trap_0x24: mov 0x24, %g1; restore; ta 0; nop
HW_trap_0x25: mov 0x25, %g1; restore; ta 0; nop
HW_trap_0x26: mov 0x26, %g1; restore; ta 0; nop
HW_trap_0x27: mov 0x27, %g1; restore; ta 0; nop
HW_trap_0x28: mov 0x28, %g1; restore; ta 0; nop
HW_trap_0x29: mov 0x29, %g1; restore; ta 0; nop
HW_trap_0x2a: mov 0x2a, %g1; restore; ta 0; nop
HW_trap_0x2b: mov 0x2b, %g1; restore; ta 0; nop
HW_trap_0x2c: mov 0x2c, %g1; restore; ta 0; nop
HW_trap_0x2d: mov 0x2d, %g1; restore; ta 0; nop
HW_trap_0x2e: mov 0x2e, %g1; restore; ta 0; nop
HW_trap_0x2f: mov 0x2f, %g1; restore; ta 0; nop
HW_trap_0x30: mov 0x30, %g1; restore; ta 0; nop
HW_trap_0x31: mov 0x31, %g1; restore; ta 0; nop
HW_trap_0x32: mov 0x32, %g1; restore; ta 0; nop
HW_trap_0x33: mov 0x33, %g1; restore; ta 0; nop
HW_trap_0x34: mov 0x34, %g1; restore; ta 0; nop
HW_trap_0x35: mov 0x35, %g1; restore; ta 0; nop
HW_trap_0x36: mov 0x36, %g1; restore; ta 0; nop
HW_trap_0x37: mov 0x37, %g1; restore; ta 0; nop
HW_trap_0x38: mov 0x38, %g1; restore; ta 0; nop
HW_trap_0x39: mov 0x39, %g1; restore; ta 0; nop
HW_trap_0x3a: mov 0x3a, %g1; restore; ta 0; nop
HW_trap_0x3b: mov 0x3b, %g1; restore; ta 0; nop
HW_trap_0x3c: mov 0x3c, %g1; restore; ta 0; nop
HW_trap_0x3d: mov 0x3d, %g1; restore; ta 0; nop
HW_trap_0x3e: mov 0x3e, %g1; restore; ta 0; nop
HW_trap_0x3f: mov 0x3f, %g1; restore; ta 0; nop
HW_trap_0x40: mov 0x40, %g1; restore; ta 0; nop
HW_trap_0x41: mov 0x41, %g1; restore; ta 0; nop
HW_trap_0x42: mov 0x42, %g1; restore; ta 0; nop
HW_trap_0x43: mov 0x43, %g1; restore; ta 0; nop
HW_trap_0x44: mov 0x44, %g1; restore; ta 0; nop
HW_trap_0x45: mov 0x45, %g1; restore; ta 0; nop
HW_trap_0x46: mov 0x46, %g1; restore; ta 0; nop
HW_trap_0x47: mov 0x47, %g1; restore; ta 0; nop
HW_trap_0x48: mov 0x48, %g1; restore; ta 0; nop
HW_trap_0x49: mov 0x49, %g1; restore; ta 0; nop
HW_trap_0x4a: mov 0x4a, %g1; restore; ta 0; nop
HW_trap_0x4b: mov 0x4b, %g1; restore; ta 0; nop
HW_trap_0x4c: mov 0x4c, %g1; restore; ta 0; nop
HW_trap_0x4d: mov 0x4d, %g1; restore; ta 0; nop
HW_trap_0x4e: mov 0x4e, %g1; restore; ta 0; nop
HW_trap_0x4f: mov 0x4f, %g1; restore; ta 0; nop
HW_trap_0x50: mov 0x50, %g1; restore; ta 0; nop
HW_trap_0x51: mov 0x51, %g1; restore; ta 0; nop
HW_trap_0x52: mov 0x52, %g1; restore; ta 0; nop
HW_trap_0x53: mov 0x53, %g1; restore; ta 0; nop
HW_trap_0x54: mov 0x54, %g1; restore; ta 0; nop
HW_trap_0x55: mov 0x55, %g1; restore; ta 0; nop
HW_trap_0x56: mov 0x56, %g1; restore; ta 0; nop
HW_trap_0x57: mov 0x57, %g1; restore; ta 0; nop
HW_trap_0x58: mov 0x58, %g1; restore; ta 0; nop
HW_trap_0x59: mov 0x59, %g1; restore; ta 0; nop
HW_trap_0x5a: mov 0x5a, %g1; restore; ta 0; nop
HW_trap_0x5b: mov 0x5b, %g1; restore; ta 0; nop
HW_trap_0x5c: mov 0x5c, %g1; restore; ta 0; nop
HW_trap_0x5d: mov 0x5d, %g1; restore; ta 0; nop
HW_trap_0x5e: mov 0x5e, %g1; restore; ta 0; nop
HW_trap_0x5f: mov 0x5f, %g1; restore; ta 0; nop
HW_trap_0x60: mov 0x60, %g1; restore; ta 0; nop
HW_trap_0x61: mov 0x61, %g1; restore; ta 0; nop
HW_trap_0x62: mov 0x62, %g1; restore; ta 0; nop
HW_trap_0x63: mov 0x63, %g1; restore; ta 0; nop
HW_trap_0x64: mov 0x64, %g1; restore; ta 0; nop
HW_trap_0x65: mov 0x65, %g1; restore; ta 0; nop
HW_trap_0x66: mov 0x66, %g1; restore; ta 0; nop
HW_trap_0x67: mov 0x67, %g1; restore; ta 0; nop
HW_trap_0x68: mov 0x68, %g1; restore; ta 0; nop
HW_trap_0x69: mov 0x69, %g1; restore; ta 0; nop
HW_trap_0x6a: mov 0x6a, %g1; restore; ta 0; nop
HW_trap_0x6b: mov 0x6b, %g1; restore; ta 0; nop
HW_trap_0x6c: mov 0x6c, %g1; restore; ta 0; nop
HW_trap_0x6d: mov 0x6d, %g1; restore; ta 0; nop
HW_trap_0x6e: mov 0x6e, %g1; restore; ta 0; nop
HW_trap_0x6f: mov 0x6f, %g1; restore; ta 0; nop
HW_trap_0x70: mov 0x70, %g1; restore; ta 0; nop
HW_trap_0x71: mov 0x71, %g1; restore; ta 0; nop
HW_trap_0x72: mov 0x72, %g1; restore; ta 0; nop
HW_trap_0x73: mov 0x73, %g1; restore; ta 0; nop
HW_trap_0x74: mov 0x74, %g1; restore; ta 0; nop
HW_trap_0x75: mov 0x75, %g1; restore; ta 0; nop
HW_trap_0x76: mov 0x76, %g1; restore; ta 0; nop
HW_trap_0x77: mov 0x77, %g1; restore; ta 0; nop
HW_trap_0x78: mov 0x78, %g1; restore; ta 0; nop
HW_trap_0x79: mov 0x79, %g1; restore; ta 0; nop
HW_trap_0x7a: mov 0x7a, %g1; restore; ta 0; nop
HW_trap_0x7b: mov 0x7b, %g1; restore; ta 0; nop
HW_trap_0x7c: mov 0x7c, %g1; restore; ta 0; nop
HW_trap_0x7d: mov 0x7d, %g1; restore; ta 0; nop
HW_trap_0x7e: mov 0x7e, %g1; restore; ta 0; nop
HW_trap_0x7f: mov 0x7f, %g1; restore; ta 0; nop
software_trap_table_base:
SW_trap_0x80: mov 0x80, %g1; restore; ta 0; nop
SW_trap_0x81: mov 0x81, %g1; restore; ta 0; nop
SW_trap_0x82: mov 0x82, %g1; restore; ta 0; nop
SW_trap_0x83: mov 0x83, %g1; restore; ta 0; nop
SW_trap_0x84: mov 0x84, %g1; restore; ta 0; nop
SW_trap_0x85: mov 0x85, %g1; restore; ta 0; nop
SW_trap_0x86: mov 0x86, %g1; restore; ta 0; nop
SW_trap_0x87: mov 0x87, %g1; restore; ta 0; nop
SW_trap_0x88: mov 0x88, %g1; restore; ta 0; nop
SW_trap_0x89: mov 0x89, %g1; restore; ta 0; nop
SW_trap_0x8a: mov 0x8a, %g1; restore; ta 0; nop
SW_trap_0x8b: mov 0x8b, %g1; restore; ta 0; nop
SW_trap_0x8c: mov 0x8c, %g1; restore; ta 0; nop
SW_trap_0x8d: mov 0x8d, %g1; restore; ta 0; nop
SW_trap_0x8e: mov 0x8e, %g1; restore; ta 0; nop
SW_trap_0x8f: mov 0x8f, %g1; restore; ta 0; nop
SW_trap_0x90: mov 0x90, %g1; restore; ta 0; nop
SW_trap_0x91: mov 0x91, %g1; restore; ta 0; nop
SW_trap_0x92: mov 0x92, %g1; restore; ta 0; nop
SW_trap_0x93: mov 0x93, %g1; restore; ta 0; nop
SW_trap_0x94: mov 0x94, %g1; restore; ta 0; nop
SW_trap_0x95: mov 0x95, %g1; restore; ta 0; nop
SW_trap_0x96: mov 0x96, %g1; restore; ta 0; nop
SW_trap_0x97: mov 0x97, %g1; restore; ta 0; nop
SW_trap_0x98: mov 0x98, %g1; restore; ta 0; nop
SW_trap_0x99: mov 0x99, %g1; restore; ta 0; nop
SW_trap_0x9a: mov 0x9a, %g1; restore; ta 0; nop
SW_trap_0x9b: mov 0x9b, %g1; restore; ta 0; nop
SW_trap_0x9c: mov 0x9c, %g1; restore; ta 0; nop
SW_trap_0x9d: mov 0x9d, %g1; restore; ta 0; nop
SW_trap_0x9e: mov 0x9e, %g1; restore; ta 0; nop
SW_trap_0x9f: mov 0x9f, %g1; restore; ta 0; nop
SW_trap_0xa0: mov 0xa0, %g1; restore; ta 0; nop
SW_trap_0xa1: mov 0xa1, %g1; restore; ta 0; nop
SW_trap_0xa2: mov 0xa2, %g1; restore; ta 0; nop
SW_trap_0xa3: mov 0xa3, %g1; restore; ta 0; nop
SW_trap_0xa4: mov 0xa4, %g1; restore; ta 0; nop
SW_trap_0xa5: mov 0xa5, %g1; restore; ta 0; nop
SW_trap_0xa6: mov 0xa6, %g1; restore; ta 0; nop
SW_trap_0xa7: mov 0xa7, %g1; restore; ta 0; nop
SW_trap_0xa8: mov 0xa8, %g1; restore; ta 0; nop
SW_trap_0xa9: mov 0xa9, %g1; restore; ta 0; nop
SW_trap_0xaa: mov 0xaa, %g1; restore; ta 0; nop
SW_trap_0xab: mov 0xab, %g1; restore; ta 0; nop
SW_trap_0xac: mov 0xac, %g1; restore; ta 0; nop
SW_trap_0xad: mov 0xad, %g1; restore; ta 0; nop
SW_trap_0xae: mov 0xae, %g1; restore; ta 0; nop
SW_trap_0xaf: mov 0xaf, %g1; restore; ta 0; nop
SW_trap_0xb0: mov 0xb0, %g1; restore; ta 0; nop
SW_trap_0xb1: mov 0xb1, %g1; restore; ta 0; nop
SW_trap_0xb2: mov 0xb2, %g1; restore; ta 0; nop
SW_trap_0xb3: mov 0xb3, %g1; restore; ta 0; nop
SW_trap_0xb4: mov 0xb4, %g1; restore; ta 0; nop
SW_trap_0xb5: mov 0xb5, %g1; restore; ta 0; nop
SW_trap_0xb6: mov 0xb6, %g1; restore; ta 0; nop
SW_trap_0xb7: mov 0xb7, %g1; restore; ta 0; nop
SW_trap_0xb8: mov 0xb8, %g1; restore; ta 0; nop
SW_trap_0xb9: mov 0xb9, %g1; restore; ta 0; nop
SW_trap_0xba: mov 0xba, %g1; restore; ta 0; nop
SW_trap_0xbb: mov 0xbb, %g1; restore; ta 0; nop
SW_trap_0xbc: mov 0xbc, %g1; restore; ta 0; nop
SW_trap_0xbd: mov 0xbd, %g1; restore; ta 0; nop
SW_trap_0xbe: mov 0xbe, %g1; restore; ta 0; nop
SW_trap_0xbf: mov 0xbf, %g1; restore; ta 0; nop
SW_trap_0xc0: mov 0xc0, %g1; restore; ta 0; nop
SW_trap_0xc1: mov 0xc1, %g1; restore; ta 0; nop
SW_trap_0xc2: mov 0xc2, %g1; restore; ta 0; nop
SW_trap_0xc3: mov 0xc3, %g1; restore; ta 0; nop
SW_trap_0xc4: mov 0xc4, %g1; restore; ta 0; nop
SW_trap_0xc5: mov 0xc5, %g1; restore; ta 0; nop
SW_trap_0xc6: mov 0xc6, %g1; restore; ta 0; nop
SW_trap_0xc7: mov 0xc7, %g1; restore; ta 0; nop
SW_trap_0xc8: mov 0xc8, %g1; restore; ta 0; nop
SW_trap_0xc9: mov 0xc9, %g1; restore; ta 0; nop
SW_trap_0xca: mov 0xca, %g1; restore; ta 0; nop
SW_trap_0xcb: mov 0xcb, %g1; restore; ta 0; nop
SW_trap_0xcc: mov 0xcc, %g1; restore; ta 0; nop
SW_trap_0xcd: mov 0xcd, %g1; restore; ta 0; nop
SW_trap_0xce: mov 0xce, %g1; restore; ta 0; nop
SW_trap_0xcf: mov 0xcf, %g1; restore; ta 0; nop
SW_trap_0xd0: mov 0xd0, %g1; restore; ta 0; nop
SW_trap_0xd1: mov 0xd1, %g1; restore; ta 0; nop
SW_trap_0xd2: mov 0xd2, %g1; restore; ta 0; nop
SW_trap_0xd3: mov 0xd3, %g1; restore; ta 0; nop
SW_trap_0xd4: mov 0xd4, %g1; restore; ta 0; nop
SW_trap_0xd5: mov 0xd5, %g1; restore; ta 0; nop
SW_trap_0xd6: mov 0xd6, %g1; restore; ta 0; nop
SW_trap_0xd7: mov 0xd7, %g1; restore; ta 0; nop
SW_trap_0xd8: mov 0xd8, %g1; restore; ta 0; nop
SW_trap_0xd9: mov 0xd9, %g1; restore; ta 0; nop
SW_trap_0xda: mov 0xda, %g1; restore; ta 0; nop
SW_trap_0xdb: mov 0xdb, %g1; restore; ta 0; nop
SW_trap_0xdc: mov 0xdc, %g1; restore; ta 0; nop
SW_trap_0xdd: mov 0xdd, %g1; restore; ta 0; nop
SW_trap_0xde: mov 0xde, %g1; restore; ta 0; nop
SW_trap_0xdf: mov 0xdf, %g1; restore; ta 0; nop
SW_trap_0xe0: mov 0xe0, %g1; restore; ta 0; nop
SW_trap_0xe1: mov 0xe1, %g1; restore; ta 0; nop
SW_trap_0xe2: mov 0xe2, %g1; restore; ta 0; nop
SW_trap_0xe3: mov 0xe3, %g1; restore; ta 0; nop
SW_trap_0xe4: mov 0xe4, %g1; restore; ta 0; nop
SW_trap_0xe5: mov 0xe5, %g1; restore; ta 0; nop
SW_trap_0xe6: mov 0xe6, %g1; restore; ta 0; nop
SW_trap_0xe7: mov 0xe7, %g1; restore; ta 0; nop
SW_trap_0xe8: mov 0xe8, %g1; restore; ta 0; nop
SW_trap_0xe9: mov 0xe9, %g1; restore; ta 0; nop
SW_trap_0xea: mov 0xea, %g1; restore; ta 0; nop
SW_trap_0xeb: mov 0xeb, %g1; restore; ta 0; nop
SW_trap_0xec: mov 0xec, %g1; restore; ta 0; nop
SW_trap_0xed: mov 0xed, %g1; restore; ta 0; nop
SW_trap_0xee: mov 0xee, %g1; restore; ta 0; nop
SW_trap_0xef: mov 0xef, %g1; restore; ta 0; nop
SW_trap_0xf0: mov 0xf0, %g1; restore; ta 0; nop
SW_trap_0xf1: mov 0xf1, %g1; restore; ta 0; nop
SW_trap_0xf2: mov 0xf2, %g1; restore; ta 0; nop
SW_trap_0xf3: mov 0xf3, %g1; restore; ta 0; nop
SW_trap_0xf4: mov 0xf4, %g1; restore; ta 0; nop
SW_trap_0xf5: mov 0xf5, %g1; restore; ta 0; nop
SW_trap_0xf6: mov 0xf6, %g1; restore; ta 0; nop
SW_trap_0xf7: mov 0xf7, %g1; restore; ta 0; nop
SW_trap_0xf8: mov 0xf8, %g1; restore; ta 0; nop
SW_trap_0xf9: mov 0xf9, %g1; restore; ta 0; nop
SW_trap_0xfa: mov 0xfa, %g1; restore; ta 0; nop
SW_trap_0xfb: mov 0xfb, %g1; restore; ta 0; nop
SW_trap_0xfc: mov 0xfc, %g1; restore; ta 0; nop
SW_trap_0xfd: mov 0xfd, %g1; restore; ta 0; nop
SW_trap_0xfe: mov 0xfe, %g1; restore; ta 0; nop

nop
nop

	!====================================
	! Window overflow (trap 0x05). A SAVE found its new window invalid.
	! This trap window W is that invalid window. Spill window W-1 to its
	! own stack frame, make W-1 the invalid window, return to retry the
	! SAVE. %l3 = WIM (from the trap table entry).
	!====================================
window_overflow_handler:
	mov	%g1, %l7
	srl	%l3, 1, %g1		! new WIM = old WIM rotated right by one
	sll	%l3, 7, %l4		! (NWINDOWS = 8)
	or	%l4, %g1, %g1
	and	%g1, 0xff, %g1
	save				! into W-1, the window to spill
	wr	%g1, %wim
	nop
	nop
	nop
	std	%l0, [%sp + 0]
	std	%l2, [%sp + 8]
	std	%l4, [%sp + 16]
	std	%l6, [%sp + 24]
	std	%i0, [%sp + 32]
	std	%i2, [%sp + 40]
	std	%i4, [%sp + 48]
	std	%i6, [%sp + 56]
	restore				! back to W
	mov	%l7, %g1
	jmp	%l1			! retry the SAVE
	rett	%l2

	!====================================
	! Window underflow (trap 0x06). A RESTORE (in window X) found window
	! X+1 invalid. This trap window is X-1. Refill X+1 from its stack
	! frame, make X+2 the invalid window, return to retry the RESTORE.
	! %l3 = WIM (from the trap table entry).
	!====================================
window_underflow_handler:
	sll	%l3, 1, %l4		! new WIM = old WIM rotated left by one
	srl	%l3, 7, %l5		! (NWINDOWS = 8)
	or	%l5, %l4, %l5
	and	%l5, 0xff, %l5
	wr	%l5, %wim
	nop
	nop
	nop
	restore				! to X
	restore				! to X+1, the window to refill
	ldd	[%sp + 0], %l0
	ldd	[%sp + 8], %l2
	ldd	[%sp + 16], %l4
	ldd	[%sp + 24], %l6
	ldd	[%sp + 32], %i0
	ldd	[%sp + 40], %i2
	ldd	[%sp + 48], %i4
	ldd	[%sp + 56], %i6
	save				! back to X
	save				! back to X-1
	jmp	%l1			! retry the RESTORE
	rett	%l2

	!====================================
	! Interrupt trap entry (Ref this file's header comment). %l0 = PSR
	! (from the trap table entry), %l1/%l2 = interrupted PC/nPC.
	!====================================
interrupt_trap_entry:
	! If this trap window is the invalid window, spill the next window
	! now, exactly as window_overflow_handler would, so the C handler can
	! SAVE into it.
	rd	%wim, %l3
	and	%l0, 0x1f, %l4		! CWP
	srl	%l3, %l4, %l5
	andcc	%l5, 1, %g0
	be	interrupt_window_ok
	nop
	mov	%g1, %l7
	srl	%l3, 1, %g1
	sll	%l3, 7, %l4
	or	%l4, %g1, %g1
	and	%g1, 0xff, %g1
	save
	wr	%g1, %wim
	nop
	nop
	nop
	std	%l0, [%sp + 0]
	std	%l2, [%sp + 8]
	std	%l4, [%sp + 16]
	std	%l6, [%sp + 24]
	std	%i0, [%sp + 32]
	std	%i2, [%sp + 40]
	std	%i4, [%sp + 48]
	std	%i6, [%sp + 56]
	restore
	mov	%l7, %g1
interrupt_window_ok:
	sub	%fp, 104, %sp		! 96-byte minimum frame + 8 for %y, below the interrupted %sp
	mov	%g1, %l4
	mov	%g2, %l5
	mov	%g3, %l6
	mov	%g4, %l7
	rd	%y, %g1
	st	%g1, [%sp + 96]

	! Traps on (ET=1) so window traps can happen in the handler, all
	! maskable interrupts off (PIL=15). %l0 has ET=0, so xor sets it.
	or	%l0, 0xf00, %g1
	wr	%g1, 0x20, %psr
	nop
	nop
	nop

	rd	%tbr, %o0
	call	ajit_generic_interrupt_handler
	nop

	wr	%l0, %psr		! traps off again (ET=0, original PIL)
	nop
	nop
	nop

	! If the interrupted window (CWP+1) was spilled meanwhile, refill it
	! now, exactly as window_underflow_handler would: RETT may not return
	! into an invalid window. %g1/%g2 are free here (saved above).
	rd	%wim, %g1
	and	%l0, 0x1f, %g2
	add	%g2, 1, %g2
	and	%g2, 7, %g2		! (CWP+1) mod NWINDOWS
	srl	%g1, %g2, %g2
	andcc	%g2, 1, %g0
	be	interrupt_return
	nop
	sll	%g1, 1, %g2
	srl	%g1, 7, %g1
	or	%g1, %g2, %g1
	and	%g1, 0xff, %g1
	wr	%g1, %wim
	nop
	nop
	nop
	restore				! to the interrupted window
	ldd	[%sp + 0], %l0
	ldd	[%sp + 8], %l2
	ldd	[%sp + 16], %l4
	ldd	[%sp + 24], %l6
	ldd	[%sp + 32], %i0
	ldd	[%sp + 40], %i2
	ldd	[%sp + 48], %i4
	ldd	[%sp + 56], %i6
	save				! back to the trap window

interrupt_return:
	ld	[%sp + 96], %g1
	wr	%g1, %y
	mov	%l4, %g1
	mov	%l5, %g2
	mov	%l6, %g3
	mov	%l7, %g4
	wr	%l0, %psr		! restores the condition codes too
	nop
	nop
	nop
	jmp	%l1			! back to the interrupted instruction
	rett	%l2

