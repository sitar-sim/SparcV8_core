	.file	"ipi_from_core0.c"
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
! 69 "validation/multicore/interrupts/ipi_from_core0/../../multicore_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL39:
	b	.LL39
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.type	ajitIpiDestinationBit, #function
	.proc	016
ajitIpiDestinationBit:
	save	%sp, -96, %sp
	mov	%i0, %g2
	mov	%i1, %g1
	stb	%g2, [%fp+68]
	stb	%g1, [%fp+72]
	ldub	[%fp+68], %g1
	and	%g1, 0xff, %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g1
	add	%g2, %g1, %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ajitIpiDestinationBit, .-ajitIpiDestinationBit
	.align 4
	.type	ajitIpiMessageAddress, #function
	.proc	016
ajitIpiMessageAddress:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	mov	%i1, %g2
	mov	%i2, %g1
	stb	%g2, [%fp+72]
	stb	%g1, [%fp+76]
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g1
	add	%g1, %g1, %g1
	mov	%g1, %g2
	ldub	[%fp+76], %g1
	and	%g1, 0xff, %g1
	add	%g2, %g1, %g1
	sll	%g1, 3, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	add	%g2, %g1, %g1
	add	%g1, 8, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ajitIpiMessageAddress, .-ajitIpiMessageAddress
	.align 4
	.type	__ajit_set_ipi_interrupt__, #function
	.proc	04
__ajit_set_ipi_interrupt__:
	save	%sp, -120, %sp
	st	%i0, [%fp+68]
	mov	%i1, %g4
	mov	%i2, %g3
	mov	%i3, %g2
	mov	%i4, %g1
	st	%i5, [%fp+88]
	stb	%g4, [%fp+72]
	stb	%g3, [%fp+76]
	stb	%g2, [%fp+80]
	stb	%g1, [%fp+84]
	ldub	[%fp+80], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp+84], %g1
	and	%g1, 0xff, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	ajitIpiDestinationBit, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-20]
	ld	[%fp+68], %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-16]
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	ldub	[%fp+80], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp+84], %g1
	and	%g1, 0xff, %g1
	ld	[%fp+68], %o0
	mov	%g2, %o1
	mov	%g1, %o2
	call	ajitIpiMessageAddress, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g1
	sll	%g1, 24, %g2
	ldub	[%fp+76], %g1
	and	%g1, 0xff, %g1
	sll	%g1, 16, %g1
	or	%g2, %g1, %g2
	ldub	[%fp+80], %g1
	and	%g1, 0xff, %g1
	sll	%g1, 8, %g1
	or	%g2, %g1, %g2
	ldub	[%fp+84], %g1
	and	%g1, 0xff, %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %o0
	ld	[%fp-8], %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	ld	[%fp+88], %g2
	ld	[%fp-8], %g1
	add	%g1, 4, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	ld	[%fp-12], %g2
	ld	[%fp-16], %g1
	and	%g2, %g1, %g2
	ld	[%fp-20], %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	be	.LL46
	 nop
	mov	1, %g1
	b	.LL47
	 nop
.LL46:
	ld	[%fp-12], %g2
	ld	[%fp-20], %g1
	or	%g2, %g1, %g2
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	mov	0, %g1
.LL47:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_set_ipi_interrupt__, .-__ajit_set_ipi_interrupt__
	.align 4
	.type	__ajit_clear_ipi_interrupt__, #function
	.proc	04
__ajit_clear_ipi_interrupt__:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	mov	%i1, %g2
	mov	%i2, %g1
	stb	%g2, [%fp+72]
	stb	%g1, [%fp+76]
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp+76], %g1
	and	%g1, 0xff, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	ajitIpiDestinationBit, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	ld	[%fp+68], %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-12], %g1
	xnor	%g0, %g1, %g2
	ld	[%fp-4], %g1
	and	%g2, %g1, %g2
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	ld	[%fp-8], %g2
	ld	[%fp-12], %g1
	and	%g2, %g1, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_clear_ipi_interrupt__, .-__ajit_clear_ipi_interrupt__
	.align 4
	.type	__ajit_enable_ipi_interrupt__, #function
	.proc	04
__ajit_enable_ipi_interrupt__:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	mov	%i1, %g2
	mov	%i2, %g1
	stb	%g2, [%fp+72]
	stb	%g1, [%fp+76]
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g2
	ldub	[%fp+76], %g1
	and	%g1, 0xff, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	ajitIpiDestinationBit, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g2
	ld	[%fp-8], %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	be	.LL52
	 nop
	mov	1, %g1
	b	.LL53
	 nop
.LL52:
	ld	[%fp-4], %g2
	ld	[%fp-8], %g1
	or	%g2, %g1, %g1
	mov	%g1, %o0
	ld	[%fp+68], %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	mov	0, %g1
.LL53:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_enable_ipi_interrupt__, .-__ajit_enable_ipi_interrupt__
	.common	ipis_taken,16,4
	.common	message_ids,16,4
	.common	message_pointer,16,4
	.common	payload,16,4
	.align 4
	.global ipi_handler
	.type	ipi_handler, #function
	.proc	020
ipi_handler:
	save	%sp, -104, %sp
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	and	%g1, 0xff, %g1
	sethi	%hi(-53248), %g2
	or	%g2, 128, %o0
	mov	%g1, %o1
	mov	0, %o2
	call	ajitIpiMessageAddress, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %l0
	ld	[%fp-4], %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g3
	sethi	%hi(message_ids), %g1
	or	%g1, %lo(message_ids), %g2
	sll	%l0, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-8], %l0
	ld	[%fp-4], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g3
	sethi	%hi(message_pointer), %g1
	or	%g1, %lo(message_pointer), %g2
	sll	%l0, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-8], %g1
	and	%g1, 0xff, %g1
	sethi	%hi(-53248), %g2
	or	%g2, 128, %o0
	mov	%g1, %o1
	mov	0, %o2
	call	__ajit_clear_ipi_interrupt__, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(ipis_taken), %g2
	or	%g2, %lo(ipis_taken), %g3
	sll	%g1, 2, %g2
	ld	[%g3+%g2], %g2
	add	%g2, 1, %g3
	sethi	%hi(ipis_taken), %g2
	or	%g2, %lo(ipis_taken), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	restore
	jmp	%o7+8
	 nop
	.size	ipi_handler, .-ipi_handler
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	st	%g0, [%fp-24]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-20]
	mov	11, %o0
	sethi	%hi(ipi_handler), %g1
	or	%g1, %lo(ipi_handler), %o1
	call	ajit_set_interrupt_handler, 0
	 nop
	ld	[%fp-20], %g1
	mov	%g1, %o0
	mov	0, %o1
	mov	2049, %o2
	call	writeInterruptControlRegister, 0
	 nop
	ld	[%fp-20], %g1
	cmp	%g1, 0
	bne	.LL58
	 nop
	st	%g0, [%fp-4]
	mov	1, %g1
	st	%g1, [%fp-16]
	b	.LL59
	 nop
.LL60:
	ld	[%fp-16], %g1
	and	%g1, 0xff, %g1
	sethi	%hi(-53248), %g2
	or	%g2, 128, %o0
	mov	%g1, %o1
	mov	0, %o2
	call	__ajit_enable_ipi_interrupt__, 0
	 nop
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL59:
	ld	[%fp-16], %g1
	cmp	%g1, 3
	ble	.LL60
	 nop
	mov	1, %g1
	st	%g1, [%fp-16]
	b	.LL61
	 nop
.LL66:
	ld	[%fp-16], %g1
	ld	[%fp-16], %g3
	sethi	%hi(-1059192832), %g2
	add	%g3, %g2, %g3
	sethi	%hi(payload), %g2
	or	%g2, %lo(payload), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-16], %g1
	and	%g1, 0xff, %g2
	ld	[%fp-16], %g1
	sll	%g1, 2, %g3
	sethi	%hi(payload), %g1
	or	%g1, %lo(payload), %g1
	add	%g3, %g1, %g1
	sethi	%hi(-53248), %g3
	or	%g3, 128, %o0
	mov	0, %o1
	mov	0, %o2
	mov	%g2, %o3
	mov	0, %o4
	mov	%g1, %o5
	call	__ajit_set_ipi_interrupt__, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL62
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL62:
	st	%g0, [%fp-12]
	b	.LL63
	 nop
.LL65:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL63:
	ld	[%fp-16], %g1
	sll	%g1, 2, %g2
	sethi	%hi(ipis_taken), %g1
	or	%g1, %lo(ipis_taken), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL64
	 nop
	ld	[%fp-12], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL65
	 nop
.LL64:
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL61:
	ld	[%fp-16], %g1
	cmp	%g1, 3
	ble	.LL66
	 nop
	st	%g0, [%fp-8]
	b	.LL67
	 nop
.LL68:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL67:
	ld	[%fp-8], %g1
	cmp	%g1, 199
	ble	.LL68
	 nop
	sethi	%hi(ipis_taken), %g1
	or	%g1, %lo(ipis_taken), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL69
	 nop
	ld	[%fp-24], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL69:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	bne	.LL79
	 nop
	sethi	%hi(ipis_taken+4), %g1
	or	%g1, %lo(ipis_taken+4), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL80
	 nop
	sethi	%hi(ipis_taken+8), %g1
	or	%g1, %lo(ipis_taken+8), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL81
	 nop
	sethi	%hi(ipis_taken+12), %g1
	or	%g1, %lo(ipis_taken+12), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL82
	 nop
	ld	[%fp-24], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-24]
	b	.LL71
	 nop
.LL58:
	st	%g0, [%fp-12]
	b	.LL72
	 nop
.LL74:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL72:
	ld	[%fp-20], %g1
	sethi	%hi(ipis_taken), %g2
	or	%g2, %lo(ipis_taken), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	cmp	%g1, 0
	bne	.LL73
	 nop
	ld	[%fp-12], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL74
	 nop
.LL73:
	st	%g0, [%fp-8]
	b	.LL75
	 nop
.LL76:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL75:
	ld	[%fp-8], %g1
	cmp	%g1, 199
	ble	.LL76
	 nop
	ld	[%fp-20], %g1
	sethi	%hi(ipis_taken), %g2
	or	%g2, %lo(ipis_taken), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	cmp	%g1, 1
	bne	.LL77
	 nop
	ld	[%fp-24], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL77:
	ld	[%fp-20], %g1
	sethi	%hi(message_ids), %g2
	or	%g2, %lo(message_ids), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-20], %g1
	sll	%g1, 8, %g1
	cmp	%g2, %g1
	bne	.LL71
	 nop
	ld	[%fp-20], %g1
	sethi	%hi(message_pointer), %g2
	or	%g2, %lo(message_pointer), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-20], %g1
	sll	%g1, 2, %g3
	sethi	%hi(payload), %g1
	or	%g1, %lo(payload), %g1
	add	%g3, %g1, %g1
	cmp	%g2, %g1
	bne	.LL71
	 nop
	ld	[%fp-20], %g1
	sll	%g1, 2, %g2
	sethi	%hi(payload), %g1
	or	%g1, %lo(payload), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-20], %g3
	sethi	%hi(-1059192832), %g1
	add	%g3, %g1, %g1
	cmp	%g2, %g1
	bne	.LL71
	 nop
	ld	[%fp-24], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-24]
	b	.LL71
	 nop
.LL79:
	nop
	b	.LL71
	 nop
.LL80:
	nop
	b	.LL71
	 nop
.LL81:
	nop
	b	.LL71
	 nop
.LL82:
	nop
.LL71:
	ld	[%fp-24], %o0
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
