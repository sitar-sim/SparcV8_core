	.file	"console_under_lock.c"
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
	.type	__ajit_store_ubyte_mmu_bypass__, #function
	.proc	020
__ajit_store_ubyte_mmu_bypass__:
	save	%sp, -96, %sp
	mov	%i0, %g1
	st	%i1, [%fp+72]
	stb	%g1, [%fp+68]
	ldub	[%fp+68], %g1
	ld	[%fp+72], %g2
! 48 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_access_routines.h" 1
	stba %g1, [%g2] 32
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_store_ubyte_mmu_bypass__, .-__ajit_store_ubyte_mmu_bypass__
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
	.type	__ajit_write_serial_tx_register_via_bypass__, #function
	.proc	020
__ajit_write_serial_tx_register_via_bypass__:
	save	%sp, -96, %sp
	mov	%i0, %g1
	stb	%g1, [%fp+68]
	ldub	[%fp+68], %g1
	and	%g1, 0xff, %g1
	mov	%g1, %o0
	sethi	%hi(-53248), %g1
	or	%g1, 516, %o1
	call	__ajit_store_ubyte_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_write_serial_tx_register_via_bypass__, .-__ajit_write_serial_tx_register_via_bypass__
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
	be	.LL18
	 nop
	ld	[%fp-4], %g1
	or	%g1, 1, %g1
	b	.LL19
	 nop
.LL18:
	ld	[%fp-4], %g1
	and	%g1, -2, %g1
.LL19:
	st	%g1, [%fp-4]
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL20
	 nop
	ld	[%fp-4], %g1
	or	%g1, 2, %g1
	b	.LL21
	 nop
.LL20:
	ld	[%fp-4], %g1
	and	%g1, -3, %g1
.LL21:
	st	%g1, [%fp-4]
	ldub	[%fp+76], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL22
	 nop
	ld	[%fp-4], %g1
	or	%g1, 4, %g1
	b	.LL23
	 nop
.LL22:
	ld	[%fp-4], %g1
	and	%g1, -5, %g1
.LL23:
	st	%g1, [%fp-4]
	ld	[%fp-4], %o0
	call	__ajit_write_serial_control_register_via_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_serial_configure_via_bypass__, .-__ajit_serial_configure_via_bypass__
	.align 4
	.type	__ajit_serial_putchar_via_bypass__, #function
	.proc	04
__ajit_serial_putchar_via_bypass__:
	save	%sp, -104, %sp
	mov	%i0, %g1
	stb	%g1, [%fp+68]
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	and	%g1, 1, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL26
	 nop
	ld	[%fp-4], %g1
	and	%g1, 8, %g1
	cmp	%g1, 0
	bne	.LL26
	 nop
	ldub	[%fp+68], %g1
	and	%g1, 0xff, %g1
	mov	%g1, %o0
	call	__ajit_write_serial_tx_register_via_bypass__, 0
	 nop
	mov	1, %g1
	b	.LL27
	 nop
.LL26:
	mov	0, %g1
.LL27:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_serial_putchar_via_bypass__, .-__ajit_serial_putchar_via_bypass__
	.align 4
	.type	__ajit_serial_puts_via_bypass__, #function
	.proc	020
__ajit_serial_puts_via_bypass__:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%g0, [%fp-4]
	b	.LL30
	 nop
.LL31:
	ld	[%fp+68], %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	ldub	[%g1], %g1
	sll	%g1, 24, %g1
	sra	%g1, 24, %g1
	mov	%g1, %o0
	call	__ajit_serial_putchar_via_bypass__, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL31
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL30:
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	bgeu	.LL33
	 nop
	ld	[%fp+68], %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	ldub	[%g1], %g1
	sll	%g1, 24, %g1
	sra	%g1, 24, %g1
	cmp	%g1, 0
	bne	.LL31
	 nop
.LL33:
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_serial_puts_via_bypass__, .-__ajit_serial_puts_via_bypass__
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
	b	.LL53
	 nop
.LL54:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL53:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL54
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
	bgu	.LL58
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL58:
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
	bleu	.LL60
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL60
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
	be	.LL60
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL60:
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
	be	.LL62
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL62:
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
	bgu	.LL64
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL65
	 nop
.LL64:
	mov	-1, %g1
.LL65:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 59 "validation/multicore/devices/console_under_lock/../../multicore_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL66:
	b	.LL66
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
	b	.LL73
	 nop
.LL74:
	ld	[%fp-4], %o0
	call	read_shared_byte, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL74
	 nop
.LL73:
	ld	[%fp-4], %o0
	call	atomic_ldstub, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL74
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
	bne	.LL81
	 nop
	ld	[%fp+68], %g1
	st	%g0, [%g1+4]
	call	memory_fence, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+8]
	b	.LL83
	 nop
.LL81:
	ld	[%fp+68], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bne	.LL81
	 nop
.LL83:
	restore
	jmp	%o7+8
	 nop
	.size	barrier_wait, .-barrier_wait
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
	.type	interrupts_off, #function
	.proc	016
interrupts_off:
	save	%sp, -104, %sp
	mov	3840, %g3
! 35 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_platform.h" 1
	rd %psr, %g2
	or %g2, %g3, %g1
	wr %g1, %psr
	nop
	nop
	nop
! 0 "" 2
	st	%g2, [%fp-8]
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	and	%g1, 3840, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	interrupts_off, .-interrupts_off
	.align 4
	.type	interrupts_restore, #function
	.proc	020
interrupts_restore:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g2
	mov	3840, %g3
! 50 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_platform.h" 1
	rd %psr, %g1
	andn %g1, %g3, %g1
	or %g1, %g2, %g1
	wr %g1, %psr
	nop
	nop
	nop
! 0 "" 2
	st	%g1, [%fp-4]
	restore
	jmp	%o7+8
	 nop
	.size	interrupts_restore, .-interrupts_restore
	.align 4
	.type	platform_lock, #function
	.proc	016
platform_lock:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	interrupts_off, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_ldstub, 0
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	platform_lock, .-platform_lock
	.align 4
	.type	platform_unlock, #function
	.proc	020
platform_unlock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	release_mutex_using_ldstub, 0
	 nop
	ld	[%fp+72], %o0
	call	interrupts_restore, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	platform_unlock, .-platform_unlock
	.local	console_lock
	.common	console_lock,1,1
	.align 4
	.type	console_start, #function
	.proc	020
console_start:
	save	%sp, -96, %sp
	mov	1, %o0
	mov	0, %o1
	mov	0, %o2
	call	__ajit_serial_configure_via_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	console_start, .-console_start
	.align 4
	.type	console_puts, #function
	.proc	020
console_puts:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	sethi	%hi(console_lock), %g1
	or	%g1, %lo(console_lock), %o0
	call	platform_lock, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %o0
	mov	-1, %o1
	call	__ajit_serial_puts_via_bypass__, 0
	 nop
	sethi	%hi(console_lock), %g1
	or	%g1, %lo(console_lock), %o0
	ld	[%fp-4], %o1
	call	platform_unlock, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	console_puts, .-console_puts
	.align 4
	.type	console_wait_until_sent, #function
	.proc	020
console_wait_until_sent:
	save	%sp, -96, %sp
.LL103:
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	and	%g1, 8, %g1
	cmp	%g1, 0
	bne	.LL103
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	console_wait_until_sent, .-console_wait_until_sent
	.local	ipi_lock
	.common	ipi_lock,1,1
	.align 4
	.type	ipi_receive, #function
	.proc	0120
ipi_receive:
	save	%sp, -120, %sp
	st	%i0, [%fp+68]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	and	%g1, 0xff, %g1
	sethi	%hi(-53248), %g2
	or	%g2, 128, %o0
	mov	%g1, %o1
	mov	0, %o2
	call	ajitIpiMessageAddress, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-16]
	ld	[%fp-16], %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	sethi	%hi(ipi_lock), %g1
	or	%g1, %lo(ipi_lock), %o0
	call	platform_lock, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-20], %g1
	and	%g1, 0xff, %g1
	sethi	%hi(-53248), %g2
	or	%g2, 128, %o0
	mov	%g1, %o1
	mov	0, %o2
	call	__ajit_clear_ipi_interrupt__, 0
	 nop
	sethi	%hi(ipi_lock), %g1
	or	%g1, %lo(ipi_lock), %o0
	ld	[%fp-4], %o1
	call	platform_unlock, 0
	 nop
	ld	[%fp+68], %g1
	cmp	%g1, 0
	be	.LL106
	 nop
	ld	[%fp-12], %g1
	srl	%g1, 24, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1]
.LL106:
	ld	[%fp-8], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ipi_receive, .-ipi_receive
	.align 4
	.type	mmu_context, #function
	.proc	016
mmu_context:
	save	%sp, -104, %sp
	mov	512, %g1
! 179 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_platform.h" 1
	lda [%g1] 0x04, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	mmu_context, .-mmu_context
	.align 4
	.type	mmu_set_context, #function
	.proc	020
mmu_set_context:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	512, %g2
! 185 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_platform.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	mmu_set_context, .-mmu_set_context
	.align 4
	.type	tlb_flush_page, #function
	.proc	020
tlb_flush_page:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	interrupts_off, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	call	mmu_context, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+72], %o0
	call	mmu_set_context, 0
	 nop
	ld	[%fp+68], %g1
	and	%g1, -4096, %g1
! 200 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_platform.h" 1
	sta %g0, [%g1] 0x03
! 0 "" 2
	ld	[%fp-4], %o0
	call	mmu_set_context, 0
	 nop
	ld	[%fp-8], %o0
	call	interrupts_restore, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	tlb_flush_page, .-tlb_flush_page
	.local	shootdown_lock
	.common	shootdown_lock,1,1
	.local	shootdown_va
	.common	shootdown_va,4,4
	.local	shootdown_context
	.common	shootdown_context,4,4
	.local	shootdown_number
	.common	shootdown_number,4,4
	.local	shootdown_done
	.common	shootdown_done,16,4
	.align 4
	.type	tlb_shootdown_ipi_handler, #function
	.proc	020
tlb_shootdown_ipi_handler:
	save	%sp, -104, %sp
	mov	0, %o0
	call	ipi_receive, 0
	 nop
	sethi	%hi(shootdown_va), %g1
	or	%g1, %lo(shootdown_va), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %l0
	sethi	%hi(shootdown_context), %g1
	or	%g1, %lo(shootdown_context), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	mov	%l0, %o0
	mov	%g1, %o1
	call	tlb_flush_page, 0
	 nop
	sethi	%hi(shootdown_number), %g1
	or	%g1, %lo(shootdown_number), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	sll	%g1, 2, %g2
	sethi	%hi(shootdown_done), %g1
	or	%g1, %lo(shootdown_done), %g1
	add	%g2, %g1, %g1
	ld	[%fp-4], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	tlb_shootdown_ipi_handler, .-tlb_shootdown_ipi_handler
	.local	barrier
	.common	barrier,28,4
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	sethi	%hi(1668247552), %g2
	or	%g2, 613, %g2
	sethi	%hi(540024832), %g3
	or	%g3, 108, %g3
	std	%g2, [%fp-24]
	sethi	%hi(1768842240), %g1
	or	%g1, 288, %g1
	st	%g1, [%fp-16]
	sethi	%hi(12288), %g1
	or	%g1, 10, %g1
	sth	%g1, [%fp-12]
	stb	%g0, [%fp-10]
	ld	[%fp-8], %g1
	cmp	%g1, 0
	bne	.LL117
	 nop
	call	console_start, 0
	 nop
.LL117:
	sethi	%hi(barrier), %g1
	or	%g1, %lo(barrier), %o0
	mov	4, %o1
	call	barrier_wait, 0
	 nop
	st	%g0, [%fp-4]
	b	.LL118
	 nop
.LL119:
	ld	[%fp-8], %g1
	add	%g1, 48, %g1
	stb	%g1, [%fp-19]
	ld	[%fp-4], %g1
	add	%g1, 48, %g1
	stb	%g1, [%fp-12]
	add	%fp, -24, %g1
	mov	%g1, %o0
	call	console_puts, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL118:
	ld	[%fp-4], %g1
	cmp	%g1, 2
	bleu	.LL119
	 nop
	sethi	%hi(barrier), %g1
	or	%g1, %lo(barrier), %o0
	mov	4, %o1
	call	barrier_wait, 0
	 nop
	call	console_wait_until_sent, 0
	 nop
	mov	1, %o0
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
