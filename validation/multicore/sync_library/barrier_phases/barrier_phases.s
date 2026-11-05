	.file	"barrier_phases.c"
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
	.type	__ajit_read_core_thread_id_word__, #function
	.proc	016
__ajit_read_core_thread_id_word__:
	save	%sp, -104, %sp
! 66 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_access_routines.h" 1
	rd %asr29, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_read_core_thread_id_word__, .-__ajit_read_core_thread_id_word__
	.align 4
	.type	ajit_get_core_and_thread_id, #function
	.proc	020
ajit_get_core_and_thread_id:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	__ajit_read_core_thread_id_word__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	srl	%g1, 8, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	stb	%g2, [%g1]
	ld	[%fp-4], %g1
	mov	%g1, %g2
	ld	[%fp+72], %g1
	stb	%g2, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	ajit_get_core_and_thread_id, .-ajit_get_core_and_thread_id
	.align 4
	.type	this_core_id, #function
	.proc	016
this_core_id:
	save	%sp, -104, %sp
	add	%fp, -1, %g2
	add	%fp, -2, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	ajit_get_core_and_thread_id, 0
	 nop
	ldub	[%fp-1], %g1
	and	%g1, 0xff, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	this_core_id, .-this_core_id
	.align 4
	.type	read_shared, #function
	.proc	016
read_shared:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	read_shared, .-read_shared
	.align 4
	.type	read_shared_byte, #function
	.proc	014
read_shared_byte:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 38 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_core.h" 1
	lduba [%g1] 0x20, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	read_shared_byte, .-read_shared_byte
	.align 4
	.type	ajitInterruptControlRegisterAddress, #function
	.proc	016
ajitInterruptControlRegisterAddress:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp+72], %g1
	add	%g2, %g1, %g1
	mov	%g1, %g2
	sethi	%hi(1073728512), %g1
	add	%g2, %g1, %g1
	sll	%g1, 2, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ajitInterruptControlRegisterAddress, .-ajitInterruptControlRegisterAddress
	.align 4
	.type	readInterruptControlRegister, #function
	.proc	016
readInterruptControlRegister:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	ajitInterruptControlRegisterAddress, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	readInterruptControlRegister, .-readInterruptControlRegister
	.align 4
	.type	writeInterruptControlRegister, #function
	.proc	020
writeInterruptControlRegister:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	ajitInterruptControlRegisterAddress, 0
	 nop
	mov	%o0, %g1
	ld	[%fp+76], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	writeInterruptControlRegister, .-writeInterruptControlRegister
	.align 4
	.type	ajitInterruptControlWritableBits, #function
	.proc	016
ajitInterruptControlWritableBits:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g2
	sethi	%hi(64512), %g1
	or	%g1, 1023, %g1
	and	%g2, %g1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ajitInterruptControlWritableBits, .-ajitInterruptControlWritableBits
	.align 4
	.type	enableInterruptController, #function
	.proc	020
enableInterruptController:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	readInterruptControlRegister, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	ajitInterruptControlWritableBits, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	or	%g1, 1, %g1
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	mov	%g1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	enableInterruptController, .-enableInterruptController
	.align 4
	.type	disableInterruptController, #function
	.proc	020
disableInterruptController:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	readInterruptControlRegister, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	ajitInterruptControlWritableBits, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	and	%g1, -2, %g1
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	mov	%g1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	disableInterruptController, .-disableInterruptController
	.common	ajit_global_interrupt_handlers,64,4
	.align 4
	.global ajit_initialize_interrupt_handlers_to_null
	.type	ajit_initialize_interrupt_handlers_to_null, #function
	.proc	020
ajit_initialize_interrupt_handlers_to_null:
	save	%sp, -104, %sp
	st	%g0, [%fp-4]
	b	.LL28
	 nop
.LL29:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL28:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL29
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	ajit_initialize_interrupt_handlers_to_null, .-ajit_initialize_interrupt_handlers_to_null
	.align 4
	.global ajit_set_interrupt_handler
	.type	ajit_set_interrupt_handler, #function
	.proc	020
ajit_set_interrupt_handler:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	cmp	%g1, 15
	bgu	.LL33
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL33:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_set_interrupt_handler, .-ajit_set_interrupt_handler
	.align 4
	.global ajit_generic_interrupt_handler
	.type	ajit_generic_interrupt_handler, #function
	.proc	020
ajit_generic_interrupt_handler:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -13, %g2
	add	%fp, -14, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	ajit_get_core_and_thread_id, 0
	 nop
	ldub	[%fp-13], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp-14], %g1
	and	%g1, 0xff, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	disableInterruptController, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-12]
	ld	[%fp+68], %g1
	srl	%g1, 4, %g1
	and	%g1, 255, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, 16
	bleu	.LL35
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL35
	 nop
	ld	[%fp-8], %g1
	add	%g1, -16, %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 0
	be	.LL35
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL35:
	ldub	[%fp-13], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp-14], %g1
	and	%g1, 0xff, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	enableInterruptController, 0
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL37
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL37:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_generic_interrupt_handler, .-ajit_generic_interrupt_handler
	.align 4
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL39
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL40
	 nop
.LL39:
	mov	-1, %g1
.LL40:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 59 "validation/multicore/sync_library/barrier_phases/../../multicore_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL41:
	b	.LL41
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.type	atomic_ldstub, #function
	.proc	014
atomic_ldstub:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
! 44 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_sync.h" 1
	ldstub [%g1], %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	atomic_ldstub, .-atomic_ldstub
	.align 4
	.type	memory_fence, #function
	.proc	020
memory_fence:
	save	%sp, -96, %sp
! 61 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_sync.h" 1
	stbar
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	memory_fence, .-memory_fence
	.align 4
	.type	acquire_mutex_using_ldstub, #function
	.proc	020
acquire_mutex_using_ldstub:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	st	%g1, [%fp-4]
	b	.LL48
	 nop
.LL49:
	ld	[%fp-4], %o0
	call	read_shared_byte, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL49
	 nop
.LL48:
	ld	[%fp-4], %o0
	call	atomic_ldstub, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL49
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	acquire_mutex_using_ldstub, .-acquire_mutex_using_ldstub
	.align 4
	.type	release_mutex_using_ldstub, #function
	.proc	020
release_mutex_using_ldstub:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	memory_fence, 0
	 nop
	ld	[%fp+68], %g1
	stb	%g0, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	release_mutex_using_ldstub, .-release_mutex_using_ldstub
	.align 4
	.type	atomic_fetch_and_add, #function
	.proc	016
atomic_fetch_and_add:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_ldstub, 0
	 nop
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	add	%g2, %g1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+4]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	release_mutex_using_ldstub, 0
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	atomic_fetch_and_add, .-atomic_fetch_and_add
	.align 4
	.type	barrier_wait, #function
	.proc	020
barrier_wait:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	ld	[%fp+68], %g2
	add	%g1, 2, %g1
	sll	%g1, 2, %g1
	add	%g2, %g1, %g1
	ld	[%g1+4], %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp+68], %g2
	add	%g1, 2, %g1
	sll	%g1, 2, %g1
	add	%g2, %g1, %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+4]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	mov	1, %o1
	call	atomic_fetch_and_add, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+72], %g1
	add	%g1, -1, %g1
	cmp	%g2, %g1
	bne	.LL56
	 nop
	ld	[%fp+68], %g1
	st	%g0, [%g1+4]
	call	memory_fence, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+8]
	b	.LL58
	 nop
.LL56:
	ld	[%fp+68], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bne	.LL56
	 nop
.LL58:
	restore
	jmp	%o7+8
	 nop
	.size	barrier_wait, .-barrier_wait
	.local	barrier
	.common	barrier,28,4
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	mov	1, %g1
	st	%g1, [%fp-16]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	mov	1, %g1
	st	%g1, [%fp-8]
	b	.LL60
	 nop
.LL66:
	st	%g0, [%fp-20]
	b	.LL61
	 nop
.LL62:
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL61:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	mov	%g1, %g2
	sll	%g2, 2, %g2
	add	%g2, %g1, %g2
	ld	[%fp-20], %g1
	cmp	%g2, %g1
	bgu	.LL62
	 nop
	ld	[%fp-12], %g1
	sll	%g1, 2, %g2
	sethi	%hi(1048576), %g1
	add	%g2, %g1, %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1]
	sethi	%hi(barrier), %g1
	or	%g1, %lo(barrier), %o0
	mov	4, %o1
	call	barrier_wait, 0
	 nop
	st	%g0, [%fp-4]
	b	.LL63
	 nop
.LL65:
	ld	[%fp-4], %g1
	sll	%g1, 2, %g2
	sethi	%hi(1048576), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	cmp	%g2, %g1
	be	.LL64
	 nop
	ld	[%fp-16], %g1
	and	%g1, -2, %g1
	st	%g1, [%fp-16]
.LL64:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL63:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	bleu	.LL65
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL60:
	ld	[%fp-8], %g1
	cmp	%g1, 25
	bleu	.LL66
	 nop
	sethi	%hi(barrier), %g1
	or	%g1, %lo(barrier), %o0
	mov	4, %o1
	call	barrier_wait, 0
	 nop
	sethi	%hi(1048576), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 25
	bne	.LL67
	 nop
	sethi	%hi(1048576), %g1
	or	%g1, 12, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 25
	bne	.LL67
	 nop
	ld	[%fp-16], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-16]
.LL67:
	ld	[%fp-16], %o0
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
