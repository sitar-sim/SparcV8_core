	.file	"parallel_sum.c"
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
	b	.LL26
	 nop
.LL27:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL26:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL27
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
	bgu	.LL31
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL31:
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
	bleu	.LL33
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL33
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
	be	.LL33
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL33:
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
	be	.LL35
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL35:
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
	bgu	.LL37
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL38
	 nop
.LL37:
	mov	-1, %g1
.LL38:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 59 "validation/multicore/examples/parallel_sum/../../multicore_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL39:
	b	.LL39
	 nop
	.size	report_and_halt, .-report_and_halt
	.common	data,16384,4
	.common	partial_sum,16,4
	.common	done,16,4
	.align 4
	.type	value_at, #function
	.proc	016
value_at:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %g2
	sll	%g2, 3, %g2
	sub	%g2, %g1, %g1
	add	%g1, 3, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	value_at, .-value_at
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -136, %sp
	st	%g0, [%fp-40]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-36]
	ld	[%fp-36], %g1
	sll	%g1, 10, %g1
	st	%g1, [%fp-32]
	st	%g0, [%fp-16]
	st	%g0, [%fp-12]
	ld	[%fp-32], %g1
	st	%g1, [%fp-28]
	b	.LL44
	 nop
.LL45:
	ld	[%fp-28], %l0
	ld	[%fp-28], %o0
	call	value_at, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g3
	sethi	%hi(data), %g1
	or	%g1, %lo(data), %g2
	sll	%l0, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL44:
	ld	[%fp-32], %g1
	add	%g1, 1024, %g2
	ld	[%fp-28], %g1
	cmp	%g2, %g1
	bg	.LL45
	 nop
	ld	[%fp-32], %g1
	st	%g1, [%fp-28]
	b	.LL46
	 nop
.LL47:
	ld	[%fp-28], %g1
	sethi	%hi(data), %g2
	or	%g2, %lo(data), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	ld	[%fp-16], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-16]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL46:
	ld	[%fp-32], %g1
	add	%g1, 1024, %g2
	ld	[%fp-28], %g1
	cmp	%g2, %g1
	bg	.LL47
	 nop
	ld	[%fp-36], %g1
	sethi	%hi(partial_sum), %g2
	or	%g2, %lo(partial_sum), %g2
	sll	%g1, 2, %g1
	ld	[%fp-16], %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-36], %g1
	sethi	%hi(done), %g2
	or	%g2, %lo(done), %g2
	sll	%g1, 2, %g1
	mov	1, %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-36], %g1
	cmp	%g1, 0
	bne	.LL48
	 nop
	st	%g0, [%fp-8]
	mov	1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-24]
	b	.LL49
	 nop
.LL54:
	st	%g0, [%fp-20]
	b	.LL50
	 nop
.LL52:
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL50:
	ld	[%fp-24], %g1
	sll	%g1, 2, %g2
	sethi	%hi(done), %g1
	or	%g1, %lo(done), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL51
	 nop
	ld	[%fp-20], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL52
	 nop
.LL51:
	ld	[%fp-20], %g2
	sethi	%hi(99328), %g1
	or	%g1, 672, %g1
	cmp	%g2, %g1
	bne	.LL53
	 nop
	st	%g0, [%fp-4]
.LL53:
	ld	[%fp-24], %g1
	sll	%g1, 2, %g2
	sethi	%hi(partial_sum), %g1
	or	%g1, %lo(partial_sum), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	ld	[%fp-8], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL49:
	ld	[%fp-24], %g1
	cmp	%g1, 3
	ble	.LL54
	 nop
	sethi	%hi(1048576), %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1]
	st	%g0, [%fp-28]
	b	.LL55
	 nop
.LL56:
	ld	[%fp-28], %o0
	call	value_at, 0
	 nop
	mov	%o0, %g1
	ld	[%fp-12], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL55:
	ld	[%fp-28], %g1
	cmp	%g1, 4095
	ble	.LL56
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 0
	be	.LL62
	 nop
	ld	[%fp-8], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	bne	.LL63
	 nop
	ld	[%fp-40], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-40]
	b	.LL58
	 nop
.LL48:
	ld	[%fp-32], %g1
	st	%g1, [%fp-28]
	b	.LL59
	 nop
.LL60:
	ld	[%fp-28], %o0
	call	value_at, 0
	 nop
	mov	%o0, %g1
	ld	[%fp-12], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL59:
	ld	[%fp-32], %g1
	add	%g1, 1024, %g2
	ld	[%fp-28], %g1
	cmp	%g2, %g1
	bg	.LL60
	 nop
	ld	[%fp-16], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	bne	.LL58
	 nop
	ld	[%fp-40], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-40]
	b	.LL58
	 nop
.LL62:
	nop
	b	.LL58
	 nop
.LL63:
	nop
.LL58:
	ld	[%fp-40], %o0
	mov	1, %o1
	call	report_and_halt, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
