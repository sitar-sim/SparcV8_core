	.file	"huge_page_levels.c"
	.local	context_table
	.common	context_table,1024,1024
	.local	l1_table
	.common	l1_table,1024,1024
	.local	l2_table
	.common	l2_table,256,1024
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -360, %sp
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-260]
	sethi	%hi(16777216), %g1
	sethi	%hi(286334976), %g2
	or	%g2, 546, %g2
	st	%g2, [%g1]
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-228]
	mov	3, %g1
	st	%g1, [%fp-232]
	mov	1, %g1
	st	%g1, [%fp-236]
	ld	[%fp-228], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-236], %g1
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
	ld	[%fp-232], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	sethi	%hi(l1_table), %g2
	or	%g2, %lo(l1_table), %g2
	st	%g2, [%fp-220]
	st	%g1, [%fp-224]
	st	%g0, [%fp-216]
	b	.LL4
	 nop
.LL5:
	ld	[%fp-216], %g1
	sll	%g1, 2, %g1
	ld	[%fp-220], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-216], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-216]
.LL4:
	ld	[%fp-216], %g1
	cmp	%g1, 255
	ble	.LL5
	 nop
	st	%g0, [%fp-204]
	mov	3, %g1
	st	%g1, [%fp-208]
	mov	1, %g1
	st	%g1, [%fp-212]
	ld	[%fp-204], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-212], %g1
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
	ld	[%fp-208], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-220], %g1
	st	%g2, [%g1]
	ld	[%fp-220], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-192]
	mov	3, %g1
	st	%g1, [%fp-196]
	mov	1, %g1
	st	%g1, [%fp-200]
	ld	[%fp-192], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-200], %g1
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
	ld	[%fp-196], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-220], %g1
	add	%g1, 64, %g1
	ld	[%fp-224], %g2
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-184]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-188]
	ld	[%fp-188], %g1
	st	%g1, [%fp-180]
	ld	[%fp-180], %g1
	st	%g1, [%fp-176]
	ld	[%fp-176], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-184], %g1
	st	%g2, [%g1]
	ld	[%fp-184], %g1
	st	%g1, [%fp-172]
	ld	[%fp-172], %g1
	st	%g1, [%fp-168]
	ld	[%fp-168], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-160]
	mov	256, %g1
	st	%g1, [%fp-164]
	ld	[%fp-160], %g1
	ld	[%fp-164], %g2
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-152]
	st	%g0, [%fp-156]
	ld	[%fp-152], %g1
	ld	[%fp-156], %g2
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%fp-260], %g1
	ld	[%g1], %g2
	sethi	%hi(286334976), %g1
	or	%g1, 546, %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-256]
	st	%g0, [%fp-144]
	st	%g0, [%fp-148]
	ld	[%fp-144], %g1
	ld	[%fp-148], %g2
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-260]
	sethi	%hi(262144), %g1
	sethi	%hi(858997760), %g2
	or	%g2, 68, %g2
	st	%g2, [%g1]
	sethi	%hi(262144), %g1
	st	%g1, [%fp-132]
	mov	3, %g1
	st	%g1, [%fp-136]
	mov	1, %g1
	st	%g1, [%fp-140]
	ld	[%fp-132], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-140], %g1
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
	ld	[%fp-136], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l2_table), %g1
	or	%g1, %lo(l2_table), %g1
	st	%g2, [%g1]
	sethi	%hi(l2_table), %g1
	or	%g1, %lo(l2_table), %g1
	st	%g1, [%fp-128]
	ld	[%fp-128], %g1
	st	%g1, [%fp-124]
	ld	[%fp-124], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	sethi	%hi(l1_table), %g2
	or	%g2, %lo(l1_table), %g2
	st	%g2, [%fp-116]
	st	%g1, [%fp-120]
	st	%g0, [%fp-112]
	b	.LL12
	 nop
.LL13:
	ld	[%fp-112], %g1
	sll	%g1, 2, %g1
	ld	[%fp-116], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-112], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-112]
.LL12:
	ld	[%fp-112], %g1
	cmp	%g1, 255
	ble	.LL13
	 nop
	st	%g0, [%fp-100]
	mov	3, %g1
	st	%g1, [%fp-104]
	mov	1, %g1
	st	%g1, [%fp-108]
	ld	[%fp-100], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-108], %g1
	cmp	%g1, 0
	be	.LL14
	 nop
	mov	128, %g1
	b	.LL15
	 nop
.LL14:
	mov	0, %g1
.LL15:
	or	%g2, %g1, %g2
	ld	[%fp-104], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-116], %g1
	st	%g2, [%g1]
	ld	[%fp-116], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-88]
	mov	3, %g1
	st	%g1, [%fp-92]
	mov	1, %g1
	st	%g1, [%fp-96]
	ld	[%fp-88], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-96], %g1
	cmp	%g1, 0
	be	.LL16
	 nop
	mov	128, %g1
	b	.LL17
	 nop
.LL16:
	mov	0, %g1
.LL17:
	or	%g3, %g1, %g3
	ld	[%fp-92], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-116], %g1
	add	%g1, 64, %g1
	ld	[%fp-120], %g2
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-80]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-84]
	ld	[%fp-84], %g1
	st	%g1, [%fp-76]
	ld	[%fp-76], %g1
	st	%g1, [%fp-72]
	ld	[%fp-72], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-80], %g1
	st	%g2, [%g1]
	ld	[%fp-80], %g1
	st	%g1, [%fp-68]
	ld	[%fp-68], %g1
	st	%g1, [%fp-64]
	ld	[%fp-64], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-56]
	mov	256, %g1
	st	%g1, [%fp-60]
	ld	[%fp-56], %g1
	ld	[%fp-60], %g2
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-48]
	st	%g0, [%fp-52]
	ld	[%fp-48], %g1
	ld	[%fp-52], %g2
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%fp-260], %g1
	ld	[%g1], %g2
	sethi	%hi(858997760), %g1
	or	%g1, 68, %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-252]
	st	%g0, [%fp-40]
	st	%g0, [%fp-44]
	ld	[%fp-40], %g1
	ld	[%fp-44], %g2
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	sethi	%hi(5242880), %g1
	sethi	%hi(1431659520), %g2
	or	%g2, 614, %g2
	st	%g2, [%g1]
	st	%g0, [%fp-28]
	mov	3, %g1
	st	%g1, [%fp-32]
	mov	1, %g1
	st	%g1, [%fp-36]
	ld	[%fp-28], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-36], %g1
	cmp	%g1, 0
	be	.LL18
	 nop
	mov	128, %g1
	b	.LL19
	 nop
.LL18:
	mov	0, %g1
.LL19:
	or	%g2, %g1, %g2
	ld	[%fp-32], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
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
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/C/mmu/huge_page_levels/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	sethi	%hi(5242880), %g1
	ld	[%g1], %g2
	sethi	%hi(1431659520), %g1
	or	%g1, 614, %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-248]
	ld	[%fp-256], %g1
	cmp	%g1, 0
	be	.LL20
	 nop
	ld	[%fp-252], %g1
	cmp	%g1, 0
	be	.LL20
	 nop
	ld	[%fp-248], %g1
	cmp	%g1, 0
	be	.LL20
	 nop
	mov	1, %g1
	b	.LL21
	 nop
.LL20:
	mov	0, %g1
.LL21:
	st	%g1, [%fp-244]
	ld	[%fp-252], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp-256], %g1
	or	%g2, %g1, %g2
	ld	[%fp-248], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-240]
	ld	[%fp-244], %g1
! 91 "validation/C/mmu/huge_page_levels/huge_page_levels.c" 1
	mov %g1, %o0
! 0 "" 2
	ld	[%fp-240], %g1
! 92 "validation/C/mmu/huge_page_levels/huge_page_levels.c" 1
	mov %g1, %o1
! 0 "" 2
! 93 "validation/C/mmu/huge_page_levels/huge_page_levels.c" 1
	ta 0
! 0 "" 2
.LL22:
	b	.LL22
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
