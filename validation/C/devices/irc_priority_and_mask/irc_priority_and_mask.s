	.file	"irc_priority_and_mask.c"
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
	.type	__ajit_write_serial_control_register_via_bypass__, #function
	.proc	020
__ajit_write_serial_control_register_via_bypass__:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	sethi	%hi(-53248), %g1
	or	%g1, 512, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_write_serial_control_register_via_bypass__, .-__ajit_write_serial_control_register_via_bypass__
	.align 4
	.type	__ajit_read_serial_control_register_via_bypass__, #function
	.proc	016
__ajit_read_serial_control_register_via_bypass__:
	save	%sp, -96, %sp
	sethi	%hi(-53248), %g1
	or	%g1, 512, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_read_serial_control_register_via_bypass__, .-__ajit_read_serial_control_register_via_bypass__
	.align 4
	.type	__ajit_read_serial_rx_register_via_bypass__, #function
	.proc	014
__ajit_read_serial_rx_register_via_bypass__:
	save	%sp, -96, %sp
	sethi	%hi(-53248), %g1
	or	%g1, 520, %o0
	call	__ajit_load_ubyte_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_read_serial_rx_register_via_bypass__, .-__ajit_read_serial_rx_register_via_bypass__
	.align 4
	.type	__ajit_serial_configure_via_bypass__, #function
	.proc	020
__ajit_serial_configure_via_bypass__:
	save	%sp, -104, %sp
	mov	%i0, %g3
	mov	%i1, %g2
	mov	%i2, %g1
	stb	%g3, [%fp+68]
	stb	%g2, [%fp+72]
	stb	%g1, [%fp+76]
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ldub	[%fp+68], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL20
	 nop
	ld	[%fp-4], %g1
	or	%g1, 1, %g1
	b	.LL21
	 nop
.LL20:
	ld	[%fp-4], %g1
	and	%g1, -2, %g1
.LL21:
	st	%g1, [%fp-4]
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL22
	 nop
	ld	[%fp-4], %g1
	or	%g1, 2, %g1
	b	.LL23
	 nop
.LL22:
	ld	[%fp-4], %g1
	and	%g1, -3, %g1
.LL23:
	st	%g1, [%fp-4]
	ldub	[%fp+76], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL24
	 nop
	ld	[%fp-4], %g1
	or	%g1, 4, %g1
	b	.LL25
	 nop
.LL24:
	ld	[%fp-4], %g1
	and	%g1, -5, %g1
.LL25:
	st	%g1, [%fp-4]
	ld	[%fp-4], %o0
	call	__ajit_write_serial_control_register_via_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_serial_configure_via_bypass__, .-__ajit_serial_configure_via_bypass__
	.align 4
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL28
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL29
	 nop
.LL28:
	mov	-1, %g1
.LL29:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 29 "validation/C/devices/irc_priority_and_mask/../devices_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL30:
	b	.LL30
	 nop
	.size	report_and_halt, .-report_and_halt
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
	b	.LL45
	 nop
.LL46:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL45:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL46
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
	bgu	.LL50
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL50:
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
	bleu	.LL52
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL52
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
	be	.LL52
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL52:
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
	be	.LL54
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL54:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_generic_interrupt_handler, .-ajit_generic_interrupt_handler
	.common	order,16,4
	.global count
	.section	".bss"
	.align 4
	.type	count, #object
	.size	count, 4
count:
	.skip	4
	.section	".text"
	.align 4
	.global timer_handler
	.type	timer_handler, #function
	.proc	020
timer_handler:
	save	%sp, -96, %sp
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	cmp	%g1, 3
	bgu	.LL56
	 nop
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	sethi	%hi(order), %g2
	or	%g2, %lo(order), %g2
	sll	%g1, 2, %g1
	mov	10, %g3
	st	%g3, [%g2+%g1]
.LL56:
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	add	%g1, 1, %g2
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	st	%g2, [%g1]
	mov	0, %o0
	call	__ajit_write_timer_control_register_via_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	timer_handler, .-timer_handler
	.align 4
	.global serial_handler
	.type	serial_handler, #function
	.proc	020
serial_handler:
	save	%sp, -96, %sp
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	cmp	%g1, 3
	bgu	.LL59
	 nop
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	sethi	%hi(order), %g2
	or	%g2, %lo(order), %g2
	sll	%g1, 2, %g1
	mov	12, %g3
	st	%g3, [%g2+%g1]
.LL59:
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	add	%g1, 1, %g2
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	st	%g2, [%g1]
	mov	0, %o0
	mov	0, %o1
	mov	0, %o2
	call	__ajit_serial_configure_via_bypass__, 0
	 nop
	call	__ajit_read_serial_rx_register_via_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	serial_handler, .-serial_handler
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -112, %sp
	st	%g0, [%fp-16]
	call	ajit_initialize_interrupt_handlers_to_null, 0
	 nop
	mov	10, %o0
	sethi	%hi(timer_handler), %g1
	or	%g1, %lo(timer_handler), %o1
	call	ajit_set_interrupt_handler, 0
	 nop
	mov	12, %o0
	sethi	%hi(serial_handler), %g1
	or	%g1, %lo(serial_handler), %o1
	call	ajit_set_interrupt_handler, 0
	 nop
	mov	3, %o0
	call	__ajit_write_timer_control_register_via_bypass__, 0
	 nop
	mov	0, %o0
	mov	1, %o1
	mov	1, %o2
	call	__ajit_serial_configure_via_bypass__, 0
	 nop
	st	%g0, [%fp-8]
	b	.LL62
	 nop
.LL64:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL62:
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	and	%g1, 16, %g1
	cmp	%g1, 0
	bne	.LL63
	 nop
	ld	[%fp-8], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL64
	 nop
.LL63:
	mov	0, %o0
	mov	0, %o1
	call	readInterruptControlRegister, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g2
	sethi	%hi(33554432), %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	be	.LL65
	 nop
	ld	[%fp-4], %g2
	sethi	%hi(134217728), %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	be	.LL65
	 nop
	ld	[%fp-16], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-16]
.LL65:
	mov	0, %o0
	mov	0, %o1
	sethi	%hi(4096), %g1
	or	%g1, 1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	st	%g0, [%fp-8]
	b	.LL66
	 nop
.LL68:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL66:
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	bne	.LL67
	 nop
	ld	[%fp-8], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL68
	 nop
.LL67:
	st	%g0, [%fp-12]
	b	.LL69
	 nop
.LL70:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL69:
	ld	[%fp-12], %g1
	cmp	%g1, 199
	ble	.LL70
	 nop
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	cmp	%g1, 1
	bne	.LL71
	 nop
	sethi	%hi(order), %g1
	or	%g1, %lo(order), %g1
	ld	[%g1], %g1
	cmp	%g1, 12
	bne	.LL71
	 nop
	ld	[%fp-16], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL71:
	mov	0, %o0
	mov	0, %o1
	call	disableInterruptController, 0
	 nop
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	st	%g0, [%g1]
	mov	0, %o0
	mov	1, %o1
	mov	1, %o2
	call	__ajit_serial_configure_via_bypass__, 0
	 nop
	st	%g0, [%fp-8]
	b	.LL72
	 nop
.LL74:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL72:
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	and	%g1, 16, %g1
	cmp	%g1, 0
	bne	.LL73
	 nop
	ld	[%fp-8], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL74
	 nop
.LL73:
	mov	0, %o0
	mov	0, %o1
	sethi	%hi(5120), %g1
	or	%g1, 1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	st	%g0, [%fp-8]
	b	.LL75
	 nop
.LL77:
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL75:
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	cmp	%g1, 1
	bgu	.LL76
	 nop
	ld	[%fp-8], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL77
	 nop
.LL76:
	st	%g0, [%fp-12]
	b	.LL78
	 nop
.LL79:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL78:
	ld	[%fp-12], %g1
	cmp	%g1, 199
	ble	.LL79
	 nop
	sethi	%hi(order), %g1
	or	%g1, %lo(order), %g1
	ld	[%g1], %g1
	cmp	%g1, 10
	bne	.LL80
	 nop
	sethi	%hi(order), %g1
	or	%g1, %lo(order), %g1
	ld	[%g1+4], %g1
	cmp	%g1, 12
	bne	.LL80
	 nop
	ld	[%fp-16], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-16]
.LL80:
	sethi	%hi(count), %g1
	or	%g1, %lo(count), %g1
	ld	[%g1], %g1
	cmp	%g1, 2
	bne	.LL81
	 nop
	ld	[%fp-16], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-16]
.LL81:
	ld	[%fp-16], %o0
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
