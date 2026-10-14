	.file	"device_never_cached.c"
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
	.type	__ajit_write_timer_control_register_via_bypass__, #function
	.proc	020
__ajit_write_timer_control_register_via_bypass__:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	sethi	%hi(-53248), %g1
	or	%g1, 256, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_write_timer_control_register_via_bypass__, .-__ajit_write_timer_control_register_via_bypass__
	.align 4
	.type	set_always_cacheable, #function
	.proc	020
set_always_cacheable:
	save	%sp, -104, %sp
	mov	256, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 26 "validation/C/caches/device_never_cached/../caches_common.h" 1
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
	bgu	.LL8
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL9
	 nop
.LL8:
	mov	-1, %g1
.LL9:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 39 "validation/C/caches/device_never_cached/../caches_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL10:
	b	.LL10
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -104, %sp
	st	%g0, [%fp-8]
	st	%g0, [%fp-4]
	call	set_always_cacheable, 0
	 nop
	sethi	%hi(39936), %g1
	or	%g1, 65, %o0
	call	__ajit_write_timer_control_register_via_bypass__, 0
	 nop
	sethi	%hi(-53248), %g1
	ld	[%g1], %g2
	sethi	%hi(33554432), %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	bne	.LL19
	 nop
	ld	[%fp-8], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-8]
	b	.LL14
	 nop
.LL16:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	b	.LL14
	 nop
.LL19:
	nop
.LL14:
	sethi	%hi(-53248), %g1
	ld	[%g1], %g2
	sethi	%hi(33554432), %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	bne	.LL15
	 nop
	ld	[%fp-4], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL16
	 nop
.LL15:
	ld	[%fp-4], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	bg	.LL17
	 nop
	ld	[%fp-8], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-8]
.LL17:
	mov	0, %o0
	call	__ajit_write_timer_control_register_via_bypass__, 0
	 nop
	ld	[%fp-8], %o0
	mov	2, %o1
	call	report_and_halt, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
