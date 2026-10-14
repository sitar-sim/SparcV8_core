	.file	"atomic_on_cached_line.c"
	.section	".text"
	.align 4
	.type	__ajit_load_ubyte_mmu_bypass__, #function
	.proc	014
__ajit_load_ubyte_mmu_bypass__:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 54 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_access_routines.h" 1
	lduba [%g1] 32, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_load_ubyte_mmu_bypass__, .-__ajit_load_ubyte_mmu_bypass__
	.align 4
	.type	set_always_cacheable, #function
	.proc	020
set_always_cacheable:
	save	%sp, -104, %sp
	mov	256, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 26 "validation/C/caches/atomic_on_cached_line/../caches_common.h" 1
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
! 39 "validation/C/caches/atomic_on_cached_line/../caches_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL8:
	b	.LL8
	 nop
	.size	report_and_halt, .-report_and_halt
	.global lock_byte
	.section	".data"
	.type	lock_byte, #object
	.size	lock_byte, 1
lock_byte:
	.byte	5
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -104, %sp
	st	%g0, [%fp-8]
	call	set_always_cacheable, 0
	 nop
	sethi	%hi(lock_byte), %g1
	or	%g1, %lo(lock_byte), %g1
	ldub	[%g1], %g1
	sethi	%hi(lock_byte), %g1
	or	%g1, %lo(lock_byte), %g1
! 22 "validation/C/caches/atomic_on_cached_line/atomic_on_cached_line.c" 1
	ldstub [%g1], %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 5
	bne	.LL11
	 nop
	ld	[%fp-8], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL11:
	sethi	%hi(lock_byte), %g1
	or	%g1, %lo(lock_byte), %g1
	ldub	[%g1], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 255
	bne	.LL12
	 nop
	ld	[%fp-8], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-8]
.LL12:
	sethi	%hi(lock_byte), %g1
	or	%g1, %lo(lock_byte), %g1
	mov	%g1, %o0
	call	__ajit_load_ubyte_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 255
	bne	.LL13
	 nop
	ld	[%fp-8], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-8]
.LL13:
	ld	[%fp-8], %o0
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
