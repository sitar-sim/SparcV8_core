	.file	"integer_sort.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -152, %sp
	sethi	%hi(C.0.802), %g1
	or	%g1, %lo(C.0.802), %g1
	add	%fp, -56, %g3
	mov	%g1, %g2
	mov	32, %g1
	mov	%g3, %o0
	mov	%g2, %o1
	mov	%g1, %o2
	call	memcpy, 0
	 nop
	st	%g0, [%fp-24]
	b	.LL2
	 nop
.LL6:
	st	%g0, [%fp-20]
	b	.LL3
	 nop
.LL5:
	ld	[%fp-20], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-56], %g2
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-56], %g1
	cmp	%g2, %g1
	ble	.LL4
	 nop
	ld	[%fp-20], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-56], %g1
	st	%g1, [%fp-16]
	ld	[%fp-20], %g1
	ld	[%fp-20], %g2
	add	%g2, 1, %g2
	sll	%g2, 2, %g2
	add	%fp, %g2, %g2
	ld	[%g2-56], %g2
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	st	%g2, [%g1-56]
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%fp-16], %g2
	st	%g2, [%g1-56]
.LL4:
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL3:
	mov	7, %g2
	ld	[%fp-24], %g1
	sub	%g2, %g1, %g2
	ld	[%fp-20], %g1
	cmp	%g2, %g1
	bg	.LL5
	 nop
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL2:
	ld	[%fp-24], %g1
	cmp	%g1, 6
	ble	.LL6
	 nop
	st	%g0, [%fp-12]
	st	%g0, [%fp-24]
	b	.LL7
	 nop
.LL8:
	ld	[%fp-24], %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-56], %g2
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	smul	%g2, %g1, %g1
	ld	[%fp-12], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL7:
	ld	[%fp-24], %g1
	cmp	%g1, 7
	ble	.LL8
	 nop
	mov	225, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 40 "validation/C/integer_sort/integer_sort.c" 1
	mov %g1, %o0
! 0 "" 2
! 44 "validation/C/integer_sort/integer_sort.c" 1
	ta 0
! 0 "" 2
.LL9:
	b	.LL9
	 nop
	.size	main, .-main
	.section	".rodata"
	.align 4
	.type	C.0.802, #object
	.size	C.0.802, 32
C.0.802:
	.long	5
	.long	3
	.long	8
	.long	1
	.long	9
	.long	2
	.long	7
	.long	4
	.ident	"GCC: (GNU) 4.4.3"
