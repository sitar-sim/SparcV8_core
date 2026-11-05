	.file	"window_spill_at_stack_top.c"
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
	b	.LL22
	 nop
.LL23:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL22:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL23
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
	bgu	.LL27
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL27:
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
	bleu	.LL29
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL29
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
	be	.LL29
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL29:
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
	be	.LL31
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL31:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_generic_interrupt_handler, .-ajit_generic_interrupt_handler
	.local	context_table
	.common	context_table,1024,1024
	.local	l1_table
	.common	l1_table,1024,1024
	.align 4
	.type	sum_down_to_zero, #function
	.proc	016
sum_down_to_zero:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	cmp	%g1, 0
	bne	.LL33
	 nop
	mov	0, %g1
	b	.LL34
	 nop
.LL33:
	ld	[%fp+68], %g1
	add	%g1, -1, %g1
	mov	%g1, %o0
	call	sum_down_to_zero, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+68], %g1
	add	%g2, %g1, %g1
.LL34:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	sum_down_to_zero, .-sum_down_to_zero
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -176, %sp
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-72]
	st	%g0, [%fp-76]
	st	%g0, [%fp-68]
	b	.LL37
	 nop
.LL38:
	ld	[%fp-68], %g1
	sll	%g1, 2, %g1
	ld	[%fp-72], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-68], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-68]
.LL37:
	ld	[%fp-68], %g1
	cmp	%g1, 255
	ble	.LL38
	 nop
	st	%g0, [%fp-56]
	mov	3, %g1
	st	%g1, [%fp-60]
	mov	1, %g1
	st	%g1, [%fp-64]
	ld	[%fp-56], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-64], %g1
	cmp	%g1, 0
	be	.LL39
	 nop
	mov	128, %g1
	b	.LL40
	 nop
.LL39:
	mov	0, %g1
.LL40:
	or	%g2, %g1, %g2
	ld	[%fp-60], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-72], %g1
	st	%g2, [%g1]
	ld	[%fp-72], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-44]
	mov	3, %g1
	st	%g1, [%fp-48]
	mov	1, %g1
	st	%g1, [%fp-52]
	ld	[%fp-44], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-52], %g1
	cmp	%g1, 0
	be	.LL41
	 nop
	mov	128, %g1
	b	.LL42
	 nop
.LL41:
	mov	0, %g1
.LL42:
	or	%g3, %g1, %g3
	ld	[%fp-48], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-72], %g1
	add	%g1, 64, %g1
	ld	[%fp-76], %g2
	st	%g2, [%g1]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-36]
	sethi	%hi(l1_table), %g1
	or	%g1, %lo(l1_table), %g1
	st	%g1, [%fp-40]
	ld	[%fp-40], %g1
	st	%g1, [%fp-32]
	ld	[%fp-32], %g1
	st	%g1, [%fp-28]
	ld	[%fp-28], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	mov	%g1, %g2
	ld	[%fp-36], %g1
	st	%g2, [%g1]
	ld	[%fp-36], %g1
	st	%g1, [%fp-24]
	ld	[%fp-24], %g1
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-12]
	mov	256, %g1
	st	%g1, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 96 "validation/C/mmu/window_spill_at_stack_top/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/C/mmu/window_spill_at_stack_top/../mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	40, %o0
	call	sum_down_to_zero, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 820, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-80]
	ld	[%fp-80], %g1
! 37 "validation/C/mmu/window_spill_at_stack_top/window_spill_at_stack_top.c" 1
	mov %g1, %o0
! 0 "" 2
! 38 "validation/C/mmu/window_spill_at_stack_top/window_spill_at_stack_top.c" 1
	ta 0
! 0 "" 2
.LL43:
	b	.LL43
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
