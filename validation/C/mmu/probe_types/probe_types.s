	.file	"probe_types.c"
	.local	context_table
	.common	context_table,1024,1024
	.local	l1_table
	.common	l1_table,1024,1024
	.local	l2_table
	.common	l2_table,256,1024
	.local	l3_table
	.common	l3_table,256,1024
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -400, %sp
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-300]
	ld	[%fp-300], %g1
	srl	%g1, 18, %g1
	and	%g1, 63, %g1
	st	%g1, [%fp-296]
	ld	[%fp-300], %g1
	srl	%g1, 12, %g1
	and	%g1, 63, %g1
	st	%g1, [%fp-292]
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-232]
	mov	3, %g1
	st	%g1, [%fp-236]
	mov	1, %g1
	st	%g1, [%fp-240]
	ld	[%fp-232], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-240], %g1
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
	ld	[%fp-236], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-288]
	ld	[%fp-292], %g1
	sethi	%hi(l3_table), %g2
	or	%g2, %lo(l3_table), %g2
	sll	%g1, 2, %g1
	ld	[%fp-288], %g3
	st	%g3, [%g2+%g1]
	sethi	%hi(l3_table), %g1
	or	%g1, %lo(l3_table), %g1
	st	%g1, [%fp-228]
	ld	[%fp-228], %g1
	st	%g1, [%fp-224]
	ld	[%fp-224], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-284]
	ld	[%fp-296], %g1
	sethi	%hi(l2_table), %g2
	or	%g2, %lo(l2_table), %g2
	sll	%g1, 2, %g1
	ld	[%fp-284], %g3
	st	%g3, [%g2+%g1]
	sethi	%hi(l2_table), %g1
	or	%g1, %lo(l2_table), %g1
	st	%g1, [%fp-220]
	ld	[%fp-220], %g1
	st	%g1, [%fp-216]
	ld	[%fp-216], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-280]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-208]
	ld	[%fp-280], %g1
	st	%g1, [%fp-212]
	st	%g0, [%fp-204]
	b	.LL4
	 nop
.LL5:
	ld	[%fp-204], %g1
	sll	%g1, 2, %g1
	ld	[%fp-208], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-204], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-204]
.LL4:
	ld	[%fp-204], %g1
	cmp	%g1, 255
	ble	.LL5
	 nop
	st	%g0, [%fp-192]
	mov	3, %g1
	st	%g1, [%fp-196]
	mov	1, %g1
	st	%g1, [%fp-200]
	ld	[%fp-192], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-200], %g1
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
	ld	[%fp-196], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-208], %g1
	st	%g2, [%g1]
	ld	[%fp-208], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-180]
	mov	3, %g1
	st	%g1, [%fp-184]
	mov	1, %g1
	st	%g1, [%fp-188]
	ld	[%fp-180], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-188], %g1
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
	ld	[%fp-184], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-208], %g1
	add	%g1, 64, %g1
	ld	[%fp-212], %g2
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-172]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-176]
	ld	[%fp-176], %g1
	st	%g1, [%fp-168]
	ld	[%fp-168], %g1
	st	%g1, [%fp-164]
	ld	[%fp-164], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-172], %g1
	st	%g2, [%g1]
	ld	[%fp-172], %g1
	st	%g1, [%fp-160]
	ld	[%fp-160], %g1
	st	%g1, [%fp-156]
	ld	[%fp-156], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-148]
	mov	256, %g1
	st	%g1, [%fp-152]
	ld	[%fp-148], %g1
	ld	[%fp-152], %g2
! 96 "validation/C/mmu/probe_types/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-140]
	st	%g0, [%fp-144]
	ld	[%fp-140], %g1
	ld	[%fp-144], %g2
! 96 "validation/C/mmu/probe_types/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%fp-300], %g1
	st	%g1, [%fp-132]
	mov	4, %g1
	st	%g1, [%fp-136]
	ld	[%fp-132], %g1
	and	%g1, -4096, %g2
	ld	[%fp-136], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-128]
	ld	[%fp-128], %g1
! 124 "validation/C/mmu/probe_types/../mmu_common.h" 1
	lda [%g1] 0x03, %g1
! 0 "" 2
	st	%g1, [%fp-124]
	ld	[%fp-124], %g1
	st	%g1, [%fp-244]
	ld	[%fp-244], %g2
	ld	[%fp-288], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-276]
	sethi	%hi(285212672), %g1
	st	%g1, [%fp-116]
	mov	4, %g1
	st	%g1, [%fp-120]
	ld	[%fp-116], %g1
	and	%g1, -4096, %g2
	ld	[%fp-120], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-112]
	ld	[%fp-112], %g1
! 124 "validation/C/mmu/probe_types/../mmu_common.h" 1
	lda [%g1] 0x03, %g1
! 0 "" 2
	st	%g1, [%fp-108]
	ld	[%fp-108], %g1
	st	%g1, [%fp-244]
	ld	[%fp-244], %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-272]
	ld	[%fp-300], %g1
	st	%g1, [%fp-100]
	st	%g0, [%fp-104]
	ld	[%fp-100], %g1
	and	%g1, -4096, %g2
	ld	[%fp-104], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-96]
	ld	[%fp-96], %g1
! 124 "validation/C/mmu/probe_types/../mmu_common.h" 1
	lda [%g1] 0x03, %g1
! 0 "" 2
	st	%g1, [%fp-92]
	ld	[%fp-92], %g1
	st	%g1, [%fp-244]
	ld	[%fp-244], %g2
	ld	[%fp-288], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-268]
	ld	[%fp-300], %g1
	st	%g1, [%fp-84]
	mov	2, %g1
	st	%g1, [%fp-88]
	ld	[%fp-84], %g1
	and	%g1, -4096, %g2
	ld	[%fp-88], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-80]
	ld	[%fp-80], %g1
! 124 "validation/C/mmu/probe_types/../mmu_common.h" 1
	lda [%g1] 0x03, %g1
! 0 "" 2
	st	%g1, [%fp-76]
	ld	[%fp-76], %g1
	st	%g1, [%fp-244]
	ld	[%fp-244], %g2
	ld	[%fp-280], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-264]
	ld	[%fp-292], %g1
	sethi	%hi(l2_table), %g2
	or	%g2, %lo(l2_table), %g2
	st	%g2, [%fp-72]
	ld	[%fp-72], %g2
	st	%g2, [%fp-68]
	ld	[%fp-68], %g2
	srl	%g2, 6, %g2
	sll	%g2, 2, %g2
	or	%g2, 1, %g2
	mov	%g2, %g3
	sethi	%hi(l3_table), %g2
	or	%g2, %lo(l3_table), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	st	%g0, [%fp-60]
	mov	4, %g1
	st	%g1, [%fp-64]
	ld	[%fp-60], %g1
	and	%g1, -4096, %g2
	ld	[%fp-64], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-56]
	ld	[%fp-56], %g1
! 130 "validation/C/mmu/probe_types/../mmu_common.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	ld	[%fp-300], %g1
	st	%g1, [%fp-48]
	st	%g0, [%fp-52]
	ld	[%fp-48], %g1
	and	%g1, -4096, %g2
	ld	[%fp-52], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-44]
	ld	[%fp-44], %g1
! 124 "validation/C/mmu/probe_types/../mmu_common.h" 1
	lda [%g1] 0x03, %g1
! 0 "" 2
	st	%g1, [%fp-40]
	ld	[%fp-40], %g1
	st	%g1, [%fp-244]
	ld	[%fp-244], %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-260]
	ld	[%fp-292], %g1
	sethi	%hi(l3_table), %g2
	or	%g2, %lo(l3_table), %g2
	sll	%g1, 2, %g1
	ld	[%fp-288], %g3
	st	%g3, [%g2+%g1]
	st	%g0, [%fp-32]
	mov	4, %g1
	st	%g1, [%fp-36]
	ld	[%fp-32], %g1
	and	%g1, -4096, %g2
	ld	[%fp-36], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-28]
	ld	[%fp-28], %g1
! 130 "validation/C/mmu/probe_types/../mmu_common.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	ld	[%fp-300], %g1
	st	%g1, [%fp-20]
	mov	3, %g1
	st	%g1, [%fp-24]
	ld	[%fp-20], %g1
	and	%g1, -4096, %g2
	ld	[%fp-24], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-16]
	ld	[%fp-16], %g1
! 124 "validation/C/mmu/probe_types/../mmu_common.h" 1
	lda [%g1] 0x03, %g1
! 0 "" 2
	st	%g1, [%fp-12]
	ld	[%fp-12], %g1
	st	%g1, [%fp-244]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-244], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-256]
	ld	[%fp-276], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	ld	[%fp-272], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	ld	[%fp-268], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	ld	[%fp-264], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	ld	[%fp-260], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	ld	[%fp-256], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	mov	1, %g1
	b	.LL11
	 nop
.LL10:
	mov	0, %g1
.LL11:
	st	%g1, [%fp-252]
	ld	[%fp-272], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp-276], %g1
	or	%g2, %g1, %g2
	ld	[%fp-268], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g2
	ld	[%fp-264], %g1
	sll	%g1, 3, %g1
	or	%g2, %g1, %g2
	ld	[%fp-260], %g1
	sll	%g1, 4, %g1
	or	%g2, %g1, %g2
	ld	[%fp-256], %g1
	sll	%g1, 5, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-248]
	ld	[%fp-252], %g1
! 88 "validation/C/mmu/probe_types/probe_types.c" 1
	mov %g1, %o0
! 0 "" 2
	ld	[%fp-248], %g1
! 89 "validation/C/mmu/probe_types/probe_types.c" 1
	mov %g1, %o1
! 0 "" 2
! 90 "validation/C/mmu/probe_types/probe_types.c" 1
	ta 0
! 0 "" 2
.LL12:
	b	.LL12
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
