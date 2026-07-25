	.file	"checksum.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -128, %sp
	sethi	%hi(1214606336), %g2
	or	%g2, 108, %g2
	sethi	%hi(1865162752), %g3
	or	%g3, 83, %g3
	std	%g2, [%fp-32]
	sethi	%hi(1346457600), %g1
	or	%g1, 579, %g1
	st	%g1, [%fp-24]
	sethi	%hi(8192), %g1
	or	%g1, 256, %g1
	sth	%g1, [%fp-20]
	st	%g0, [%fp-12]
	st	%g0, [%fp-16]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-16], %g1
	add	%fp, %g1, %g1
	ldub	[%g1-32], %g1
	and	%g1, 0xff, %g1
	ld	[%fp-12], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL2:
	ld	[%fp-16], %g1
	add	%fp, %g1, %g1
	ldub	[%g1-32], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL3
	 nop
	mov	986, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 23 "validation/C/checksum/checksum.c" 1
	mov %g1, %o0
! 0 "" 2
! 27 "validation/C/checksum/checksum.c" 1
	ta 0
! 0 "" 2
.LL4:
	b	.LL4
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
