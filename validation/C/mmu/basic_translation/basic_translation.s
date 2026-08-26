	.file	"basic_translation.c"
	.local	context_table
	.common	context_table,1024,1024
	.local	l1_table
	.common	l1_table,1024,1024
	.local	l2_table
	.common	l2_table,256,1024
	.local	l3_table
	.common	l3_table,256,1024
	.local	target_page
	.common	target_page,4096,4096
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -224, %sp
	sethi	%hi(-889262080), %g1
	or	%g1, 13, %g1
	st	%g1, [%fp-108]
	sethi	%hi(268648448), %g1
	st	%g1, [%fp-128]
	ld	[%fp-128], %g1
	srl	%g1, 18, %g1
	and	%g1, 63, %g1
	st	%g1, [%fp-124]
	ld	[%fp-128], %g1
	srl	%g1, 12, %g1
	and	%g1, 63, %g1
	st	%g1, [%fp-120]
	sethi	%hi(target_page), %g1
	or	%g1, %lo(target_page), %g1
	ld	[%fp-108], %g2
	st	%g2, [%g1]
	ld	[%fp-120], %g4
	sethi	%hi(target_page), %g1
	or	%g1, %lo(target_page), %g1
	st	%g1, [%fp-96]
	mov	3, %g1
	st	%g1, [%fp-100]
	mov	1, %g1
	st	%g1, [%fp-104]
	ld	[%fp-96], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-104], %g1
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
	ld	[%fp-100], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g3
	sethi	%hi(l3_table), %g1
	or	%g1, %lo(l3_table), %g2
	sll	%g4, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-124], %g1
	sethi	%hi(l3_table), %g2
	or	%g2, %lo(l3_table), %g2
	st	%g2, [%fp-92]
	ld	[%fp-92], %g2
	st	%g2, [%fp-88]
	ld	[%fp-88], %g2
	srl	%g2, 6, %g2
	sll	%g2, 2, %g2
	or	%g2, 1, %g2
	mov	%g2, %g3
	sethi	%hi(l2_table), %g2
	or	%g2, %lo(l2_table), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	sethi	%hi(l2_table), %g1
	or	%g1, %lo(l2_table), %g1
	st	%g1, [%fp-84]
	ld	[%fp-84], %g1
	st	%g1, [%fp-80]
	ld	[%fp-80], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	sethi	%hi(l1_table), %g2
	or	%g2, %lo(l1_table), %g2
	st	%g2, [%fp-72]
	st	%g1, [%fp-76]
	st	%g0, [%fp-68]
	b	.LL4
	 nop
.LL5:
	ld	[%fp-68], %g1
	sll	%g1, 2, %g1
	ld	[%fp-72], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-68], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-68]
.LL4:
	ld	[%fp-68], %g1
	cmp	%g1, 255
	ble	.LL5
	 nop
	st	%g0, [%fp-56]
	mov	3, %g1
	st	%g1, [%fp-60]
	mov	1, %g1
	st	%g1, [%fp-64]
	ld	[%fp-56], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-64], %g1
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
	ld	[%fp-60], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-72], %g1
	st	%g2, [%g1]
	ld	[%fp-72], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-44]
	mov	3, %g1
	st	%g1, [%fp-48]
	mov	1, %g1
	st	%g1, [%fp-52]
	ld	[%fp-44], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-52], %g1
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
	ld	[%fp-48], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-72], %g1
	add	%g1, 64, %g1
	ld	[%fp-76], %g2
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-36]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-40]
	ld	[%fp-40], %g1
	st	%g1, [%fp-32]
	ld	[%fp-32], %g1
	st	%g1, [%fp-28]
	ld	[%fp-28], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-36], %g1
	st	%g2, [%g1]
	ld	[%fp-36], %g1
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
! 96 "validation/C/mmu/basic_translation/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/C/mmu/basic_translation/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%fp-128], %g1
	ld	[%g1], %g1
	st	%g1, [%fp-112]
	ld	[%fp-112], %g2
	ld	[%fp-108], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-116]
	ld	[%fp-116], %g1
! 41 "validation/C/mmu/basic_translation/basic_translation.c" 1
	mov %g1, %o0
! 0 "" 2
! 42 "validation/C/mmu/basic_translation/basic_translation.c" 1
	ta 0
! 0 "" 2
.LL10:
	b	.LL10
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
