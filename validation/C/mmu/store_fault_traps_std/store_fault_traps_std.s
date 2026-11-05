	.file	"store_fault_traps_std.c"
	.local	context_table
	.common	context_table,1024,1024
	.local	l1_table
	.common	l1_table,1024,1024
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -168, %sp
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-64]
	st	%g0, [%fp-68]
	st	%g0, [%fp-60]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-60], %g1
	sll	%g1, 2, %g1
	ld	[%fp-64], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-60], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-60]
.LL2:
	ld	[%fp-60], %g1
	cmp	%g1, 255
	ble	.LL3
	 nop
	st	%g0, [%fp-48]
	mov	3, %g1
	st	%g1, [%fp-52]
	mov	1, %g1
	st	%g1, [%fp-56]
	ld	[%fp-48], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-56], %g1
	cmp	%g1, 0
	be	.LL4
	 nop
	mov	128, %g1
	b	.LL5
	 nop
.LL4:
	mov	0, %g1
.LL5:
	or	%g2, %g1, %g2
	ld	[%fp-52], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-64], %g1
	st	%g2, [%g1]
	ld	[%fp-64], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-36]
	mov	3, %g1
	st	%g1, [%fp-40]
	mov	1, %g1
	st	%g1, [%fp-44]
	ld	[%fp-36], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-44], %g1
	cmp	%g1, 0
	be	.LL6
	 nop
	mov	128, %g1
	b	.LL7
	 nop
.LL6:
	mov	0, %g1
.LL7:
	or	%g3, %g1, %g3
	ld	[%fp-40], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-64], %g1
	add	%g1, 64, %g1
	ld	[%fp-68], %g2
	st	%g2, [%g1]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-32]
	ld	[%fp-32], %g1
	st	%g1, [%fp-28]
	ld	[%fp-28], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-24]
	ld	[%fp-24], %g1
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-12]
	mov	256, %g1
	st	%g1, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 96 "validation/C/mmu/store_fault_traps_std/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/C/mmu/store_fault_traps_std/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
! 24 "validation/C/mmu/store_fault_traps_std/store_fault_traps_std.c" 1
	mov %g0, %g1
	set 0x10000000, %g4
	mov 0x55, %g2
	mov 0x66, %g3
	std %g2, [%g4]
	mov %g0, %g1
	ta 0
! 0 "" 2
.LL8:
	b	.LL8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
