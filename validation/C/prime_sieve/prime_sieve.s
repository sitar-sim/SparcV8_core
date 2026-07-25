	.file	"prime_sieve.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -328, %sp
	mov	50, %g1
	st	%g1, [%fp-24]
	st	%g0, [%fp-20]
	b	.LL2
	 nop
.LL3:
	ld	[%fp-20], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	mov	1, %g2
	st	%g2, [%g1-228]
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL2:
	ld	[%fp-20], %g2
	ld	[%fp-24], %g1
	cmp	%g2, %g1
	ble	.LL3
	 nop
	st	%g0, [%fp-228]
	st	%g0, [%fp-224]
	mov	2, %g1
	st	%g1, [%fp-20]
	b	.LL4
	 nop
.LL8:
	ld	[%fp-20], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-228], %g1
	cmp	%g1, 0
	be	.LL5
	 nop
	ld	[%fp-20], %g2
	ld	[%fp-20], %g1
	smul	%g2, %g1, %g1
	st	%g1, [%fp-16]
	b	.LL6
	 nop
.LL7:
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	st	%g0, [%g1-228]
	ld	[%fp-16], %g2
	ld	[%fp-20], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-16]
.LL6:
	ld	[%fp-16], %g2
	ld	[%fp-24], %g1
	cmp	%g2, %g1
	ble	.LL7
	 nop
.LL5:
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL4:
	ld	[%fp-20], %g2
	ld	[%fp-20], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-24], %g1
	cmp	%g2, %g1
	ble	.LL8
	 nop
	st	%g0, [%fp-12]
	st	%g0, [%fp-20]
	b	.LL9
	 nop
.LL11:
	ld	[%fp-20], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-228], %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL10:
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL9:
	ld	[%fp-20], %g2
	ld	[%fp-24], %g1
	cmp	%g2, %g1
	ble	.LL11
	 nop
	mov	15, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 38 "validation/C/prime_sieve/prime_sieve.c" 1
	mov %g1, %o0
! 0 "" 2
! 42 "validation/C/prime_sieve/prime_sieve.c" 1
	ta 0
! 0 "" 2
.LL12:
	b	.LL12
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
