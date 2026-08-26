	.file	"register_rw.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -208, %sp
	mov	510, %g1
	st	%g1, [%fp-76]
	st	%g0, [%fp-80]
	ld	[%fp-76], %g1
	ld	[%fp-80], %g2
! 96 "validation/C/mmu/register_rw/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	st	%g0, [%fp-72]
	ld	[%fp-72], %g1
! 90 "validation/C/mmu/register_rw/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-68]
	ld	[%fp-68], %g1
	xor	%g1, 510, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-108]
	sethi	%hi(-1412571136), %g1
	st	%g1, [%fp-60]
	mov	256, %g1
	st	%g1, [%fp-64]
	ld	[%fp-60], %g1
	ld	[%fp-64], %g2
! 96 "validation/C/mmu/register_rw/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	256, %g1
	st	%g1, [%fp-56]
	ld	[%fp-56], %g1
! 90 "validation/C/mmu/register_rw/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-52]
	ld	[%fp-52], %g1
	mov	%g1, %g2
	sethi	%hi(-1412571136), %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-104]
	mov	7, %g1
	st	%g1, [%fp-44]
	mov	512, %g1
	st	%g1, [%fp-48]
	ld	[%fp-44], %g1
	ld	[%fp-48], %g2
! 96 "validation/C/mmu/register_rw/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	512, %g1
	st	%g1, [%fp-40]
	ld	[%fp-40], %g1
! 90 "validation/C/mmu/register_rw/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-36]
	ld	[%fp-36], %g1
	xor	%g1, 7, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-100]
	sethi	%hi(-559039488), %g1
	or	%g1, 751, %g1
	st	%g1, [%fp-28]
	mov	768, %g1
	st	%g1, [%fp-32]
	ld	[%fp-28], %g1
	ld	[%fp-32], %g2
! 96 "validation/C/mmu/register_rw/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	768, %g1
	st	%g1, [%fp-24]
	ld	[%fp-24], %g1
! 90 "validation/C/mmu/register_rw/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-96]
	sethi	%hi(-559039488), %g1
	or	%g1, 751, %g1
	st	%g1, [%fp-12]
	mov	1024, %g1
	st	%g1, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 96 "validation/C/mmu/register_rw/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1024, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
! 90 "validation/C/mmu/register_rw/../mmu_common.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-92]
	ld	[%fp-108], %g1
	cmp	%g1, 0
	be	.LL2
	 nop
	ld	[%fp-104], %g1
	cmp	%g1, 0
	be	.LL2
	 nop
	ld	[%fp-100], %g1
	cmp	%g1, 0
	be	.LL2
	 nop
	ld	[%fp-96], %g1
	cmp	%g1, 0
	be	.LL2
	 nop
	ld	[%fp-92], %g1
	cmp	%g1, 0
	be	.LL2
	 nop
	mov	1, %g1
	b	.LL3
	 nop
.LL2:
	mov	0, %g1
.LL3:
	st	%g1, [%fp-88]
	ld	[%fp-104], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp-108], %g1
	or	%g2, %g1, %g2
	ld	[%fp-100], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g2
	ld	[%fp-96], %g1
	sll	%g1, 3, %g1
	or	%g2, %g1, %g2
	ld	[%fp-92], %g1
	sll	%g1, 4, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-84]
	ld	[%fp-88], %g1
! 49 "validation/C/mmu/register_rw/register_rw.c" 1
	mov %g1, %o0
! 0 "" 2
	ld	[%fp-84], %g1
! 50 "validation/C/mmu/register_rw/register_rw.c" 1
	mov %g1, %o1
! 0 "" 2
! 51 "validation/C/mmu/register_rw/register_rw.c" 1
	ta 0
! 0 "" 2
.LL4:
	b	.LL4
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
