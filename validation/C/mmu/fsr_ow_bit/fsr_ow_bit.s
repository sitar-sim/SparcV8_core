	.file	"fsr_ow_bit.c"
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
	save	%sp, -272, %sp
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-140]
	st	%g0, [%fp-144]
	mov	1, %g1
	st	%g1, [%fp-148]
	ld	[%fp-140], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-148], %g1
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
	ld	[%fp-144], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	sethi	%hi(l1_table), %g2
	or	%g2, %lo(l1_table), %g2
	st	%g2, [%fp-132]
	st	%g1, [%fp-136]
	st	%g0, [%fp-128]
	b	.LL4
	 nop
.LL5:
	ld	[%fp-128], %g1
	sll	%g1, 2, %g1
	ld	[%fp-132], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-128], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-128]
.LL4:
	ld	[%fp-128], %g1
	cmp	%g1, 255
	ble	.LL5
	 nop
	st	%g0, [%fp-116]
	mov	3, %g1
	st	%g1, [%fp-120]
	mov	1, %g1
	st	%g1, [%fp-124]
	ld	[%fp-116], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-124], %g1
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
	ld	[%fp-120], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-132], %g1
	st	%g2, [%g1]
	ld	[%fp-132], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-104]
	mov	3, %g1
	st	%g1, [%fp-108]
	mov	1, %g1
	st	%g1, [%fp-112]
	ld	[%fp-104], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-112], %g1
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
	ld	[%fp-108], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-132], %g1
	add	%g1, 64, %g1
	ld	[%fp-136], %g2
	st	%g2, [%g1]
	sethi	%hi(33554432), %g1
	st	%g1, [%fp-92]
	mov	6, %g1
	st	%g1, [%fp-96]
	mov	1, %g1
	st	%g1, [%fp-100]
	ld	[%fp-92], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-100], %g1
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
	ld	[%fp-96], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g2, [%g1+68]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-84]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-88]
	ld	[%fp-88], %g1
	st	%g1, [%fp-80]
	ld	[%fp-80], %g1
	st	%g1, [%fp-76]
	ld	[%fp-76], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-84], %g1
	st	%g2, [%g1]
	ld	[%fp-84], %g1
	st	%g1, [%fp-72]
	ld	[%fp-72], %g1
	st	%g1, [%fp-68]
	ld	[%fp-68], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-60]
	mov	256, %g1
	st	%g1, [%fp-64]
	ld	[%fp-60], %g1
	ld	[%fp-64], %g2
! 96 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-52]
	st	%g0, [%fp-56]
	ld	[%fp-52], %g1
	ld	[%fp-56], %g2
! 96 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	3, %g1
	st	%g1, [%fp-44]
	st	%g0, [%fp-48]
	ld	[%fp-44], %g1
	ld	[%fp-48], %g2
! 96 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	sethi	%hi(286330880), %g1
	or	%g1, 273, %g1
	st	%g1, [%fp-36]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-40]
	ld	[%fp-36], %g1
	ld	[%fp-40], %g2
! 118 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	sethi	%hi(285212672), %g1
	st	%g1, [%fp-32]
	ld	[%fp-32], %g1
! 112 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	lda [%g1] 0x0a, %g1
! 0 "" 2
	st	%g1, [%fp-28]
	mov	768, %g1
	st	%g1, [%fp-24]
	ld	[%fp-24], %g1
! 90 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	st	%g1, [%fp-176]
	ld	[%fp-176], %g1
	and	%g1, 1, %g1
	st	%g1, [%fp-172]
	ld	[%fp-176], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	xor	%g1, 3, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-168]
	ld	[%fp-176], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-164]
	sethi	%hi(572661760), %g1
	or	%g1, 546, %g1
	st	%g1, [%fp-12]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 118 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	mov	768, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
! 90 "validation/C/mmu/fsr_ow_bit/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	st	%g1, [%fp-176]
	ld	[%fp-176], %g1
	and	%g1, 1, %g1
	cmp	%g1, 0
	bne	.LL12
	 nop
	ld	[%fp-176], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	cmp	%g1, 2
	bne	.LL12
	 nop
	ld	[%fp-176], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	cmp	%g1, 4
	bne	.LL12
	 nop
	mov	1, %g1
	b	.LL13
	 nop
.LL12:
	mov	0, %g1
.LL13:
	st	%g1, [%fp-160]
	ld	[%fp-172], %g1
	cmp	%g1, 0
	be	.LL14
	 nop
	ld	[%fp-168], %g1
	cmp	%g1, 0
	be	.LL14
	 nop
	ld	[%fp-164], %g1
	cmp	%g1, 0
	be	.LL14
	 nop
	ld	[%fp-160], %g1
	cmp	%g1, 0
	be	.LL14
	 nop
	mov	1, %g1
	b	.LL15
	 nop
.LL14:
	mov	0, %g1
.LL15:
	st	%g1, [%fp-156]
	ld	[%fp-168], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp-172], %g1
	or	%g2, %g1, %g2
	ld	[%fp-164], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g2
	ld	[%fp-160], %g1
	sll	%g1, 3, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-152]
	ld	[%fp-156], %g1
! 59 "validation/C/mmu/fsr_ow_bit/fsr_ow_bit.c" 1
	mov %g1, %o0
! 0 "" 2
	ld	[%fp-152], %g1
! 60 "validation/C/mmu/fsr_ow_bit/fsr_ow_bit.c" 1
	mov %g1, %o1
! 0 "" 2
! 61 "validation/C/mmu/fsr_ow_bit/fsr_ow_bit.c" 1
	ta 0
! 0 "" 2
.LL16:
	b	.LL16
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
