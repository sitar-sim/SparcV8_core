	.file	"run_interrupt.c"
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
! 29 "validation/sparc_apara/basic/run_interrupt/../../../C/devices/devices_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL12:
	b	.LL12
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.type	apara_ccu_read, #function
	.proc	016
apara_ccu_read:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g2
	sethi	%hi(134213632), %g1
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
	.size	apara_ccu_read, .-apara_ccu_read
	.align 4
	.type	apara_ccu_write, #function
	.proc	020
apara_ccu_write:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %g2
	sethi	%hi(134213632), %g1
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
	.size	apara_ccu_write, .-apara_ccu_write
	.align 4
	.type	apara_ccu_start_command, #function
	.proc	020
apara_ccu_start_command:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+72], %g1
	sll	%g1, 8, %g2
	ld	[%fp+76], %g1
	or	%g2, %g1, %g1
	or	%g1, 17, %g1
	ld	[%fp+68], %o0
	mov	0, %o1
	mov	%g1, %o2
	call	apara_ccu_write, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_ccu_start_command, .-apara_ccu_start_command
	.align 4
	.type	apara_ccu_command_done, #function
	.proc	04
apara_ccu_command_done:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	0, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	and	%g1, 4, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_ccu_command_done, .-apara_ccu_command_done
	.align 4
	.type	apara_ccu_command, #function
	.proc	020
apara_ccu_command:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	mov	0, %o2
	call	apara_ccu_start_command, 0
	 nop
.LL23:
	ld	[%fp+68], %o0
	call	apara_ccu_command_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL23
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_ccu_command, .-apara_ccu_command
	.align 4
	.type	apara_write_imem, #function
	.proc	020
apara_write_imem:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	mov	0, %o0
	mov	2, %o1
	ld	[%fp+68], %o2
	call	apara_ccu_write, 0
	 nop
	mov	0, %o0
	mov	3, %o1
	ld	[%fp+72], %o2
	call	apara_ccu_write, 0
	 nop
	mov	0, %o0
	mov	2, %o1
	call	apara_ccu_command, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_write_imem, .-apara_write_imem
	.align 4
	.type	apara_load_program, #function
	.proc	020
apara_load_program:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%g0, [%fp-4]
	b	.LL28
	 nop
.LL29:
	ld	[%fp-4], %g1
	sll	%g1, 2, %g1
	ld	[%fp+68], %g2
	add	%g2, %g1, %g1
	ld	[%g1], %g1
	ld	[%fp-4], %o0
	mov	%g1, %o1
	call	apara_write_imem, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL28:
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	blu	.LL29
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_load_program, .-apara_load_program
	.align 4
	.type	apara_write_thread_register, #function
	.proc	020
apara_write_thread_register:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	std	%i2, [%fp-8]
	ld	[%fp+68], %o0
	mov	2, %o1
	ld	[%fp+72], %o2
	call	apara_ccu_write, 0
	 nop
	ld	[%fp-8], %g1
	srl	%g1, 0, %l1
	mov	0, %l0
	mov	%l1, %g1
	ld	[%fp+68], %o0
	mov	6, %o1
	mov	%g1, %o2
	call	apara_ccu_write, 0
	 nop
	ld	[%fp-4], %g1
	ld	[%fp+68], %o0
	mov	7, %o1
	mov	%g1, %o2
	call	apara_ccu_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	6, %o1
	call	apara_ccu_command, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_write_thread_register, .-apara_write_thread_register
	.align 4
	.type	apara_read_thread_register, #function
	.proc	017
apara_read_thread_register:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	mov	2, %o1
	ld	[%fp+72], %o2
	call	apara_ccu_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	5, %o1
	call	apara_ccu_command, 0
	 nop
	ld	[%fp+68], %o0
	mov	6, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	mov	0, %g2
	mov	%g1, %g3
	sll	%g3, 0, %l0
	mov	0, %l1
	ld	[%fp+68], %o0
	mov	7, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	mov	0, %g2
	mov	%g1, %g3
	or	%l0, %g2, %g2
	or	%l1, %g3, %g3
	mov	%g2, %i0
	mov	%g3, %i1
	restore
	jmp	%o7+8
	 nop
	.size	apara_read_thread_register, .-apara_read_thread_register
	.align 4
	.type	apara_start_thread, #function
	.proc	020
apara_start_thread:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	mov	1, %o1
	ld	[%fp+72], %o2
	call	apara_ccu_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	4, %o1
	call	apara_ccu_command, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_start_thread, .-apara_start_thread
	.align 4
	.type	apara_request_completion_interrupt, #function
	.proc	020
apara_request_completion_interrupt:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	7, %o1
	mov	8, %o2
	call	apara_ccu_start_command, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_request_completion_interrupt, .-apara_request_completion_interrupt
	.align 4
	.type	apara_thread_completion, #function
	.proc	016
apara_thread_completion:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	5, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_thread_completion, .-apara_thread_completion
	.align 4
	.type	apara_clear_interrupt, #function
	.proc	020
apara_clear_interrupt:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	0, %o1
	mov	16, %o2
	call	apara_ccu_write, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_clear_interrupt, .-apara_clear_interrupt
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
	b	.LL56
	 nop
.LL57:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL56:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL57
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
	bgu	.LL61
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL61:
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
	bleu	.LL63
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL63
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
	be	.LL63
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL63:
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
	be	.LL65
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL65:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_generic_interrupt_handler, .-ajit_generic_interrupt_handler
	.section	".rodata"
	.align 4
	.type	kernel_program, #object
	.size	kernel_program, 36
kernel_program:
	.long	-1995046911
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-335544320
	.global engine_interrupts
	.section	".bss"
	.align 4
	.type	engine_interrupts, #object
	.size	engine_interrupts, 4
engine_interrupts:
	.skip	4
	.global completion_in_handler
	.align 4
	.type	completion_in_handler, #object
	.size	completion_in_handler, 4
completion_in_handler:
	.skip	4
	.section	".text"
	.align 4
	.global engine_handler
	.type	engine_handler, #function
	.proc	020
engine_handler:
	save	%sp, -96, %sp
	mov	0, %o0
	call	apara_thread_completion, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(completion_in_handler), %g1
	or	%g1, %lo(completion_in_handler), %g1
	st	%g2, [%g1]
	mov	0, %o0
	call	apara_clear_interrupt, 0
	 nop
	sethi	%hi(engine_interrupts), %g1
	or	%g1, %lo(engine_interrupts), %g1
	ld	[%g1], %g1
	add	%g1, 1, %g2
	sethi	%hi(engine_interrupts), %g1
	or	%g1, %lo(engine_interrupts), %g1
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
	save	%sp, -112, %sp
	st	%g0, [%fp-12]
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
	sethi	%hi(kernel_program), %g1
	or	%g1, %lo(kernel_program), %o0
	mov	9, %o1
	call	apara_load_program, 0
	 nop
	mov	0, %o0
	mov	1, %o1
	mov	0, %o2
	mov	300, %o3
	call	apara_write_thread_register, 0
	 nop
	mov	0, %o0
	mov	0, %o1
	call	apara_start_thread, 0
	 nop
	mov	0, %o0
	call	apara_request_completion_interrupt, 0
	 nop
	mov	0, %o0
	call	apara_ccu_command_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL69
	 nop
	ld	[%fp-12], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL69:
	st	%g0, [%fp-8]
	b	.LL70
	 nop
.LL72:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL70:
	sethi	%hi(engine_interrupts), %g1
	or	%g1, %lo(engine_interrupts), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL71
	 nop
	ld	[%fp-8], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL72
	 nop
.LL71:
	st	%g0, [%fp-4]
	b	.LL73
	 nop
.LL74:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL73:
	ld	[%fp-4], %g1
	cmp	%g1, 199
	ble	.LL74
	 nop
	sethi	%hi(engine_interrupts), %g1
	or	%g1, %lo(engine_interrupts), %g1
	ld	[%g1], %g1
	cmp	%g1, 1
	bne	.LL75
	 nop
	ld	[%fp-12], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-12]
.LL75:
	sethi	%hi(completion_in_handler), %g1
	or	%g1, %lo(completion_in_handler), %g1
	ld	[%g1], %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL76
	 nop
	ld	[%fp-12], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-12]
.LL76:
	mov	0, %o0
	mov	1, %o1
	call	apara_read_thread_register, 0
	 nop
	mov	%o0, %g2
	mov	%o1, %g3
	cmp	%g2, -1
	bne	.LL77
	 nop
	cmp	%g3, -1
	bne	.LL77
	 nop
	ld	[%fp-12], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-12]
.LL77:
	ld	[%fp-12], %o0
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
