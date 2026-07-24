! test_simple_ADD.s
!
! The simplest possible SPARC V8 test program: add two numbers and put
! the result in a register, then halt.

.global main
main:
_start:
	! Disable traps. %g0 always reads as 0, so this writes 0 into
	! every bit of %psr, including ET (trap-enable). A write to %psr
	! takes a couple of cycles to take effect, hence the nops after it.
	wr %g0, %psr
	nop
	nop
	nop

	! The actual computation: %o0 = 5 + 7
	mov 5, %l0
	mov 7, %l1
	add %l0, %l1, %o0	! %o0 = 0xc (12)

	! Halt. Traps are disabled (ET=0, set above), so this `ta 0`
	! is not taken as a trap: it forces the processor straight into
	! error_mode instead, which every model in this repo recognizes as
	! a deliberate, successful stop (not a bug).
	ta 0
	nop
	nop
