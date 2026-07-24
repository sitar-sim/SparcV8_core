	.file	"array_sum.c"
	.common	result,4,4
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -128, %sp
	mov	1, %g1
	st	%g1, [%fp-28]
	mov	2, %g1
	st	%g1, [%fp-24]
	mov	3, %g1
	st	%g1, [%fp-20]
	mov	4, %g1
	st	%g1, [%fp-16]
	mov	5, %g1
	st	%g1, [%fp-12]
	st	%g0, [%fp-8]
	st	%g0, [%fp-4]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-4], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-28], %g1
	ld	[%fp-8], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL2:
	ld	[%fp-4], %g1
	cmp	%g1, 4
	ble	.LL3
	 nop
	sethi	%hi(result), %g1
	or	%g1, %lo(result), %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1]
! 30 "validation/C/array_sum/array_sum.c" 1
	ta 0
! 0 "" 2
.LL4:
	b	.LL4
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
