	.file	"parallel_matmul.c"
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
	.type	flush_caches, #function
	.proc	020
flush_caches:
	save	%sp, -96, %sp
! 48 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_core.h" 1
	sta %g0, [%g0] 0x10
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	flush_caches, .-flush_caches
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
! 59 "validation/multicore/examples/parallel_matmul/../../multicore_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL41:
	b	.LL41
	 nop
	.size	report_and_halt, .-report_and_halt
	.common	A,1024,4
	.common	B,1024,4
	.common	C,1024,4
	.common	inputs_ready,4,4
	.common	done,16,4
	.align 4
	.type	a_at, #function
	.proc	04
a_at:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	add	%g2, %g1, %g1
	add	%g1, 1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	a_at, .-a_at
	.align 4
	.type	b_at, #function
	.proc	04
b_at:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	be	.LL46
	 nop
	ld	[%fp+68], %g2
	ld	[%fp+72], %g1
	sub	%g2, %g1, %g1
	and	%g1, 3, %g1
	b	.LL47
	 nop
.LL46:
	mov	2, %g1
.LL47:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	b_at, .-b_at
	.align 4
	.type	wait_for, #function
	.proc	04
wait_for:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%g0, [%fp-4]
	b	.LL50
	 nop
.LL52:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL50:
	ld	[%fp+68], %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL51
	 nop
	ld	[%fp-4], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL52
	 nop
.LL51:
	mov	1, %g1
	ld	[%fp-4], %g3
	sethi	%hi(99328), %g2
	or	%g2, 671, %g2
	cmp	%g3, %g2
	ble	.LL53
	 nop
	mov	0, %g1
.LL53:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	wait_for, .-wait_for
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
	cmp	%g1, 0
	bne	.LL56
	 nop
	st	%g0, [%fp-32]
	b	.LL57
	 nop
.LL60:
	st	%g0, [%fp-28]
	b	.LL58
	 nop
.LL59:
	ld	[%fp-32], %l1
	ld	[%fp-28], %l0
	ld	[%fp-32], %o0
	ld	[%fp-28], %o1
	call	a_at, 0
	 nop
	mov	%o0, %g3
	sethi	%hi(A), %g1
	or	%g1, %lo(A), %g2
	sll	%l1, 4, %g1
	add	%g1, %l0, %g1
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-32], %l1
	ld	[%fp-28], %l0
	ld	[%fp-32], %o0
	ld	[%fp-28], %o1
	call	b_at, 0
	 nop
	mov	%o0, %g3
	sethi	%hi(B), %g1
	or	%g1, %lo(B), %g2
	sll	%l1, 4, %g1
	add	%g1, %l0, %g1
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL58:
	ld	[%fp-28], %g1
	cmp	%g1, 15
	ble	.LL59
	 nop
	ld	[%fp-32], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-32]
.LL57:
	ld	[%fp-32], %g1
	cmp	%g1, 15
	ble	.LL60
	 nop
	sethi	%hi(inputs_ready), %g1
	or	%g1, %lo(inputs_ready), %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-40], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-40]
	b	.LL61
	 nop
.LL56:
	sethi	%hi(inputs_ready), %g1
	or	%g1, %lo(inputs_ready), %o0
	call	wait_for, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL62
	 nop
	ld	[%fp-40], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-40]
.LL62:
	call	flush_caches, 0
	 nop
.LL61:
	ld	[%fp-36], %g1
	sll	%g1, 2, %g1
	st	%g1, [%fp-32]
	b	.LL63
	 nop
.LL68:
	st	%g0, [%fp-28]
	b	.LL64
	 nop
.LL67:
	st	%g0, [%fp-20]
	st	%g0, [%fp-24]
	b	.LL65
	 nop
.LL66:
	ld	[%fp-32], %g3
	ld	[%fp-24], %g1
	sethi	%hi(A), %g2
	or	%g2, %lo(A), %g2
	sll	%g3, 4, %g3
	add	%g3, %g1, %g1
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-24], %g4
	ld	[%fp-28], %g1
	sethi	%hi(B), %g3
	or	%g3, %lo(B), %g3
	sll	%g4, 4, %g4
	add	%g4, %g1, %g1
	sll	%g1, 2, %g1
	ld	[%g3+%g1], %g1
	smul	%g2, %g1, %g1
	ld	[%fp-20], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-20]
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL65:
	ld	[%fp-24], %g1
	cmp	%g1, 15
	ble	.LL66
	 nop
	ld	[%fp-32], %g3
	ld	[%fp-28], %g1
	sethi	%hi(C), %g2
	or	%g2, %lo(C), %g2
	sll	%g3, 4, %g3
	add	%g3, %g1, %g1
	sll	%g1, 2, %g1
	ld	[%fp-20], %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL64:
	ld	[%fp-28], %g1
	cmp	%g1, 15
	ble	.LL67
	 nop
	ld	[%fp-32], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-32]
.LL63:
	ld	[%fp-32], %g2
	ld	[%fp-36], %g1
	add	%g1, 1, %g1
	sll	%g1, 2, %g1
	cmp	%g2, %g1
	blu	.LL68
	 nop
	ld	[%fp-36], %g1
	sethi	%hi(done), %g2
	or	%g2, %lo(done), %g2
	sll	%g1, 2, %g1
	mov	1, %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-36], %g1
	cmp	%g1, 0
	bne	.LL69
	 nop
	mov	1, %g1
	st	%g1, [%fp-16]
	mov	1, %g1
	st	%g1, [%fp-12]
	st	%g0, [%fp-8]
	st	%g0, [%fp-24]
	b	.LL70
	 nop
.LL72:
	ld	[%fp-24], %g1
	sll	%g1, 2, %g2
	sethi	%hi(done), %g1
	or	%g1, %lo(done), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	wait_for, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL71
	 nop
	st	%g0, [%fp-16]
.LL71:
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL70:
	ld	[%fp-24], %g1
	cmp	%g1, 3
	ble	.LL72
	 nop
	call	flush_caches, 0
	 nop
	st	%g0, [%fp-32]
	b	.LL73
	 nop
.LL79:
	st	%g0, [%fp-28]
	b	.LL74
	 nop
.LL78:
	st	%g0, [%fp-4]
	st	%g0, [%fp-24]
	b	.LL75
	 nop
.LL76:
	ld	[%fp-32], %o0
	ld	[%fp-24], %o1
	call	a_at, 0
	 nop
	mov	%o0, %l0
	ld	[%fp-24], %o0
	ld	[%fp-28], %o1
	call	b_at, 0
	 nop
	mov	%o0, %g1
	smul	%l0, %g1, %g1
	ld	[%fp-4], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL75:
	ld	[%fp-24], %g1
	cmp	%g1, 15
	ble	.LL76
	 nop
	ld	[%fp-32], %g3
	ld	[%fp-28], %g1
	sethi	%hi(C), %g2
	or	%g2, %lo(C), %g2
	sll	%g3, 4, %g3
	add	%g3, %g1, %g1
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL77
	 nop
	st	%g0, [%fp-12]
.LL77:
	ld	[%fp-8], %g1
	mov	%g1, %g2
	sll	%g2, 5, %g2
	sub	%g2, %g1, %g2
	ld	[%fp-32], %g4
	ld	[%fp-28], %g1
	sethi	%hi(C), %g3
	or	%g3, %lo(C), %g3
	sll	%g4, 4, %g4
	add	%g4, %g1, %g1
	sll	%g1, 2, %g1
	ld	[%g3+%g1], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL74:
	ld	[%fp-28], %g1
	cmp	%g1, 15
	ble	.LL78
	 nop
	ld	[%fp-32], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-32]
.LL73:
	ld	[%fp-32], %g1
	cmp	%g1, 15
	ble	.LL79
	 nop
	sethi	%hi(1048576), %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1]
	ld	[%fp-16], %g1
	cmp	%g1, 0
	be	.LL80
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	bne	.LL69
	 nop
.LL80:
	st	%g0, [%fp-40]
.LL69:
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
