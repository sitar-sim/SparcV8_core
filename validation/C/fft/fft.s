	.file	"fft.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -176, %sp
	mov	1, %g1
	st	%g1, [%fp-48]
	mov	2, %g1
	st	%g1, [%fp-44]
	mov	3, %g1
	st	%g1, [%fp-40]
	mov	4, %g1
	st	%g1, [%fp-36]
	ld	[%fp-48], %g2
	ld	[%fp-40], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-32]
	ld	[%fp-48], %g2
	ld	[%fp-40], %g1
	sub	%g2, %g1, %g1
	st	%g1, [%fp-28]
	ld	[%fp-44], %g2
	ld	[%fp-36], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-24]
	ld	[%fp-44], %g2
	ld	[%fp-36], %g1
	sub	%g2, %g1, %g1
	st	%g1, [%fp-20]
	ld	[%fp-32], %g2
	ld	[%fp-24], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-64]
	st	%g0, [%fp-80]
	ld	[%fp-28], %g1
	st	%g1, [%fp-60]
	ld	[%fp-20], %g1
	sub	%g0, %g1, %g1
	st	%g1, [%fp-76]
	ld	[%fp-32], %g2
	ld	[%fp-24], %g1
	sub	%g2, %g1, %g1
	st	%g1, [%fp-56]
	st	%g0, [%fp-72]
	ld	[%fp-28], %g1
	st	%g1, [%fp-52]
	ld	[%fp-20], %g1
	st	%g1, [%fp-68]
	st	%g0, [%fp-12]
	st	%g0, [%fp-16]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-64], %g2
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-64], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-80], %g3
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-80], %g1
	smul	%g3, %g1, %g1
	add	%g2, %g1, %g1
	ld	[%fp-12], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL2:
	ld	[%fp-16], %g1
	cmp	%g1, 3
	ble	.LL3
	 nop
	mov	120, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 48 "validation/C/fft/fft.c" 1
	mov %g1, %o0
! 0 "" 2
! 52 "validation/C/fft/fft.c" 1
	ta 0
! 0 "" 2
.LL4:
	b	.LL4
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
