! snoop_filter.s
!
! The snoop filter leaves out an invalidate if the core's last one was for the same
! line and it has read nothing from the bus since, because it cannot then hold the
! line. It must forget that as soon as the core does read. Here cores 1 to 3 fetch the
! line again in every round, and core 0 writes it each time, so each invalidate after
! the first is for the same line as the one before it. Each must still be delivered.
!
! This test is in assembly because it needs core 0 to write nothing else to memory. Any
! other write would send an invalidate of its own, which would become the "last
! invalidate" and hide a mistake in the filter. Compiled C keeps its local variables
! on the stack, and a barrier writes to memory too. The cores therefore use registers
! only, and coordinate through the scratch-pad, since writes to a device send no
! invalidates.
!
! Runs with the filter on (see the RUN_OPTIONS line). Each core halts with %o0 = 1 if
! it passed. A reader that sees an old value halts at once with %o0 = 0. A core that
! never sees another core's round fails at the cycle limit.

	.equ ROUNDS,   50
	.equ VALUE,    0x100000         ! the shared word
	.equ REACHED,  0xFFFF2C20       ! scratch-pad words 8 to 11: the round each core reached

.global main
main:
	rd %asr29, %l0
	srl %l0, 8, %l0
	and %l0, 0xff, %l0              ! %l0 = core ID
	sll %l0, 2, %l5                 ! %l5 = this core's offset in REACHED
	set VALUE, %l2
	set REACHED, %l3
	mov 0x100, %l7
	sta %l7, [%g0] 0x4              ! the MMU's "always cacheable" bit: turn caching on
	mov 1, %l1                      ! %l1 = the round
	cmp %l0, 0
	be writer
	nop

reader:
	ld [%l2], %l4                   ! fetch the line
	st %l1, [%l3 + %l5]             ! tell core 0
wait_for_writer:
	ld [%l3], %l4
	cmp %l4, %l1
	bne wait_for_writer
	nop
	ld [%l2], %l4                   ! must see this round's value
	cmp %l4, %l1
	bne fail
	nop
	add %l1, 1, %l1
	cmp %l1, ROUNDS
	ble reader
	nop
	ba pass
	nop

writer:
	mov 4, %l6                      ! offsets of cores 1 to 3 in REACHED
wait_for_reader:
	ld [%l3 + %l6], %l4
	cmp %l4, %l1
	bne wait_for_reader
	nop
	add %l6, 4, %l6
	cmp %l6, 16
	bne wait_for_reader
	nop
	st %l1, [%l2]                   ! the write. This is the invalidate being tested
	st %l1, [%l3]                   ! tell the readers
	add %l1, 1, %l1
	cmp %l1, ROUNDS
	ble writer
	nop

pass:
	mov 1, %o0
	ta 0
	nop
fail:
	mov 0, %o0
	ta 0
	nop
