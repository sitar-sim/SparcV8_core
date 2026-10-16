	.file	"dma_interrupt.c"
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
! 29 "validation/sparc_apara/basic/dma_interrupt/../../../C/devices/devices_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL12:
	b	.LL12
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.type	apara_dma_read, #function
	.proc	016
apara_dma_read:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g2
	sethi	%hi(134213632), %g1
	or	%g1, 256, %g1
	add	%g2, %g1, %g1
	sll	%g1, 3, %g2
	ld	[%fp+72], %g1
	add	%g2, %g1, %g1
	sll	%g1, 2, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_read, .-apara_dma_read
	.align 4
	.type	apara_dma_write, #function
	.proc	020
apara_dma_write:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %g2
	sethi	%hi(134213632), %g1
	or	%g1, 256, %g1
	add	%g2, %g1, %g1
	sll	%g1, 3, %g2
	ld	[%fp+72], %g1
	add	%g2, %g1, %g1
	sll	%g1, 2, %g1
	ld	[%fp+76], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_write, .-apara_dma_write
	.align 4
	.type	apara_dmem_read_word, #function
	.proc	016
apara_dmem_read_word:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g2
	sethi	%hi(16777216), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_dmem_read_word, .-apara_dmem_read_word
	.align 4
	.type	apara_dma_start, #function
	.proc	020
apara_dma_start:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+68], %o0
	mov	1, %o1
	ld	[%fp+76], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	2, %o1
	ld	[%fp+80], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+84], %g2
	ld	[%fp+92], %g1
	smul	%g2, %g1, %g1
	ld	[%fp+68], %o0
	mov	3, %o1
	mov	%g1, %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	4, %o1
	ld	[%fp+84], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	5, %o1
	ld	[%fp+88], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	6, %o1
	ld	[%fp+92], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+72], %g1
	sll	%g1, 24, %g2
	ld	[%fp+96], %g1
	cmp	%g1, 0
	be	.LL21
	 nop
	mov	8, %g1
	b	.LL22
	 nop
.LL21:
	mov	0, %g1
.LL22:
	or	%g2, %g1, %g1
	or	%g1, 1, %g1
	ld	[%fp+68], %o0
	mov	0, %o1
	mov	%g1, %o2
	call	apara_dma_write, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_start, .-apara_dma_start
	.align 4
	.type	apara_dma_clear_interrupt, #function
	.proc	020
apara_dma_clear_interrupt:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	0, %o1
	mov	0, %o2
	call	apara_dma_write, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_clear_interrupt, .-apara_dma_clear_interrupt
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
	b	.LL39
	 nop
.LL40:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL39:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL40
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
	bgu	.LL44
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL44:
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
	bleu	.LL46
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL46
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
	be	.LL46
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL46:
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
	be	.LL48
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL48:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_generic_interrupt_handler, .-ajit_generic_interrupt_handler
	.global dma_interrupts
	.section	".bss"
	.align 4
	.type	dma_interrupts, #object
	.size	dma_interrupts, 4
dma_interrupts:
	.skip	4
	.global control_in_handler
	.align 4
	.type	control_in_handler, #object
	.size	control_in_handler, 4
control_in_handler:
	.skip	4
	.common	source,32,8
	.section	".text"
	.align 4
	.global engine_handler
	.type	engine_handler, #function
	.proc	020
engine_handler:
	save	%sp, -96, %sp
	mov	1, %o0
	mov	0, %o1
	call	apara_dma_read, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(control_in_handler), %g1
	or	%g1, %lo(control_in_handler), %g1
	st	%g2, [%g1]
	mov	1, %o0
	call	apara_dma_clear_interrupt, 0
	 nop
	sethi	%hi(dma_interrupts), %g1
	or	%g1, %lo(dma_interrupts), %g1
	ld	[%g1], %g1
	add	%g1, 1, %g2
	sethi	%hi(dma_interrupts), %g1
	or	%g1, %lo(dma_interrupts), %g1
	st	%g2, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	engine_handler, .-engine_handler
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -136, %sp
	st	%g0, [%fp-20]
	st	%g0, [%fp-16]
	b	.LL52
	 nop
.LL53:
	ld	[%fp-16], %g1
	ld	[%fp-16], %g2
	add	%g2, -96, %g2
	mov	%g2, %g3
	sethi	%hi(source), %g2
	or	%g2, %lo(source), %g2
	stb	%g3, [%g2+%g1]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL52:
	ld	[%fp-16], %g1
	cmp	%g1, 31
	ble	.LL53
	 nop
	call	ajit_initialize_interrupt_handlers_to_null, 0
	 nop
	mov	14, %o0
	sethi	%hi(engine_handler), %g1
	or	%g1, %lo(engine_handler), %o1
	call	ajit_set_interrupt_handler, 0
	 nop
	mov	0, %o0
	mov	0, %o1
	sethi	%hi(16384), %g1
	or	%g1, 1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	sethi	%hi(source), %g1
	or	%g1, %lo(source), %g1
	add	%g1, 1, %g1
	mov	3, %g2
	st	%g2, [%sp+92]
	mov	1, %g2
	st	%g2, [%sp+96]
	mov	1, %o0
	mov	1, %o1
	mov	%g1, %o2
	mov	64, %o3
	mov	4, %o4
	mov	8, %o5
	call	apara_dma_start, 0
	 nop
	st	%g0, [%fp-12]
	b	.LL54
	 nop
.LL56:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL54:
	sethi	%hi(dma_interrupts), %g1
	or	%g1, %lo(dma_interrupts), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL55
	 nop
	ld	[%fp-12], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL56
	 nop
.LL55:
	st	%g0, [%fp-16]
	b	.LL57
	 nop
.LL58:
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL57:
	ld	[%fp-16], %g1
	cmp	%g1, 199
	ble	.LL58
	 nop
	sethi	%hi(dma_interrupts), %g1
	or	%g1, %lo(dma_interrupts), %g1
	ld	[%g1], %g1
	cmp	%g1, 1
	bne	.LL59
	 nop
	ld	[%fp-20], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL59:
	sethi	%hi(control_in_handler), %g1
	or	%g1, %lo(control_in_handler), %g1
	ld	[%g1], %g1
	and	%g1, 4, %g1
	cmp	%g1, 0
	be	.LL60
	 nop
	sethi	%hi(control_in_handler), %g1
	or	%g1, %lo(control_in_handler), %g1
	ld	[%g1], %g1
	and	%g1, 16, %g1
	cmp	%g1, 0
	bne	.LL60
	 nop
	ld	[%fp-20], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-20]
.LL60:
	mov	64, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %l1
	mov	68, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %l0
	mov	72, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g1
	st	%l1, [%fp-32]
	st	%l0, [%fp-28]
	st	%g1, [%fp-24]
	mov	1, %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-16]
	b	.LL61
	 nop
.LL62:
	ld	[%fp-16], %g1
	sra	%g1, 31, %g2
	and	%g2, 3, %g2
	add	%g2, %g1, %g1
	sra	%g1, 2, %g1
	sll	%g1, 2, %g1
	add	%fp, %g1, %g1
	ld	[%g1-32], %g3
	ld	[%fp-16], %g2
	sra	%g2, 31, %g1
	srl	%g1, 30, %g1
	add	%g2, %g1, %g2
	and	%g2, 3, %g2
	sub	%g2, %g1, %g1
	mov	3, %g2
	sub	%g2, %g1, %g1
	sll	%g1, 3, %g1
	srl	%g3, %g1, %g1
	and	%g1, 255, %g1
	st	%g1, [%fp-4]
	ld	[%fp-16], %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	nop
	nop
	nop
	sdiv	%g1, 3, %g1
	sll	%g1, 3, %g1
	add	%g1, 161, %g4
	ld	[%fp-16], %g2
	sra	%g2, 31, %g1
	wr	%g1, 0, %y
	nop
	nop
	nop
	sdiv	%g2, 3, %g3
	mov	%g3, %g1
	add	%g1, %g1, %g1
	add	%g1, %g3, %g1
	sub	%g2, %g1, %g1
	add	%g4, %g1, %g1
	mov	%g1, %g2
	ld	[%fp-4], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-8], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL61:
	ld	[%fp-16], %g1
	cmp	%g1, 11
	ble	.LL62
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 0
	be	.LL63
	 nop
	ld	[%fp-20], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-20]
.LL63:
	ld	[%fp-20], %o0
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
