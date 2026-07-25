	.file	"root_finding.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	sethi	%hi(12288), %g1
	or	%g1, 57, %g1
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	st	%g1, [%fp-16]
.LL4:
	ld	[%fp-20], %g1
	sra	%g1, 31, %g3
	wr	%g3, 0, %y
	ld	[%fp-16], %g3
	nop
	nop
	sdiv	%g1, %g3, %g2
	ld	[%fp-16], %g1
	add	%g2, %g1, %g1
	srl	%g1, 31, %g2
	add	%g2, %g1, %g1
	sra	%g1, 1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-12], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bl	.LL2
	 nop
	mov	111, %g1
	st	%g1, [%fp-8]
	ld	[%fp-16], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 29 "validation/C/root_finding/root_finding.c" 1
	mov %g1, %o0
! 0 "" 2
! 33 "validation/C/root_finding/root_finding.c" 1
	ta 0
! 0 "" 2
	b	.LL3
	 nop
.LL2:
	ld	[%fp-12], %g1
	st	%g1, [%fp-16]
	b	.LL4
	 nop
.LL3:
	b	.LL3
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
