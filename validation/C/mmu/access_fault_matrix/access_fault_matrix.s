	.file	"access_fault_matrix.c"
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
	save	%sp, -512, %sp
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-360]
	st	%g0, [%fp-364]
	st	%g0, [%fp-356]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-356], %g1
	sll	%g1, 2, %g1
	ld	[%fp-360], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-356], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-356]
.LL2:
	ld	[%fp-356], %g1
	cmp	%g1, 255
	ble	.LL3
	 nop
	st	%g0, [%fp-344]
	mov	3, %g1
	st	%g1, [%fp-348]
	mov	1, %g1
	st	%g1, [%fp-352]
	ld	[%fp-344], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-352], %g1
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
	ld	[%fp-348], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-360], %g1
	st	%g2, [%g1]
	ld	[%fp-360], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-332]
	mov	3, %g1
	st	%g1, [%fp-336]
	mov	1, %g1
	st	%g1, [%fp-340]
	ld	[%fp-332], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-340], %g1
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
	ld	[%fp-336], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-360], %g1
	add	%g1, 64, %g1
	ld	[%fp-364], %g2
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-324]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-328]
	ld	[%fp-328], %g1
	st	%g1, [%fp-320]
	ld	[%fp-320], %g1
	st	%g1, [%fp-316]
	ld	[%fp-316], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-324], %g1
	st	%g2, [%g1]
	ld	[%fp-324], %g1
	st	%g1, [%fp-312]
	ld	[%fp-312], %g1
	st	%g1, [%fp-308]
	ld	[%fp-308], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-300]
	mov	256, %g1
	st	%g1, [%fp-304]
	ld	[%fp-300], %g1
	ld	[%fp-304], %g2
! 96 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-292]
	st	%g0, [%fp-296]
	ld	[%fp-292], %g1
	ld	[%fp-296], %g2
! 96 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	3, %g1
	st	%g1, [%fp-284]
	st	%g0, [%fp-288]
	ld	[%fp-284], %g1
	ld	[%fp-288], %g2
! 96 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-272]
	st	%g0, [%fp-276]
	mov	1, %g1
	st	%g1, [%fp-280]
	ld	[%fp-272], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-280], %g1
	cmp	%g1, 0
	be	.LL8
	 nop
	mov	128, %g1
	b	.LL9
	 nop
.LL8:
	mov	0, %g1
.LL9:
	or	%g2, %g1, %g2
	ld	[%fp-276], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g2, [%g1+64]
	st	%g0, [%fp-264]
	mov	4, %g1
	st	%g1, [%fp-268]
	ld	[%fp-264], %g1
	and	%g1, -4096, %g2
	ld	[%fp-268], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-260]
	ld	[%fp-260], %g1
! 130 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-256]
	ld	[%fp-256], %g1
! 112 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x0a, %g1
! 0 "" 2
	st	%g1, [%fp-252]
	mov	768, %g1
	st	%g1, [%fp-248]
	ld	[%fp-248], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-244]
	ld	[%fp-244], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-404]
	sethi	%hi(305419264), %g1
	or	%g1, 632, %g1
	st	%g1, [%fp-236]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-240]
	ld	[%fp-236], %g1
	ld	[%fp-240], %g2
! 118 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	mov	768, %g1
	st	%g1, [%fp-232]
	ld	[%fp-232], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-228]
	ld	[%fp-228], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	cmp	%g1, 2
	bne	.LL10
	 nop
	ld	[%fp-416], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	cmp	%g1, 4
	bne	.LL10
	 nop
	mov	1, %g1
	b	.LL11
	 nop
.LL10:
	mov	0, %g1
.LL11:
	st	%g1, [%fp-400]
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-216]
	mov	1, %g1
	st	%g1, [%fp-220]
	mov	1, %g1
	st	%g1, [%fp-224]
	ld	[%fp-216], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-224], %g1
	cmp	%g1, 0
	be	.LL12
	 nop
	mov	128, %g1
	b	.LL13
	 nop
.LL12:
	mov	0, %g1
.LL13:
	or	%g2, %g1, %g2
	ld	[%fp-220], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g2, [%g1+64]
	st	%g0, [%fp-208]
	mov	4, %g1
	st	%g1, [%fp-212]
	ld	[%fp-208], %g1
	and	%g1, -4096, %g2
	ld	[%fp-212], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-204]
	ld	[%fp-204], %g1
! 130 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-200]
	ld	[%fp-200], %g1
! 112 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x0a, %g1
! 0 "" 2
	st	%g1, [%fp-196]
	mov	768, %g1
	st	%g1, [%fp-192]
	ld	[%fp-192], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-188]
	ld	[%fp-188], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-396]
	sethi	%hi(305419264), %g1
	or	%g1, 632, %g1
	st	%g1, [%fp-180]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-184]
	ld	[%fp-180], %g1
	ld	[%fp-184], %g2
! 118 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	mov	768, %g1
	st	%g1, [%fp-176]
	ld	[%fp-176], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-172]
	ld	[%fp-172], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-392]
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-160]
	mov	2, %g1
	st	%g1, [%fp-164]
	mov	1, %g1
	st	%g1, [%fp-168]
	ld	[%fp-160], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-168], %g1
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
	ld	[%fp-164], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g2, [%g1+64]
	st	%g0, [%fp-152]
	mov	4, %g1
	st	%g1, [%fp-156]
	ld	[%fp-152], %g1
	and	%g1, -4096, %g2
	ld	[%fp-156], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-148]
	ld	[%fp-148], %g1
! 130 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-144]
	ld	[%fp-144], %g1
! 112 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x0a, %g1
! 0 "" 2
	st	%g1, [%fp-140]
	mov	768, %g1
	st	%g1, [%fp-136]
	ld	[%fp-136], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-132]
	ld	[%fp-132], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-388]
	sethi	%hi(305419264), %g1
	or	%g1, 632, %g1
	st	%g1, [%fp-124]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-128]
	ld	[%fp-124], %g1
	ld	[%fp-128], %g2
! 118 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	mov	768, %g1
	st	%g1, [%fp-120]
	ld	[%fp-120], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-116]
	ld	[%fp-116], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	cmp	%g1, 2
	bne	.LL16
	 nop
	ld	[%fp-416], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	cmp	%g1, 4
	bne	.LL16
	 nop
	mov	1, %g1
	b	.LL17
	 nop
.LL16:
	mov	0, %g1
.LL17:
	st	%g1, [%fp-384]
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-104]
	mov	4, %g1
	st	%g1, [%fp-108]
	mov	1, %g1
	st	%g1, [%fp-112]
	ld	[%fp-104], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-112], %g1
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
	ld	[%fp-108], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g2, [%g1+64]
	st	%g0, [%fp-96]
	mov	4, %g1
	st	%g1, [%fp-100]
	ld	[%fp-96], %g1
	and	%g1, -4096, %g2
	ld	[%fp-100], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-92]
	ld	[%fp-92], %g1
! 130 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-88]
	ld	[%fp-88], %g1
! 112 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x0a, %g1
! 0 "" 2
	st	%g1, [%fp-84]
	mov	768, %g1
	st	%g1, [%fp-80]
	ld	[%fp-80], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-76]
	ld	[%fp-76], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	cmp	%g1, 2
	bne	.LL20
	 nop
	ld	[%fp-416], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	cmp	%g1, 0
	bne	.LL20
	 nop
	mov	1, %g1
	b	.LL21
	 nop
.LL20:
	mov	0, %g1
.LL21:
	st	%g1, [%fp-380]
	sethi	%hi(305419264), %g1
	or	%g1, 632, %g1
	st	%g1, [%fp-68]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-72]
	ld	[%fp-68], %g1
	ld	[%fp-72], %g2
! 118 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	mov	768, %g1
	st	%g1, [%fp-64]
	ld	[%fp-64], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-60]
	ld	[%fp-60], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	cmp	%g1, 2
	bne	.LL22
	 nop
	ld	[%fp-416], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	cmp	%g1, 4
	bne	.LL22
	 nop
	mov	1, %g1
	b	.LL23
	 nop
.LL22:
	mov	0, %g1
.LL23:
	st	%g1, [%fp-376]
	sethi	%hi(16777216), %g1
	st	%g1, [%fp-48]
	mov	6, %g1
	st	%g1, [%fp-52]
	mov	1, %g1
	st	%g1, [%fp-56]
	ld	[%fp-48], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-56], %g1
	cmp	%g1, 0
	be	.LL24
	 nop
	mov	128, %g1
	b	.LL25
	 nop
.LL24:
	mov	0, %g1
.LL25:
	or	%g2, %g1, %g2
	ld	[%fp-52], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g2, [%g1+64]
	st	%g0, [%fp-40]
	mov	4, %g1
	st	%g1, [%fp-44]
	ld	[%fp-40], %g1
	and	%g1, -4096, %g2
	ld	[%fp-44], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-36]
	ld	[%fp-36], %g1
! 130 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-32]
	ld	[%fp-32], %g1
! 112 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x0a, %g1
! 0 "" 2
	st	%g1, [%fp-28]
	mov	768, %g1
	st	%g1, [%fp-24]
	ld	[%fp-24], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	cmp	%g1, 3
	bne	.LL26
	 nop
	ld	[%fp-416], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	cmp	%g1, 0
	bne	.LL26
	 nop
	mov	1, %g1
	b	.LL27
	 nop
.LL26:
	mov	0, %g1
.LL27:
	st	%g1, [%fp-372]
	sethi	%hi(305419264), %g1
	or	%g1, 632, %g1
	st	%g1, [%fp-12]
	sethi	%hi(268435456), %g1
	st	%g1, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 118 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	sta %g1, [%g2] 0x0a
! 0 "" 2
	mov	768, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
! 90 "validation/C/mmu/access_fault_matrix/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	st	%g1, [%fp-416]
	ld	[%fp-416], %g1
	srl	%g1, 2, %g1
	and	%g1, 7, %g1
	cmp	%g1, 3
	bne	.LL28
	 nop
	ld	[%fp-416], %g1
	srl	%g1, 5, %g1
	and	%g1, 7, %g1
	cmp	%g1, 4
	bne	.LL28
	 nop
	mov	1, %g1
	b	.LL29
	 nop
.LL28:
	mov	0, %g1
.LL29:
	st	%g1, [%fp-368]
	ld	[%fp-404], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-400], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-396], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-392], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-388], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-384], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-380], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-376], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-372], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	ld	[%fp-368], %g1
	cmp	%g1, 0
	be	.LL30
	 nop
	mov	1, %g1
	b	.LL31
	 nop
.LL30:
	mov	0, %g1
.LL31:
	st	%g1, [%fp-412]
	ld	[%fp-400], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp-404], %g1
	or	%g2, %g1, %g2
	ld	[%fp-396], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g2
	ld	[%fp-392], %g1
	sll	%g1, 3, %g1
	or	%g2, %g1, %g2
	ld	[%fp-388], %g1
	sll	%g1, 4, %g1
	or	%g2, %g1, %g2
	ld	[%fp-384], %g1
	sll	%g1, 5, %g1
	or	%g2, %g1, %g2
	ld	[%fp-380], %g1
	sll	%g1, 6, %g1
	or	%g2, %g1, %g2
	ld	[%fp-376], %g1
	sll	%g1, 7, %g1
	or	%g2, %g1, %g2
	ld	[%fp-372], %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g2
	ld	[%fp-368], %g1
	sll	%g1, 9, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-408]
	ld	[%fp-412], %g1
! 94 "validation/C/mmu/access_fault_matrix/access_fault_matrix.c" 1
	mov %g1, %o0
! 0 "" 2
	ld	[%fp-408], %g1
! 95 "validation/C/mmu/access_fault_matrix/access_fault_matrix.c" 1
	mov %g1, %o1
! 0 "" 2
! 96 "validation/C/mmu/access_fault_matrix/access_fault_matrix.c" 1
	ta 0
! 0 "" 2
.LL32:
	b	.LL32
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
