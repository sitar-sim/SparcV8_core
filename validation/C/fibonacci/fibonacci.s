	.file	"fibonacci.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -128, %sp
	mov	20, %g1
	st	%g1, [%fp-28]
	st	%g0, [%fp-24]
	mov	1, %g1
	st	%g1, [%fp-20]
	st	%g0, [%fp-16]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-24], %g2
	ld	[%fp-20], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-20], %g1
	st	%g1, [%fp-24]
	ld	[%fp-12], %g1
	st	%g1, [%fp-20]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL2:
	ld	[%fp-16], %g2
	ld	[%fp-28], %g1
	cmp	%g2, %g1
	bl	.LL3
	 nop
	sethi	%hi(6144), %g1
	or	%g1, 621, %g1
	st	%g1, [%fp-8]
	ld	[%fp-24], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 25 "validation/C/fibonacci/fibonacci.c" 1
	mov %g1, %o0
! 0 "" 2
! 29 "validation/C/fibonacci/fibonacci.c" 1
	ta 0
! 0 "" 2
.LL4:
	b	.LL4
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
