	.file	"mmu_disabled_bypass.c"
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
	save	%sp, -184, %sp
	sethi	%hi(5242880), %g1
	st	%g1, [%fp-64]
	st	%g0, [%fp-68]
	mov	1, %g1
	st	%g1, [%fp-72]
	ld	[%fp-64], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-72], %g1
	cmp	%g1, 0
	be	.LL2
	 nop
	mov	128, %g1
	b	.LL3
	 nop
.LL2:
	mov	0, %g1
.LL3:
	or	%g2, %g1, %g2
	ld	[%fp-68], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	sethi	%hi(l1_table), %g2
	or	%g2, %lo(l1_table), %g2
	st	%g2, [%fp-56]
	st	%g1, [%fp-60]
	st	%g0, [%fp-52]
	b	.LL4
	 nop
.LL5:
	ld	[%fp-52], %g1
	sll	%g1, 2, %g1
	ld	[%fp-56], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-52], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-52]
.LL4:
	ld	[%fp-52], %g1
	cmp	%g1, 255
	ble	.LL5
	 nop
	st	%g0, [%fp-40]
	mov	3, %g1
	st	%g1, [%fp-44]
	mov	1, %g1
	st	%g1, [%fp-48]
	ld	[%fp-40], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-48], %g1
	cmp	%g1, 0
	be	.LL6
	 nop
	mov	128, %g1
	b	.LL7
	 nop
.LL6:
	mov	0, %g1
.LL7:
	or	%g2, %g1, %g2
	ld	[%fp-44], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-56], %g1
	st	%g2, [%g1]
	ld	[%fp-56], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-28]
	mov	3, %g1
	st	%g1, [%fp-32]
	mov	1, %g1
	st	%g1, [%fp-36]
	ld	[%fp-28], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-36], %g1
	cmp	%g1, 0
	be	.LL8
	 nop
	mov	128, %g1
	b	.LL9
	 nop
.LL8:
	mov	0, %g1
.LL9:
	or	%g3, %g1, %g3
	ld	[%fp-32], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-56], %g1
	add	%g1, 64, %g1
	ld	[%fp-60], %g2
	st	%g2, [%g1]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-24]
	ld	[%fp-24], %g1
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-16]
	ld	[%fp-16], %g1
	st	%g1, [%fp-12]
	ld	[%fp-12], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-4]
	mov	256, %g1
	st	%g1, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/C/mmu/mmu_disabled_bypass/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	sethi	%hi(5242880), %g1
	sethi	%hi(-559039488), %g2
	or	%g2, 751, %g2
	st	%g2, [%g1]
	mov	1, %g1
	st	%g1, [%fp-88]
	sethi	%hi(5242880), %g1
	ld	[%g1], %g2
	sethi	%hi(-559039488), %g1
	or	%g1, 751, %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-84]
	ld	[%fp-88], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	ld	[%fp-84], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	mov	1, %g1
	b	.LL11
	 nop
.LL10:
	mov	0, %g1
.LL11:
	st	%g1, [%fp-80]
	ld	[%fp-84], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp-88], %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-76]
	ld	[%fp-80], %g1
! 46 "validation/C/mmu/mmu_disabled_bypass/mmu_disabled_bypass.c" 1
	mov %g1, %o0
! 0 "" 2
	ld	[%fp-76], %g1
! 47 "validation/C/mmu/mmu_disabled_bypass/mmu_disabled_bypass.c" 1
	mov %g1, %o1
! 0 "" 2
! 48 "validation/C/mmu/mmu_disabled_bypass/mmu_disabled_bypass.c" 1
	ta 0
! 0 "" 2
.LL12:
	b	.LL12
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
