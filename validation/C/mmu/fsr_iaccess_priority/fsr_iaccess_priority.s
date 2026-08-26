	.file	"fsr_iaccess_priority.c"
	.local	context_table
	.common	context_table,1024,1024
	.local	l1_table
	.common	l1_table,1024,1024
	.global fsr_iaccess_handler
fsr_iaccess_handler:
	mov 0x300, %l0
	lda [%l0] 0x04, %o0
	ta 0
	nop

	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -232, %sp
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-108]
	st	%g0, [%fp-112]
	mov	1, %g1
	st	%g1, [%fp-116]
	ld	[%fp-108], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-116], %g1
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
	ld	[%fp-112], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	sethi	%hi(l1_table), %g2
	or	%g2, %lo(l1_table), %g2
	st	%g2, [%fp-100]
	st	%g1, [%fp-104]
	st	%g0, [%fp-96]
	b	.LL4
	 nop
.LL5:
	ld	[%fp-96], %g1
	sll	%g1, 2, %g1
	ld	[%fp-100], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-96], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-96]
.LL4:
	ld	[%fp-96], %g1
	cmp	%g1, 255
	ble	.LL5
	 nop
	st	%g0, [%fp-84]
	mov	3, %g1
	st	%g1, [%fp-88]
	mov	1, %g1
	st	%g1, [%fp-92]
	ld	[%fp-84], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-92], %g1
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
	ld	[%fp-88], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-100], %g1
	st	%g2, [%g1]
	ld	[%fp-100], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-72]
	mov	3, %g1
	st	%g1, [%fp-76]
	mov	1, %g1
	st	%g1, [%fp-80]
	ld	[%fp-72], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-80], %g1
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
	ld	[%fp-76], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-100], %g1
	add	%g1, 64, %g1
	ld	[%fp-104], %g2
	st	%g2, [%g1]
	sethi	%hi(33554432), %g1
	st	%g1, [%fp-60]
	mov	1, %g1
	st	%g1, [%fp-64]
	mov	1, %g1
	st	%g1, [%fp-68]
	ld	[%fp-60], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-68], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	mov	128, %g1
	b	.LL11
	 nop
.LL10:
	mov	0, %g1
.LL11:
	or	%g2, %g1, %g2
	ld	[%fp-64], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g2, [%g1+68]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-52]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-56]
	ld	[%fp-56], %g1
	st	%g1, [%fp-48]
	ld	[%fp-48], %g1
	st	%g1, [%fp-44]
	ld	[%fp-44], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-52], %g1
	st	%g2, [%g1]
	ld	[%fp-52], %g1
	st	%g1, [%fp-40]
	ld	[%fp-40], %g1
	st	%g1, [%fp-36]
	ld	[%fp-36], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-28]
	mov	256, %g1
	st	%g1, [%fp-32]
	ld	[%fp-28], %g1
	ld	[%fp-32], %g2
! 96 "validation/C/mmu/fsr_iaccess_priority/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-20]
	st	%g0, [%fp-24]
	ld	[%fp-20], %g1
	ld	[%fp-24], %g2
! 96 "validation/C/mmu/fsr_iaccess_priority/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	3, %g1
	st	%g1, [%fp-12]
	st	%g0, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 96 "validation/C/mmu/fsr_iaccess_priority/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
! 74 "validation/C/mmu/fsr_iaccess_priority/fsr_iaccess_priority.c" 1
	rd %tbr, %g1
! 0 "" 2
	st	%g1, [%fp-132]
	ld	[%fp-132], %g1
	add	%g1, 16, %g1
	st	%g1, [%fp-128]
	st	%g0, [%fp-124]
	b	.LL12
	 nop
.LL13:
	ld	[%fp-124], %g1
	sll	%g1, 2, %g1
	ld	[%fp-128], %g2
	add	%g2, %g1, %g1
	sethi	%hi(fsr_iaccess_handler), %g2
	or	%g2, %lo(fsr_iaccess_handler), %g3
	ld	[%fp-124], %g2
	sll	%g2, 2, %g2
	add	%g3, %g2, %g2
	ld	[%g2], %g2
	st	%g2, [%g1]
	ld	[%fp-124], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-124]
.LL12:
	ld	[%fp-124], %g1
	cmp	%g1, 3
	ble	.LL13
	 nop
	sethi	%hi(286330880), %g1
	or	%g1, 273, %g1
	st	%g1, [%fp-4]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 118 "validation/C/mmu/fsr_iaccess_priority/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	sethi	%hi(285212672), %g1
	st	%g1, [%fp-120]
	ld	[%fp-120], %g1
! 89 "validation/C/mmu/fsr_iaccess_priority/fsr_iaccess_priority.c" 1
	jmp %g1
	nop
! 0 "" 2
.LL14:
	b	.LL14
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
