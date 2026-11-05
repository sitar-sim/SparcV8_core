! ldstub_counter_asm.s
!
! The ldstub_counter test in assembly, with no startup file or library, to show
! the instruction sequence on its own. Every core adds 1 to one counter ITERATIONS
! times, holding a lock taken with LDSTUB. The counter is read with an MMU-bypass
! load (ASI 0x20), which never uses the cache. Then each core puts the number of
! additions it made in %o0, and halts. The counter's final value is checked in
! the .vprj.
!
! Memory starts as zero, so the lock starts free, and the cores need no
! agreement before they begin.

	.equ ITERATIONS, 100
	.equ LOCK,       0x8000         ! the lock byte
	.equ COUNTER,    0x8010         ! the shared counter

.global main
main:
	set LOCK, %l1
	set COUNTER, %l2
	mov 0, %o0                      ! additions made by this core
next_iteration:
try_lock:
	ldstub [%l1], %l3               ! read the byte and set it to 0xFF, atomically
	cmp %l3, 0
	bne try_lock                    ! it was already held, so try again
	nop

	lda [%l2] 0x20, %l4             ! inside the lock: add 1 to the counter
	add %l4, 1, %l4
	st %l4, [%l2]

	stbar                           ! the counter's store goes first
	stb %g0, [%l1]                  ! release the lock

	add %o0, 1, %o0
	cmp %o0, ITERATIONS
	bne next_iteration
	nop

	ta 0
	nop
