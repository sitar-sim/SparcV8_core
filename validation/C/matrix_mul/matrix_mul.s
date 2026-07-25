	.file	"matrix_mul.c"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -232, %sp
	sethi	%hi(C.0.810), %g1
	or	%g1, %lo(C.0.810), %g1
	add	%fp, -60, %g3
	mov	%g1, %g2
	mov	36, %g1
	mov	%g3, %o0
	mov	%g2, %o1
	mov	%g1, %o2
	call	memcpy, 0
	 nop
	sethi	%hi(C.1.811), %g1
	or	%g1, %lo(C.1.811), %g1
	add	%fp, -96, %g3
	mov	%g1, %g2
	mov	36, %g1
	mov	%g3, %o0
	mov	%g2, %o1
	mov	%g1, %o2
	call	memcpy, 0
	 nop
	st	%g0, [%fp-24]
	b	.LL2
	 nop
.LL7:
	st	%g0, [%fp-20]
	b	.LL3
	 nop
.LL6:
	ld	[%fp-24], %g2
	ld	[%fp-20], %g3
	mov	%g2, %g1
	add	%g1, %g1, %g1
	add	%g1, %g2, %g1
	add	%g1, %g3, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	st	%g0, [%g1-132]
	st	%g0, [%fp-16]
	b	.LL4
	 nop
.LL5:
	ld	[%fp-24], %g2
	ld	[%fp-20], %g4
	ld	[%fp-24], %g3
	ld	[%fp-20], %o5
	mov	%g3, %g1
	add	%g1, %g1, %g1
	add	%g1, %g3, %g1
	add	%g1, %o5, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-132], %o5
	ld	[%fp-24], %g3
	ld	[%fp-16], %o4
	mov	%g3, %g1
	add	%g1, %g1, %g1
	add	%g1, %g3, %g1
	add	%g1, %o4, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-60], %o4
	ld	[%fp-16], %g3
	ld	[%fp-20], %o3
	mov	%g3, %g1
	add	%g1, %g1, %g1
	add	%g1, %g3, %g1
	add	%g1, %o3, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-96], %g1
	smul	%o4, %g1, %g1
	add	%o5, %g1, %g3
	mov	%g2, %g1
	add	%g1, %g1, %g1
	add	%g1, %g2, %g1
	add	%g1, %g4, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	st	%g3, [%g1-132]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL4:
	ld	[%fp-16], %g1
	cmp	%g1, 2
	ble	.LL5
	 nop
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL3:
	ld	[%fp-20], %g1
	cmp	%g1, 2
	ble	.LL6
	 nop
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL2:
	ld	[%fp-24], %g1
	cmp	%g1, 2
	ble	.LL7
	 nop
	st	%g0, [%fp-12]
	st	%g0, [%fp-24]
	b	.LL8
	 nop
.LL11:
	st	%g0, [%fp-20]
	b	.LL9
	 nop
.LL10:
	ld	[%fp-24], %g2
	ld	[%fp-20], %g3
	mov	%g2, %g1
	add	%g1, %g1, %g1
	add	%g1, %g2, %g1
	add	%g1, %g3, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-132], %g1
	ld	[%fp-12], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL9:
	ld	[%fp-20], %g1
	cmp	%g1, 2
	ble	.LL10
	 nop
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL8:
	ld	[%fp-24], %g1
	cmp	%g1, 2
	ble	.LL11
	 nop
	mov	621, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 40 "validation/C/matrix_mul/matrix_mul.c" 1
	mov %g1, %o0
! 0 "" 2
! 44 "validation/C/matrix_mul/matrix_mul.c" 1
	ta 0
! 0 "" 2
.LL12:
	b	.LL12
	 nop
	.size	main, .-main
	.section	".rodata"
	.align 4
	.type	C.0.810, #object
	.size	C.0.810, 36
C.0.810:
	.long	1
	.long	2
	.long	3
	.long	4
	.long	5
	.long	6
	.long	7
	.long	8
	.long	9
	.align 4
	.type	C.1.811, #object
	.size	C.1.811, 36
C.1.811:
	.long	9
	.long	8
	.long	7
	.long	6
	.long	5
	.long	4
	.long	3
	.long	2
	.long	1
	.ident	"GCC: (GNU) 4.4.3"
