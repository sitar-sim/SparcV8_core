	.file	"scratch_pad.c"
	.section	".text"
	.align 4
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL2
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL3
	 nop
.LL2:
	mov	-1, %g1
.LL3:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 29 "C/devices/scratch_pad/../devices_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL4:
	b	.LL4
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -112, %sp
	st	%g0, [%fp-12]
	sethi	%hi(-54272), %g1
	st	%g1, [%fp-8]
	sethi	%hi(-54272), %g1
	st	%g1, [%fp-4]
	sethi	%hi(-54272), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL7
	 nop
	sethi	%hi(-54272), %g1
	or	%g1, 124, %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL7
	 nop
	ld	[%fp-12], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL7:
	sethi	%hi(-54272), %g1
	sethi	%hi(286330880), %g2
	or	%g2, 273, %g2
	st	%g2, [%g1]
	sethi	%hi(-54272), %g1
	or	%g1, 4, %g1
	sethi	%hi(572661760), %g2
	or	%g2, 546, %g2
	st	%g2, [%g1]
	sethi	%hi(-54272), %g1
	ld	[%g1], %g2
	sethi	%hi(286330880), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL8
	 nop
	sethi	%hi(-54272), %g1
	or	%g1, 4, %g1
	ld	[%g1], %g2
	sethi	%hi(572661760), %g1
	or	%g1, 546, %g1
	cmp	%g2, %g1
	bne	.LL8
	 nop
	ld	[%fp-12], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-12]
.LL8:
	sethi	%hi(-54272), %g1
	or	%g1, 8, %g1
	sethi	%hi(-889262080), %g2
	or	%g2, 13, %g2
	st	%g2, [%g1]
	sethi	%hi(-54272), %g1
	or	%g1, 136, %g1
	ld	[%g1], %g2
	sethi	%hi(-889262080), %g1
	or	%g1, 13, %g1
	cmp	%g2, %g1
	bne	.LL9
	 nop
	sethi	%hi(-54272), %g1
	or	%g1, 904, %g1
	ld	[%g1], %g2
	sethi	%hi(-889262080), %g1
	or	%g1, 13, %g1
	cmp	%g2, %g1
	bne	.LL9
	 nop
	ld	[%fp-12], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-12]
.LL9:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	mov	-86, %g2
	stb	%g2, [%g1]
	sethi	%hi(-54272), %g1
	ld	[%g1], %g2
	sethi	%hi(296357888), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL10
	 nop
	ld	[%fp-12], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-12]
.LL10:
	ld	[%fp-4], %g1
	add	%g1, 16, %g1
	sethi	%hi(16908288), %g2
	or	%g2, 772, %g2
	sethi	%hi(84280320), %g3
	or	%g3, 776, %g3
	std	%g2, [%g1]
	sethi	%hi(-54272), %g1
	or	%g1, 16, %g1
	ld	[%g1], %g2
	sethi	%hi(16908288), %g1
	or	%g1, 772, %g1
	cmp	%g2, %g1
	bne	.LL11
	 nop
	sethi	%hi(-54272), %g1
	or	%g1, 20, %g1
	ld	[%g1], %g2
	sethi	%hi(84280320), %g1
	or	%g1, 776, %g1
	cmp	%g2, %g1
	bne	.LL11
	 nop
	ld	[%fp-12], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-12]
.LL11:
	ld	[%fp-12], %o0
	mov	5, %o1
	call	report_and_halt, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
