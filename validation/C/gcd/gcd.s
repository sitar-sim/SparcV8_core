	.file	"gcd.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -152, %sp
	mov	48, %g1
	st	%g1, [%fp-40]
	mov	1071, %g1
	st	%g1, [%fp-36]
	mov	270, %g1
	st	%g1, [%fp-32]
	mov	18, %g1
	st	%g1, [%fp-52]
	mov	462, %g1
	st	%g1, [%fp-48]
	mov	192, %g1
	st	%g1, [%fp-44]
	st	%g0, [%fp-12]
	st	%g0, [%fp-28]
	b	.LL2
	 nop
.LL5:
	ld	[%fp-28], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-40], %g1
	st	%g1, [%fp-24]
	ld	[%fp-28], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-52], %g1
	st	%g1, [%fp-20]
	b	.LL3
	 nop
.LL4:
	ld	[%fp-20], %g1
	st	%g1, [%fp-16]
	ld	[%fp-24], %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	ld	[%fp-20], %g2
	nop
	nop
	sdiv	%g1, %g2, %g3
	ld	[%fp-20], %g2
	smul	%g3, %g2, %g2
	sub	%g1, %g2, %g1
	st	%g1, [%fp-20]
	ld	[%fp-16], %g1
	st	%g1, [%fp-24]
.LL3:
	ld	[%fp-20], %g1
	cmp	%g1, 0
	bne	.LL4
	 nop
	ld	[%fp-12], %g2
	ld	[%fp-24], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL2:
	ld	[%fp-28], %g1
	cmp	%g1, 2
	ble	.LL5
	 nop
	mov	33, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 34 "validation/C/gcd/gcd.c" 1
	mov %g1, %o0
! 0 "" 2
! 38 "validation/C/gcd/gcd.c" 1
	ta 0
! 0 "" 2
.LL6:
	b	.LL6
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
