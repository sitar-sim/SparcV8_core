	.file	"stale_until_flush.c"
	.section	".text"
	.align 4
	.type	__ajit_store_word_mmu_bypass__, #function
	.proc	020
__ajit_store_word_mmu_bypass__:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	ld	[%fp+72], %g2
! 35 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_access_routines.h" 1
	sta %g1, [%g2] 32
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_store_word_mmu_bypass__, .-__ajit_store_word_mmu_bypass__
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
! 26 "validation/C/caches/stale_until_flush/../caches_common.h" 1
	sta %g1, [%g0] 4
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	set_always_cacheable, .-set_always_cacheable
	.align 4
	.type	flush_both_caches, #function
	.proc	020
flush_both_caches:
	save	%sp, -96, %sp
! 32 "validation/C/caches/stale_until_flush/../caches_common.h" 1
	sta %g0, [%g0] 16
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	flush_both_caches, .-flush_both_caches
	.align 4
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL10
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL11
	 nop
.LL10:
	mov	-1, %g1
.LL11:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 39 "validation/C/caches/stale_until_flush/../caches_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL12:
	b	.LL12
	 nop
	.size	report_and_halt, .-report_and_halt
	.global word_under_test
	.section	".data"
	.align 4
	.type	word_under_test, #object
	.size	word_under_test, 4
word_under_test:
	.long	286331153
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -104, %sp
	st	%g0, [%fp-8]
	sethi	%hi(word_under_test), %g1
	or	%g1, %lo(word_under_test), %g1
	st	%g1, [%fp-4]
	call	set_always_cacheable, 0
	 nop
	sethi	%hi(word_under_test), %g1
	or	%g1, %lo(word_under_test), %g1
	ld	[%g1], %g2
	sethi	%hi(286330880), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL15
	 nop
	ld	[%fp-8], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL15:
	sethi	%hi(572661760), %g1
	or	%g1, 546, %o0
	ld	[%fp-4], %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	ld	[%fp-4], %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(572661760), %g1
	or	%g1, 546, %g1
	cmp	%g2, %g1
	bne	.LL16
	 nop
	ld	[%fp-8], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-8]
.LL16:
	sethi	%hi(word_under_test), %g1
	or	%g1, %lo(word_under_test), %g1
	ld	[%g1], %g2
	sethi	%hi(286330880), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL17
	 nop
	ld	[%fp-8], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-8]
.LL17:
	call	flush_both_caches, 0
	 nop
	sethi	%hi(word_under_test), %g1
	or	%g1, %lo(word_under_test), %g1
	ld	[%g1], %g2
	sethi	%hi(572661760), %g1
	or	%g1, 546, %g1
	cmp	%g2, %g1
	bne	.LL18
	 nop
	ld	[%fp-8], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-8]
.LL18:
	ld	[%fp-8], %o0
	mov	4, %o1
	call	report_and_halt, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
