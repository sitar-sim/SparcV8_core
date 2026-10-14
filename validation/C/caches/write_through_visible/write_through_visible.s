	.file	"write_through_visible.c"
	.section	".text"
	.align 4
	.type	__ajit_load_word_mmu_bypass__, #function
	.proc	016
__ajit_load_word_mmu_bypass__:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 41 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_access_routines.h" 1
	lda [%g1] 32, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_load_word_mmu_bypass__, .-__ajit_load_word_mmu_bypass__
	.align 4
	.type	set_always_cacheable, #function
	.proc	020
set_always_cacheable:
	save	%sp, -104, %sp
	mov	256, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 26 "validation/C/caches/write_through_visible/../caches_common.h" 1
	sta %g1, [%g0] 4
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	set_always_cacheable, .-set_always_cacheable
	.align 4
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL6
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL7
	 nop
.LL6:
	mov	-1, %g1
.LL7:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 39 "validation/C/caches/write_through_visible/../caches_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL8:
	b	.LL8
	 nop
	.size	report_and_halt, .-report_and_halt
	.common	buffer,64,4
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -112, %sp
	st	%g0, [%fp-16]
	mov	1, %g1
	st	%g1, [%fp-12]
	mov	1, %g1
	st	%g1, [%fp-8]
	call	set_always_cacheable, 0
	 nop
	st	%g0, [%fp-4]
	b	.LL11
	 nop
.LL12:
	ld	[%fp-4], %g1
	ld	[%fp-4], %g2
	sub	%g2, -4096, %g2
	mov	%g2, %g3
	sethi	%hi(buffer), %g2
	or	%g2, %lo(buffer), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL11:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL12
	 nop
	st	%g0, [%fp-4]
	b	.LL13
	 nop
.LL16:
	ld	[%fp-4], %g1
	sethi	%hi(buffer), %g2
	or	%g2, %lo(buffer), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-4], %g1
	sub	%g1, -4096, %g1
	cmp	%g2, %g1
	be	.LL14
	 nop
	st	%g0, [%fp-12]
.LL14:
	ld	[%fp-4], %g1
	sll	%g1, 2, %g2
	sethi	%hi(buffer), %g1
	or	%g1, %lo(buffer), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	sub	%g1, -4096, %g1
	cmp	%g2, %g1
	be	.LL15
	 nop
	st	%g0, [%fp-8]
.LL15:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL13:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL16
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL17
	 nop
	ld	[%fp-16], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL17:
	ld	[%fp-8], %g1
	cmp	%g1, 0
	be	.LL18
	 nop
	ld	[%fp-16], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-16]
.LL18:
	sethi	%hi(buffer+12), %g1
	or	%g1, %lo(buffer+12), %g1
	mov	-85, %g2
	stb	%g2, [%g1]
	sethi	%hi(buffer), %g1
	or	%g1, %lo(buffer), %g1
	ld	[%g1+12], %g2
	sethi	%hi(-1426059264), %g1
	or	%g1, 3, %g1
	cmp	%g2, %g1
	bne	.LL19
	 nop
	sethi	%hi(buffer+12), %g1
	or	%g1, %lo(buffer+12), %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(-1426059264), %g1
	or	%g1, 3, %g1
	cmp	%g2, %g1
	bne	.LL19
	 nop
	ld	[%fp-16], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-16]
.LL19:
	ld	[%fp-16], %o0
	mov	3, %o1
	call	report_and_halt, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
