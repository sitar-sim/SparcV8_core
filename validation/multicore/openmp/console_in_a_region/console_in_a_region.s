	.file	"console_in_a_region.c"
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
	.type	atomic_swap, #function
	.proc	016
atomic_swap:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g2
	ld	[%fp+72], %g1
! 52 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/multicore_sync.h" 1
	swap [%g2], %g1
! 0 "" 2
	st	%g1, [%fp+72]
	ld	[%fp+72], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	atomic_swap, .-atomic_swap
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
	b	.LL47
	 nop
.LL48:
	ld	[%fp-4], %o0
	call	read_shared_byte, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL48
	 nop
.LL47:
	ld	[%fp-4], %o0
	call	atomic_ldstub, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL48
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
	.type	acquire_mutex_using_swap, #function
	.proc	020
acquire_mutex_using_swap:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	st	%g1, [%fp-4]
	b	.LL53
	 nop
.LL54:
	ld	[%fp-4], %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL54
	 nop
.LL53:
	ld	[%fp-4], %o0
	mov	1, %o1
	call	atomic_swap, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL54
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	acquire_mutex_using_swap, .-acquire_mutex_using_swap
	.align 4
	.type	release_mutex_using_swap, #function
	.proc	020
release_mutex_using_swap:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	memory_fence, 0
	 nop
	ld	[%fp+68], %g1
	st	%g0, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	release_mutex_using_swap, .-release_mutex_using_swap
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
	b	.LL73
	 nop
.LL74:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL73:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL74
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
	bgu	.LL78
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL78:
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
	bleu	.LL80
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL80
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
	be	.LL80
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL80:
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
	be	.LL82
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL82:
	restore
	jmp	%o7+8
	 nop
	.size	ajit_generic_interrupt_handler, .-ajit_generic_interrupt_handler
	.local	omp_team
	.common	omp_team,424,4
	.local	omp_threads
	.common	omp_threads,2576,4
	.local	omp_go
	.common	omp_go,16,4
	.local	omp_core_online
	.common	omp_core_online,16,4
	.section	".data"
	.align 4
	.type	omp_num_procs, #object
	.size	omp_num_procs, 4
omp_num_procs:
	.long	1
	.local	omp_critical_lock
	.common	omp_critical_lock,4,4
	.local	omp_atomic_lock
	.common	omp_atomic_lock,4,4
	.section	".text"
	.align 4
	.type	omp_this_thread, #function
	.proc	0110
omp_this_thread:
	save	%sp, -96, %sp
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	smul	%g1, 644, %g2
	sethi	%hi(omp_threads), %g1
	or	%g1, %lo(omp_threads), %g1
	add	%g2, %g1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_this_thread, .-omp_this_thread
	.align 4
	.type	omp_read, #function
	.proc	04
omp_read:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_read, .-omp_read
	.align 4
	.type	omp_in_shared_team, #function
	.proc	04
omp_in_shared_team:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL88
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+12], %g1
	cmp	%g1, 0
	bne	.LL88
	 nop
	mov	1, %g1
	b	.LL89
	 nop
.LL88:
	mov	0, %g1
.LL89:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_in_shared_team, .-omp_in_shared_team
	.align 4
	.type	omp_current_team_size, #function
	.proc	016
omp_current_team_size:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	call	omp_in_shared_team, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL92
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+8], %g1
	b	.LL93
	 nop
.LL92:
	mov	1, %g1
.LL93:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_current_team_size, .-omp_current_team_size
	.align 4
	.type	omp_current_thread_num, #function
	.proc	016
omp_current_thread_num:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	call	omp_in_shared_team, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL96
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	b	.LL97
	 nop
.LL96:
	mov	0, %g1
.LL97:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_current_thread_num, .-omp_current_thread_num
	.align 4
	.type	omp_halt_this_core, #function
	.proc	020
omp_halt_this_core:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	ld	[%fp+72], %g2
! 223 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/omp.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL100:
	b	.LL100
	 nop
	.size	omp_halt_this_core, .-omp_halt_this_core
	.align 4
	.type	omp_stop_workers, #function
	.proc	020
omp_stop_workers:
	save	%sp, -104, %sp
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL103
	 nop
.LL104:
	ld	[%fp-4], %g1
	sethi	%hi(omp_go), %g2
	or	%g2, %lo(omp_go), %g2
	sll	%g1, 2, %g1
	mov	2, %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL103:
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	ld	[%fp-4], %g2
	cmp	%g2, %g1
	blu	.LL104
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_stop_workers, .-omp_stop_workers
	.align 4
	.type	omp_fatal, #function
	.proc	020
omp_fatal:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	omp_stop_workers, 0
	 nop
	ld	[%fp+68], %o0
	mov	0, %o1
	call	omp_halt_this_core, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_fatal, .-omp_fatal
	.align 4
	.type	omp_barrier, #function
	.proc	020
omp_barrier:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	call	omp_current_team_size, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, 1
	bleu	.LL113
	 nop
.LL109:
	sethi	%hi(omp_team+36), %g1
	or	%g1, %lo(omp_team+36), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	sethi	%hi(omp_team+28), %g1
	or	%g1, %lo(omp_team+28), %o0
	mov	1, %o1
	call	atomic_fetch_and_add, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	add	%g1, -1, %g1
	cmp	%g2, %g1
	bne	.LL111
	 nop
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	st	%g0, [%g1+32]
	call	memory_fence, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g2
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	st	%g2, [%g1+36]
	b	.LL112
	 nop
.LL111:
	sethi	%hi(omp_team+36), %g1
	or	%g1, %lo(omp_team+36), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL111
	 nop
	b	.LL112
	 nop
.LL113:
	nop
.LL112:
	restore
	jmp	%o7+8
	 nop
	.size	omp_barrier, .-omp_barrier
	.align 4
	.type	omp_context, #function
	.proc	0110
omp_context:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	add	%g1, 32, %g2
	ld	[%fp+68], %g1
	ld	[%g1+12], %g1
	sll	%g1, 2, %g1
	sll	%g1, 2, %g3
	add	%g1, %g3, %g1
	add	%g2, %g1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_context, .-omp_context
	.align 4
	.type	omp_current_work_share, #function
	.proc	0110
omp_current_work_share:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	call	omp_in_shared_team, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL117
	 nop
	ld	[%fp+68], %o0
	call	omp_context, 0
	 nop
	mov	%o0, %g1
	ld	[%g1], %g1
	and	%g1, 7, %g2
	mov	%g2, %g1
	add	%g1, %g1, %g1
	add	%g1, %g2, %g1
	sll	%g1, 4, %g1
	mov	%g1, %g2
	sethi	%hi(omp_team+40), %g1
	or	%g1, %lo(omp_team+40), %g1
	add	%g2, %g1, %g1
	b	.LL118
	 nop
.LL117:
	ld	[%fp+68], %g1
	add	%g1, 212, %g3
	ld	[%fp+68], %g1
	ld	[%g1+12], %g2
	mov	%g2, %g1
	add	%g1, %g1, %g1
	add	%g1, %g2, %g1
	sll	%g1, 4, %g1
	add	%g3, %g1, %g1
.LL118:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_current_work_share, .-omp_current_work_share
	.align 4
	.type	omp_enter_work_share, #function
	.proc	0110
omp_enter_work_share:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	call	omp_context, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	ld	[%fp-12], %g1
	ld	[%g1], %g1
	add	%g1, 1, %g2
	ld	[%fp-12], %g1
	st	%g2, [%g1]
	ld	[%fp-12], %g1
	st	%g0, [%g1+4]
	ld	[%fp-12], %g1
	st	%g0, [%g1+8]
	ld	[%fp+68], %o0
	call	omp_current_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %o0
	call	omp_in_shared_team, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL121
	 nop
	ld	[%fp-8], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-8], %g1
	b	.LL122
	 nop
.LL121:
	ld	[%fp-12], %g1
	ld	[%g1], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	b	.LL128
	 nop
.LL130:
	nop
.LL128:
	ld	[%fp-8], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bne	.LL123
	 nop
	ld	[%fp+72], %g1
	st	%g0, [%g1]
	ld	[%fp-8], %g1
	b	.LL122
	 nop
.LL123:
	ld	[%fp-8], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL124
	 nop
	ld	[%fp-8], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+68], %g1
	ld	[%g1+8], %g1
	cmp	%g2, %g1
	bne	.LL125
	 nop
.LL124:
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+4]
	ld	[%fp-8], %g1
	st	%g0, [%g1+8]
	ld	[%fp+72], %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-8], %g1
	b	.LL122
	 nop
.LL125:
	ld	[%fp-8], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
.LL127:
	ld	[%fp-8], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL130
	 nop
	ld	[%fp-8], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+68], %g1
	ld	[%g1+8], %g1
	cmp	%g2, %g1
	bne	.LL127
	 nop
	b	.LL128
	 nop
.LL122:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_enter_work_share, .-omp_enter_work_share
	.align 4
	.type	omp_release_ordered_turn, #function
	.proc	020
omp_release_ordered_turn:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g1
	ld	[%g1+8], %g1
	cmp	%g1, 0
	be	.LL134
	 nop
.LL133:
	ld	[%fp+72], %g1
	add	%g1, 40, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+68], %g1
	ld	[%g1+12], %g1
	cmp	%g2, %g1
	bne	.LL133
	 nop
	call	memory_fence, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+16], %g2
	ld	[%fp+72], %g1
	st	%g2, [%g1+40]
	ld	[%fp+68], %g1
	st	%g0, [%g1+8]
.LL134:
	restore
	jmp	%o7+8
	 nop
	.size	omp_release_ordered_turn, .-omp_release_ordered_turn
	.align 4
	.type	omp_leave_work_share, #function
	.proc	020
omp_leave_work_share:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	call	omp_current_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %o0
	call	omp_context, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	ld	[%fp-4], %o1
	call	omp_release_ordered_turn, 0
	 nop
	ld	[%fp+68], %o0
	call	omp_in_shared_team, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL137
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	add	%g1, 1, %g2
	ld	[%fp-4], %g1
	st	%g2, [%g1+8]
	ld	[%fp-4], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
.LL137:
	restore
	jmp	%o7+8
	 nop
	.size	omp_leave_work_share, .-omp_leave_work_share
	.align 4
	.type	omp_fill_in_loop, #function
	.proc	020
omp_fill_in_loop:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+72], %g1
	cmp	%g1, 4
	bne	.LL139
	 nop
	mov	1, %g1
	st	%g1, [%fp+72]
.LL139:
	ld	[%fp+72], %g1
	cmp	%g1, 1
	be	.LL140
	 nop
	ld	[%fp+88], %g1
	cmp	%g1, 0
	bg	.LL140
	 nop
	mov	1, %g1
	st	%g1, [%fp+88]
.LL140:
	ld	[%fp+68], %g1
	ld	[%fp+72], %g2
	st	%g2, [%g1+12]
	ld	[%fp+68], %g1
	ld	[%fp+76], %g2
	st	%g2, [%g1+32]
	ld	[%fp+68], %g1
	ld	[%fp+76], %g2
	st	%g2, [%g1+16]
	ld	[%fp+68], %g1
	ld	[%fp+80], %g2
	st	%g2, [%g1+20]
	ld	[%fp+68], %g1
	ld	[%fp+84], %g2
	st	%g2, [%g1+24]
	ld	[%fp+68], %g1
	ld	[%fp+88], %g2
	st	%g2, [%g1+28]
	ld	[%fp+68], %g1
	ld	[%fp+92], %g2
	st	%g2, [%g1+36]
	ld	[%fp+68], %g1
	ld	[%fp+76], %g2
	st	%g2, [%g1+40]
	restore
	jmp	%o7+8
	 nop
	.size	omp_fill_in_loop, .-omp_fill_in_loop
	.align 4
	.type	omp_iterations_between, #function
	.proc	04
omp_iterations_between:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+76], %g1
	cmp	%g1, 0
	ble	.LL143
	 nop
	ld	[%fp+72], %g2
	ld	[%fp+68], %g1
	sub	%g2, %g1, %g2
	ld	[%fp+76], %g1
	add	%g2, %g1, %g1
	add	%g1, -1, %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	ld	[%fp+76], %g2
	nop
	nop
	sdiv	%g1, %g2, %g1
	b	.LL144
	 nop
.LL143:
	ld	[%fp+68], %g2
	ld	[%fp+72], %g1
	sub	%g2, %g1, %g2
	ld	[%fp+76], %g1
	sub	%g2, %g1, %g1
	add	%g1, -1, %g2
	ld	[%fp+76], %g1
	sub	%g0, %g1, %g1
	sra	%g2, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g2, %g1, %g1
.LL144:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_iterations_between, .-omp_iterations_between
	.align 4
	.type	omp_take_static_chunk, #function
	.proc	04
omp_take_static_chunk:
	save	%sp, -144, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	ld	[%fp+68], %o0
	call	omp_context, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-48]
	ld	[%fp+72], %g1
	add	%g1, 32, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-44]
	ld	[%fp+72], %g1
	add	%g1, 20, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-40]
	ld	[%fp+72], %g1
	add	%g1, 24, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-36]
	ld	[%fp+72], %g1
	add	%g1, 28, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-32]
	ld	[%fp-44], %o0
	ld	[%fp-40], %o1
	ld	[%fp-36], %o2
	call	omp_iterations_between, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-28]
	ld	[%fp+68], %o0
	call	omp_current_thread_num, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-24]
	ld	[%fp+68], %o0
	call	omp_current_team_size, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-20]
	ld	[%fp-32], %g1
	cmp	%g1, 0
	bg	.LL147
	 nop
	ld	[%fp-28], %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	ld	[%fp-20], %g2
	nop
	nop
	sdiv	%g1, %g2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-28], %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	ld	[%fp-20], %g2
	nop
	nop
	sdiv	%g1, %g2, %g3
	ld	[%fp-20], %g2
	smul	%g3, %g2, %g2
	sub	%g1, %g2, %g1
	st	%g1, [%fp-4]
	ld	[%fp-48], %g1
	ld	[%g1+4], %g1
	cmp	%g1, 0
	be	.LL148
	 nop
	mov	0, %g1
	b	.LL149
	 nop
.LL148:
	ld	[%fp-24], %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bge	.LL150
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-4]
.LL150:
	ld	[%fp-8], %g2
	ld	[%fp-24], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-16]
	ld	[%fp-16], %g2
	ld	[%fp-8], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	b	.LL151
	 nop
.LL147:
	ld	[%fp-48], %g1
	ld	[%g1+4], %g2
	ld	[%fp-20], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-24], %g1
	add	%g2, %g1, %g2
	ld	[%fp-32], %g1
	smul	%g2, %g1, %g1
	st	%g1, [%fp-16]
	ld	[%fp-16], %g2
	ld	[%fp-32], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
.LL151:
	ld	[%fp-48], %g1
	ld	[%g1+4], %g1
	add	%g1, 1, %g2
	ld	[%fp-48], %g1
	st	%g2, [%g1+4]
	ld	[%fp-16], %g2
	ld	[%fp-28], %g1
	cmp	%g2, %g1
	bl	.LL152
	 nop
	mov	0, %g1
	b	.LL149
	 nop
.LL152:
	ld	[%fp-16], %g2
	ld	[%fp-36], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-44], %g1
	add	%g2, %g1, %g2
	ld	[%fp+76], %g1
	st	%g2, [%g1]
	ld	[%fp-12], %g2
	ld	[%fp-28], %g1
	cmp	%g2, %g1
	bge	.LL153
	 nop
	ld	[%fp-12], %g2
	ld	[%fp-36], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-44], %g1
	add	%g2, %g1, %g1
	b	.LL154
	 nop
.LL153:
	ld	[%fp-40], %g1
.LL154:
	ld	[%fp+80], %g2
	st	%g1, [%g2]
	mov	1, %g1
.LL149:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_take_static_chunk, .-omp_take_static_chunk
	.align 4
	.type	omp_take_shared_chunk, #function
	.proc	04
omp_take_shared_chunk:
	save	%sp, -128, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%g0, [%fp-12]
	ld	[%fp+72], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	ld	[%fp+72], %g1
	add	%g1, 16, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-32]
	ld	[%fp+72], %g1
	add	%g1, 20, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-28]
	ld	[%fp+72], %g1
	add	%g1, 24, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-24]
	ld	[%fp+72], %g1
	add	%g1, 28, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-20]
	ld	[%fp-32], %o0
	ld	[%fp-28], %o1
	ld	[%fp-24], %o2
	call	omp_iterations_between, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-16]
	ld	[%fp-16], %g1
	cmp	%g1, 0
	ble	.LL157
	 nop
	ld	[%fp+72], %g1
	add	%g1, 12, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 3
	bne	.LL158
	 nop
	ld	[%fp+68], %o0
	call	omp_current_team_size, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-16], %g2
	ld	[%fp-8], %g1
	add	%g2, %g1, %g1
	add	%g1, -1, %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	ld	[%fp-8], %g2
	nop
	nop
	sdiv	%g1, %g2, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g2
	ld	[%fp-20], %g1
	cmp	%g2, %g1
	ble	.LL158
	 nop
	ld	[%fp-4], %g1
	st	%g1, [%fp-20]
.LL158:
	ld	[%fp+76], %g1
	ld	[%fp-32], %g2
	st	%g2, [%g1]
	ld	[%fp-20], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bge	.LL159
	 nop
	ld	[%fp-20], %g2
	ld	[%fp-24], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-32], %g1
	add	%g2, %g1, %g1
	b	.LL160
	 nop
.LL159:
	ld	[%fp-28], %g1
.LL160:
	ld	[%fp+80], %g2
	st	%g1, [%g2]
	ld	[%fp+80], %g1
	ld	[%g1], %g2
	ld	[%fp+72], %g1
	st	%g2, [%g1+16]
	mov	1, %g1
	st	%g1, [%fp-12]
.LL157:
	ld	[%fp+72], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	ld	[%fp-12], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_take_shared_chunk, .-omp_take_shared_chunk
	.align 4
	.type	omp_take_chunk, #function
	.proc	04
omp_take_chunk:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %o0
	call	omp_current_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	ld	[%fp+68], %o0
	call	omp_context, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %o0
	ld	[%fp-12], %o1
	call	omp_release_ordered_turn, 0
	 nop
	ld	[%fp-12], %g1
	add	%g1, 12, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL163
	 nop
	ld	[%fp+68], %o0
	ld	[%fp-12], %o1
	ld	[%fp+72], %o2
	ld	[%fp+76], %o3
	call	omp_take_static_chunk, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	b	.LL164
	 nop
.LL163:
	ld	[%fp+68], %o0
	ld	[%fp-12], %o1
	ld	[%fp+72], %o2
	ld	[%fp+76], %o3
	call	omp_take_shared_chunk, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
.LL164:
	ld	[%fp-4], %g1
	cmp	%g1, 0
	be	.LL165
	 nop
	ld	[%fp-12], %g1
	add	%g1, 36, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL165
	 nop
	ld	[%fp-8], %g1
	mov	1, %g2
	st	%g2, [%g1+8]
	ld	[%fp+72], %g1
	ld	[%g1], %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+12]
	ld	[%fp+76], %g1
	ld	[%g1], %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+16]
.LL165:
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_take_chunk, .-omp_take_chunk
	.align 4
	.type	omp_start_loop, #function
	.proc	04
omp_start_loop:
	save	%sp, -120, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	add	%fp, -12, %g1
	ld	[%fp-8], %o0
	mov	%g1, %o1
	call	omp_enter_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL168
	 nop
	ld	[%fp+68], %g1
	ld	[%fp+72], %g2
	st	%g2, [%sp+92]
	ld	[%fp-4], %o0
	mov	%g1, %o1
	ld	[%fp+76], %o2
	ld	[%fp+80], %o3
	ld	[%fp+84], %o4
	ld	[%fp+88], %o5
	call	omp_fill_in_loop, 0
	 nop
.LL168:
	ld	[%fp-4], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	ld	[%fp-8], %o0
	ld	[%fp+92], %o1
	ld	[%fp+96], %o2
	call	omp_take_chunk, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_start_loop, .-omp_start_loop
	.align 4
	.type	omp_next_chunk, #function
	.proc	04
omp_next_chunk:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	ld	[%fp+68], %o1
	ld	[%fp+72], %o2
	call	omp_take_chunk, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_next_chunk, .-omp_next_chunk
	.align 4
	.type	omp_start_region, #function
	.proc	020
omp_start_region:
	save	%sp, -128, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-16]
	ld	[%fp+76], %g1
	cmp	%g1, 0
	bne	.LL173
	 nop
	ld	[%fp-16], %g1
	ld	[%g1+20], %g1
	b	.LL174
	 nop
.LL173:
	ld	[%fp+76], %g1
.LL174:
	st	%g1, [%fp-8]
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	ld	[%fp-8], %g2
	cmp	%g2, %g1
	bleu	.LL175
	 nop
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	st	%g1, [%fp-8]
.LL175:
	ld	[%fp-8], %g1
	cmp	%g1, 1
	bleu	.LL176
	 nop
	ld	[%fp-16], %g1
	ld	[%g1+16], %g1
	cmp	%g1, 0
	be	.LL177
	 nop
.LL176:
	ld	[%fp-16], %g1
	ld	[%g1+12], %g1
	cmp	%g1, 8
	bne	.LL178
	 nop
	sethi	%hi(-1160715264), %g1
	or	%g1, 369, %o0
	call	omp_fatal, 0
	 nop
.LL178:
	ld	[%fp-16], %g1
	ld	[%g1+12], %g1
	add	%g1, 1, %g2
	ld	[%fp-16], %g1
	st	%g2, [%g1+12]
	ld	[%fp-16], %g1
	ld	[%g1+16], %g1
	add	%g1, 1, %g2
	ld	[%fp-16], %g1
	st	%g2, [%g1+16]
	ld	[%fp-16], %o0
	call	omp_context, 0
	 nop
	mov	%o0, %g1
	mov	-1, %g2
	st	%g2, [%g1]
	ld	[%fp+80], %g1
	cmp	%g1, 0
	be	.LL187
	 nop
	add	%fp, -20, %g1
	ld	[%fp-16], %o0
	mov	%g1, %o1
	call	omp_enter_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+84], %g1
	st	%g0, [%sp+92]
	ld	[%fp-4], %o0
	mov	%g1, %o1
	ld	[%fp+88], %o2
	ld	[%fp+92], %o3
	ld	[%fp+96], %o4
	ld	[%fp+100], %o5
	call	omp_fill_in_loop, 0
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	b	.LL186
	 nop
.LL177:
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	ld	[%fp+68], %g2
	st	%g2, [%g1]
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	ld	[%fp+72], %g2
	st	%g2, [%g1+4]
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1+8]
	ld	[%fp-16], %g1
	ld	[%g1+20], %g2
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	st	%g2, [%g1+16]
	ld	[%fp-16], %g1
	ld	[%g1+24], %g2
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	st	%g2, [%g1+20]
	ld	[%fp-16], %g1
	ld	[%g1+28], %g2
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	st	%g2, [%g1+24]
	st	%g0, [%fp-12]
	b	.LL181
	 nop
.LL182:
	ld	[%fp-12], %g2
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g3
	mov	%g2, %g1
	add	%g1, %g1, %g1
	add	%g1, %g2, %g1
	sll	%g1, 4, %g1
	add	%g3, %g1, %g1
	st	%g0, [%g1+44]
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL181:
	ld	[%fp-12], %g1
	cmp	%g1, 7
	bleu	.LL182
	 nop
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	mov	-1, %g2
	st	%g2, [%g1+12]
	ld	[%fp+80], %g1
	cmp	%g1, 0
	be	.LL183
	 nop
	ld	[%fp+84], %g1
	st	%g0, [%sp+92]
	sethi	%hi(omp_team+40), %g2
	or	%g2, %lo(omp_team+40), %o0
	mov	%g1, %o1
	ld	[%fp+88], %o2
	ld	[%fp+92], %o3
	ld	[%fp+96], %o4
	ld	[%fp+100], %o5
	call	omp_fill_in_loop, 0
	 nop
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	mov	1, %g2
	st	%g2, [%g1+44]
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	st	%g0, [%g1+48]
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	st	%g0, [%g1+12]
.LL183:
	ld	[%fp-16], %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-16], %g1
	st	%g0, [%g1+4]
	ld	[%fp-16], %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1+8]
	ld	[%fp-16], %g1
	mov	1, %g2
	st	%g2, [%g1+16]
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	ld	[%g1+12], %g2
	ld	[%fp-16], %g1
	st	%g2, [%g1+32]
	ld	[%fp-16], %g1
	st	%g0, [%g1+36]
	ld	[%fp-16], %g1
	st	%g0, [%g1+40]
	call	memory_fence, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-12]
	b	.LL184
	 nop
.LL185:
	ld	[%fp-12], %g1
	sethi	%hi(omp_go), %g2
	or	%g2, %lo(omp_go), %g2
	sll	%g1, 2, %g1
	mov	1, %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL184:
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	cmp	%g2, %g1
	blu	.LL185
	 nop
	b	.LL186
	 nop
.LL187:
	nop
.LL186:
	restore
	jmp	%o7+8
	 nop
	.size	omp_start_region, .-omp_start_region
	.align 4
	.type	omp_worker_loop, #function
	.proc	020
omp_worker_loop:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	smul	%g1, 644, %g2
	sethi	%hi(omp_threads), %g1
	or	%g1, %lo(omp_threads), %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-8]
.LL189:
	ld	[%fp+68], %g1
	sll	%g1, 2, %g2
	sethi	%hi(omp_go), %g1
	or	%g1, %lo(omp_go), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 0
	be	.LL189
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(omp_go), %g2
	or	%g2, %lo(omp_go), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	cmp	%g1, 2
	bne	.LL190
	 nop
	mov	1, %o0
	mov	0, %o1
	call	omp_halt_this_core, 0
	 nop
.LL190:
	ld	[%fp-8], %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-8], %g1
	ld	[%fp+68], %g2
	st	%g2, [%g1+4]
	sethi	%hi(omp_team+8), %g1
	or	%g1, %lo(omp_team+8), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+8]
	ld	[%fp-8], %g1
	st	%g0, [%g1+12]
	ld	[%fp-8], %g1
	mov	1, %g2
	st	%g2, [%g1+16]
	sethi	%hi(omp_team+16), %g1
	or	%g1, %lo(omp_team+16), %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+20]
	sethi	%hi(omp_team+20), %g1
	or	%g1, %lo(omp_team+20), %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+24]
	sethi	%hi(omp_team+24), %g1
	or	%g1, %lo(omp_team+24), %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+28]
	sethi	%hi(omp_team+12), %g1
	or	%g1, %lo(omp_team+12), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+32]
	ld	[%fp-8], %g1
	st	%g0, [%g1+36]
	ld	[%fp-8], %g1
	st	%g0, [%g1+40]
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %l0
	sethi	%hi(omp_team+4), %g1
	or	%g1, %lo(omp_team+4), %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	%l0, 0
	 nop
	ld	[%fp-8], %o0
	call	omp_barrier, 0
	 nop
	ld	[%fp-8], %g1
	st	%g0, [%g1]
	b	.LL189
	 nop
	.size	omp_worker_loop, .-omp_worker_loop
	.align 4
	.global GOMP_parallel_start
	.type	GOMP_parallel_start, #function
	.proc	020
GOMP_parallel_start:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%g0, [%sp+92]
	mov	1, %g1
	st	%g1, [%sp+96]
	st	%g0, [%sp+100]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	ld	[%fp+76], %o2
	mov	0, %o3
	mov	1, %o4
	mov	0, %o5
	call	omp_start_region, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_start, .-GOMP_parallel_start
	.align 4
	.global GOMP_parallel_end
	.type	GOMP_parallel_end, #function
	.proc	020
GOMP_parallel_end:
	save	%sp, -104, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%g1+12], %g1
	cmp	%g1, 0
	be	.LL195
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+12], %g1
	add	%g1, -1, %g2
	ld	[%fp-4], %g1
	st	%g2, [%g1+12]
	ld	[%fp-4], %g1
	ld	[%g1+16], %g1
	add	%g1, -1, %g2
	ld	[%fp-4], %g1
	st	%g2, [%g1+16]
	b	.LL197
	 nop
.LL195:
	ld	[%fp-4], %o0
	call	omp_barrier, 0
	 nop
	ld	[%fp-4], %g1
	st	%g0, [%g1]
	ld	[%fp-4], %g1
	mov	1, %g2
	st	%g2, [%g1+8]
	ld	[%fp-4], %g1
	st	%g0, [%g1+16]
.LL197:
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_end, .-GOMP_parallel_end
	.align 4
	.global GOMP_barrier
	.type	GOMP_barrier, #function
	.proc	020
GOMP_barrier:
	save	%sp, -96, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	omp_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_barrier, .-GOMP_barrier
	.align 4
	.global GOMP_critical_start
	.type	GOMP_critical_start, #function
	.proc	020
GOMP_critical_start:
	save	%sp, -96, %sp
	sethi	%hi(omp_critical_lock), %g1
	or	%g1, %lo(omp_critical_lock), %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_critical_start, .-GOMP_critical_start
	.align 4
	.global GOMP_critical_end
	.type	GOMP_critical_end, #function
	.proc	020
GOMP_critical_end:
	save	%sp, -96, %sp
	sethi	%hi(omp_critical_lock), %g1
	or	%g1, %lo(omp_critical_lock), %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_critical_end, .-GOMP_critical_end
	.align 4
	.global GOMP_critical_name_start
	.type	GOMP_critical_name_start, #function
	.proc	020
GOMP_critical_name_start:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_critical_name_start, .-GOMP_critical_name_start
	.align 4
	.global GOMP_critical_name_end
	.type	GOMP_critical_name_end, #function
	.proc	020
GOMP_critical_name_end:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_critical_name_end, .-GOMP_critical_name_end
	.align 4
	.global GOMP_atomic_start
	.type	GOMP_atomic_start, #function
	.proc	020
GOMP_atomic_start:
	save	%sp, -96, %sp
	sethi	%hi(omp_atomic_lock), %g1
	or	%g1, %lo(omp_atomic_lock), %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_atomic_start, .-GOMP_atomic_start
	.align 4
	.global GOMP_atomic_end
	.type	GOMP_atomic_end, #function
	.proc	020
GOMP_atomic_end:
	save	%sp, -96, %sp
	sethi	%hi(omp_atomic_lock), %g1
	or	%g1, %lo(omp_atomic_lock), %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_atomic_end, .-GOMP_atomic_end
	.align 4
	.global GOMP_ordered_start
	.type	GOMP_ordered_start, #function
	.proc	020
GOMP_ordered_start:
	save	%sp, -112, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	ld	[%fp-12], %o0
	call	omp_context, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %o0
	call	omp_current_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%g1+8], %g1
	cmp	%g1, 0
	be	.LL215
	 nop
.LL214:
	ld	[%fp-4], %g1
	add	%g1, 40, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	ld	[%g1+12], %g1
	cmp	%g2, %g1
	bne	.LL214
	 nop
.LL215:
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_ordered_start, .-GOMP_ordered_start
	.align 4
	.global GOMP_ordered_end
	.type	GOMP_ordered_end, #function
	.proc	020
GOMP_ordered_end:
	save	%sp, -96, %sp
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_ordered_end, .-GOMP_ordered_end
	.align 4
	.global GOMP_loop_static_start
	.type	GOMP_loop_static_start, #function
	.proc	00
GOMP_loop_static_start:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	mov	1, %o0
	mov	0, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	ld	[%fp+80], %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_static_start, .-GOMP_loop_static_start
	.align 4
	.global GOMP_loop_dynamic_start
	.type	GOMP_loop_dynamic_start, #function
	.proc	00
GOMP_loop_dynamic_start:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	mov	2, %o0
	mov	0, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	ld	[%fp+80], %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_dynamic_start, .-GOMP_loop_dynamic_start
	.align 4
	.global GOMP_loop_guided_start
	.type	GOMP_loop_guided_start, #function
	.proc	00
GOMP_loop_guided_start:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	mov	3, %o0
	mov	0, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	ld	[%fp+80], %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_guided_start, .-GOMP_loop_guided_start
	.align 4
	.global GOMP_loop_runtime_start
	.type	GOMP_loop_runtime_start, #function
	.proc	00
GOMP_loop_runtime_start:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%g1+24], %g1
	mov	%g1, %g2
	ld	[%fp-4], %g1
	ld	[%g1+28], %g1
	ld	[%fp+80], %g3
	st	%g3, [%sp+92]
	ld	[%fp+84], %g3
	st	%g3, [%sp+96]
	mov	%g2, %o0
	mov	0, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	mov	%g1, %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_runtime_start, .-GOMP_loop_runtime_start
	.align 4
	.global GOMP_loop_ordered_static_start
	.type	GOMP_loop_ordered_static_start, #function
	.proc	00
GOMP_loop_ordered_static_start:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	mov	1, %o0
	mov	1, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	ld	[%fp+80], %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_static_start, .-GOMP_loop_ordered_static_start
	.align 4
	.global GOMP_loop_ordered_dynamic_start
	.type	GOMP_loop_ordered_dynamic_start, #function
	.proc	00
GOMP_loop_ordered_dynamic_start:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	mov	2, %o0
	mov	1, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	ld	[%fp+80], %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_dynamic_start, .-GOMP_loop_ordered_dynamic_start
	.align 4
	.global GOMP_loop_ordered_guided_start
	.type	GOMP_loop_ordered_guided_start, #function
	.proc	00
GOMP_loop_ordered_guided_start:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	mov	3, %o0
	mov	1, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	ld	[%fp+80], %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_guided_start, .-GOMP_loop_ordered_guided_start
	.align 4
	.global GOMP_loop_ordered_runtime_start
	.type	GOMP_loop_ordered_runtime_start, #function
	.proc	00
GOMP_loop_ordered_runtime_start:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%g1+24], %g1
	mov	%g1, %g2
	ld	[%fp-4], %g1
	ld	[%g1+28], %g1
	ld	[%fp+80], %g3
	st	%g3, [%sp+92]
	ld	[%fp+84], %g3
	st	%g3, [%sp+96]
	mov	%g2, %o0
	mov	1, %o1
	ld	[%fp+68], %o2
	ld	[%fp+72], %o3
	ld	[%fp+76], %o4
	mov	%g1, %o5
	call	omp_start_loop, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_runtime_start, .-GOMP_loop_ordered_runtime_start
	.align 4
	.global GOMP_loop_static_next
	.type	GOMP_loop_static_next, #function
	.proc	00
GOMP_loop_static_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_static_next, .-GOMP_loop_static_next
	.align 4
	.global GOMP_loop_dynamic_next
	.type	GOMP_loop_dynamic_next, #function
	.proc	00
GOMP_loop_dynamic_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_dynamic_next, .-GOMP_loop_dynamic_next
	.align 4
	.global GOMP_loop_guided_next
	.type	GOMP_loop_guided_next, #function
	.proc	00
GOMP_loop_guided_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_guided_next, .-GOMP_loop_guided_next
	.align 4
	.global GOMP_loop_runtime_next
	.type	GOMP_loop_runtime_next, #function
	.proc	00
GOMP_loop_runtime_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_runtime_next, .-GOMP_loop_runtime_next
	.align 4
	.global GOMP_loop_ordered_static_next
	.type	GOMP_loop_ordered_static_next, #function
	.proc	00
GOMP_loop_ordered_static_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_static_next, .-GOMP_loop_ordered_static_next
	.align 4
	.global GOMP_loop_ordered_dynamic_next
	.type	GOMP_loop_ordered_dynamic_next, #function
	.proc	00
GOMP_loop_ordered_dynamic_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_dynamic_next, .-GOMP_loop_ordered_dynamic_next
	.align 4
	.global GOMP_loop_ordered_guided_next
	.type	GOMP_loop_ordered_guided_next, #function
	.proc	00
GOMP_loop_ordered_guided_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_guided_next, .-GOMP_loop_ordered_guided_next
	.align 4
	.global GOMP_loop_ordered_runtime_next
	.type	GOMP_loop_ordered_runtime_next, #function
	.proc	00
GOMP_loop_ordered_runtime_next:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_ordered_runtime_next, .-GOMP_loop_ordered_runtime_next
	.align 4
	.global GOMP_loop_end
	.type	GOMP_loop_end, #function
	.proc	020
GOMP_loop_end:
	save	%sp, -104, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %o0
	call	omp_leave_work_share, 0
	 nop
	ld	[%fp-4], %o0
	call	omp_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_end, .-GOMP_loop_end
	.align 4
	.global GOMP_loop_end_nowait
	.type	GOMP_loop_end_nowait, #function
	.proc	020
GOMP_loop_end_nowait:
	save	%sp, -96, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	omp_leave_work_share, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_loop_end_nowait, .-GOMP_loop_end_nowait
	.align 4
	.global GOMP_parallel_loop_static_start
	.type	GOMP_parallel_loop_static_start, #function
	.proc	020
GOMP_parallel_loop_static_start:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	ld	[%fp+92], %g1
	st	%g1, [%sp+100]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	ld	[%fp+76], %o2
	mov	1, %o3
	mov	1, %o4
	ld	[%fp+80], %o5
	call	omp_start_region, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_loop_static_start, .-GOMP_parallel_loop_static_start
	.align 4
	.global GOMP_parallel_loop_dynamic_start
	.type	GOMP_parallel_loop_dynamic_start, #function
	.proc	020
GOMP_parallel_loop_dynamic_start:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	ld	[%fp+92], %g1
	st	%g1, [%sp+100]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	ld	[%fp+76], %o2
	mov	1, %o3
	mov	2, %o4
	ld	[%fp+80], %o5
	call	omp_start_region, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_loop_dynamic_start, .-GOMP_parallel_loop_dynamic_start
	.align 4
	.global GOMP_parallel_loop_guided_start
	.type	GOMP_parallel_loop_guided_start, #function
	.proc	020
GOMP_parallel_loop_guided_start:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+84], %g1
	st	%g1, [%sp+92]
	ld	[%fp+88], %g1
	st	%g1, [%sp+96]
	ld	[%fp+92], %g1
	st	%g1, [%sp+100]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	ld	[%fp+76], %o2
	mov	1, %o3
	mov	3, %o4
	ld	[%fp+80], %o5
	call	omp_start_region, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_loop_guided_start, .-GOMP_parallel_loop_guided_start
	.align 4
	.global GOMP_parallel_loop_runtime_start
	.type	GOMP_parallel_loop_runtime_start, #function
	.proc	020
GOMP_parallel_loop_runtime_start:
	save	%sp, -120, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%g1+24], %g1
	ld	[%fp-4], %g2
	ld	[%g2+28], %g2
	ld	[%fp+84], %g3
	st	%g3, [%sp+92]
	ld	[%fp+88], %g3
	st	%g3, [%sp+96]
	st	%g2, [%sp+100]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	ld	[%fp+76], %o2
	mov	1, %o3
	mov	%g1, %o4
	ld	[%fp+80], %o5
	call	omp_start_region, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_loop_runtime_start, .-GOMP_parallel_loop_runtime_start
	.align 4
	.type	omp_next_section, #function
	.proc	016
omp_next_section:
	save	%sp, -104, %sp
	add	%fp, -4, %g2
	add	%fp, -8, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	omp_next_chunk, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL263
	 nop
	ld	[%fp-4], %g1
	b	.LL264
	 nop
.LL263:
	mov	0, %g1
.LL264:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_next_section, .-omp_next_section
	.align 4
	.global GOMP_sections_start
	.type	GOMP_sections_start, #function
	.proc	016
GOMP_sections_start:
	save	%sp, -120, %sp
	st	%i0, [%fp+68]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	add	%fp, -12, %g1
	ld	[%fp-8], %o0
	mov	%g1, %o1
	call	omp_enter_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL267
	 nop
	ld	[%fp+68], %g1
	add	%g1, 1, %g1
	st	%g0, [%sp+92]
	ld	[%fp-4], %o0
	mov	2, %o1
	mov	1, %o2
	mov	%g1, %o3
	mov	1, %o4
	mov	1, %o5
	call	omp_fill_in_loop, 0
	 nop
.LL267:
	ld	[%fp-4], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	call	omp_next_section, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_sections_start, .-GOMP_sections_start
	.align 4
	.global GOMP_sections_next
	.type	GOMP_sections_next, #function
	.proc	016
GOMP_sections_next:
	save	%sp, -96, %sp
	call	omp_next_section, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_sections_next, .-GOMP_sections_next
	.align 4
	.global GOMP_sections_end
	.type	GOMP_sections_end, #function
	.proc	020
GOMP_sections_end:
	save	%sp, -96, %sp
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_sections_end, .-GOMP_sections_end
	.align 4
	.global GOMP_sections_end_nowait
	.type	GOMP_sections_end_nowait, #function
	.proc	020
GOMP_sections_end_nowait:
	save	%sp, -96, %sp
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_sections_end_nowait, .-GOMP_sections_end_nowait
	.align 4
	.global GOMP_parallel_sections_start
	.type	GOMP_parallel_sections_start, #function
	.proc	020
GOMP_parallel_sections_start:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	ld	[%fp+80], %g1
	add	%g1, 1, %g1
	st	%g1, [%sp+92]
	mov	1, %g1
	st	%g1, [%sp+96]
	mov	1, %g1
	st	%g1, [%sp+100]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	ld	[%fp+76], %o2
	mov	1, %o3
	mov	2, %o4
	mov	1, %o5
	call	omp_start_region, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_parallel_sections_start, .-GOMP_parallel_sections_start
	.align 4
	.global GOMP_single_start
	.type	GOMP_single_start, #function
	.proc	00
GOMP_single_start:
	save	%sp, -112, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	add	%fp, -12, %g1
	ld	[%fp-8], %o0
	mov	%g1, %o1
	call	omp_enter_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	ld	[%fp-8], %o0
	call	omp_leave_work_share, 0
	 nop
	ld	[%fp-12], %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_single_start, .-GOMP_single_start
	.align 4
	.global GOMP_single_copy_start
	.type	GOMP_single_copy_start, #function
	.proc	0120
GOMP_single_copy_start:
	save	%sp, -112, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	add	%fp, -16, %g1
	ld	[%fp-12], %o0
	mov	%g1, %o1
	call	omp_enter_work_share, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	ld	[%fp-16], %g1
	cmp	%g1, 0
	be	.LL280
	 nop
	mov	0, %g1
	b	.LL281
	 nop
.LL280:
	ld	[%fp-12], %o0
	call	omp_barrier, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 44, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %o0
	call	omp_leave_work_share, 0
	 nop
	ld	[%fp-8], %g1
.LL281:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_single_copy_start, .-GOMP_single_copy_start
	.align 4
	.global GOMP_single_copy_end
	.type	GOMP_single_copy_end, #function
	.proc	020
GOMP_single_copy_end:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %o0
	call	omp_current_work_share, 0
	 nop
	mov	%o0, %g1
	ld	[%fp+68], %g2
	st	%g2, [%g1+44]
	ld	[%fp-4], %o0
	call	omp_barrier, 0
	 nop
	ld	[%fp-4], %o0
	call	omp_leave_work_share, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_single_copy_end, .-GOMP_single_copy_end
	.align 4
	.global GOMP_task
	.type	GOMP_task, #function
	.proc	020
GOMP_task:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	mov	%i5, %g1
	stb	%g1, [%fp+88]
	ld	[%fp+76], %g1
	cmp	%g1, 0
	be	.LL286
	 nop
	ld	[%fp+80], %g2
	ld	[%fp+84], %g1
	add	%g2, %g1, %g1
	add	%g1, -1, %g1
	add	%g1, 7, %g1
	srl	%g1, 3, %g1
	sll	%g1, 3, %g1
	add	%g1, 7, %g1
	srl	%g1, 3, %g1
	sll	%g1, 3, %g1
	sub	%sp, %g1, %sp
	add	%sp, 92, %g1
	add	%g1, 7, %g1
	srl	%g1, 3, %g1
	sll	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g2
	ld	[%fp+84], %g1
	add	%g2, %g1, %g1
	add	%g1, -1, %g2
	ld	[%fp+84], %g1
	sub	%g0, %g1, %g1
	and	%g2, %g1, %g1
	st	%g1, [%fp-4]
	ld	[%fp+76], %g1
	ld	[%fp-4], %o0
	ld	[%fp+72], %o1
	call	%g1, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%fp-4], %o0
	call	%g1, 0
	 nop
	b	.LL288
	 nop
.LL286:
	ld	[%fp+68], %g1
	ld	[%fp+72], %o0
	call	%g1, 0
	 nop
.LL288:
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_task, .-GOMP_task
	.align 4
	.global GOMP_taskwait
	.type	GOMP_taskwait, #function
	.proc	020
GOMP_taskwait:
	save	%sp, -96, %sp
	restore
	jmp	%o7+8
	 nop
	.size	GOMP_taskwait, .-GOMP_taskwait
	.align 4
	.global omp_set_num_threads
	.type	omp_set_num_threads, #function
	.proc	020
omp_set_num_threads:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	cmp	%g1, 0
	ble	.LL293
	 nop
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	ld	[%fp+68], %g2
	st	%g2, [%g1+20]
.LL293:
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_num_threads, .-omp_set_num_threads
	.align 4
	.global omp_get_num_threads
	.type	omp_get_num_threads, #function
	.proc	04
omp_get_num_threads:
	save	%sp, -96, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	omp_current_team_size, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_num_threads, .-omp_get_num_threads
	.align 4
	.global omp_get_max_threads
	.type	omp_get_max_threads, #function
	.proc	04
omp_get_max_threads:
	save	%sp, -104, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	ld	[%g1+20], %g1
	st	%g1, [%fp-4]
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	ld	[%fp-4], %g2
	cmp	%g1, %g2
	ble	.LL297
	 nop
	mov	%g2, %g1
.LL297:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_max_threads, .-omp_get_max_threads
	.align 4
	.global omp_get_thread_num
	.type	omp_get_thread_num, #function
	.proc	04
omp_get_thread_num:
	save	%sp, -96, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	call	omp_current_thread_num, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_thread_num, .-omp_get_thread_num
	.align 4
	.global omp_get_num_procs
	.type	omp_get_num_procs, #function
	.proc	04
omp_get_num_procs:
	save	%sp, -96, %sp
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_num_procs, .-omp_get_num_procs
	.align 4
	.global omp_in_parallel
	.type	omp_in_parallel, #function
	.proc	04
omp_in_parallel:
	save	%sp, -96, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	ld	[%g1], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_in_parallel, .-omp_in_parallel
	.align 4
	.global omp_set_dynamic
	.type	omp_set_dynamic, #function
	.proc	020
omp_set_dynamic:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_dynamic, .-omp_set_dynamic
	.align 4
	.global omp_get_dynamic
	.type	omp_get_dynamic, #function
	.proc	04
omp_get_dynamic:
	save	%sp, -96, %sp
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_dynamic, .-omp_get_dynamic
	.align 4
	.global omp_set_nested
	.type	omp_set_nested, #function
	.proc	020
omp_set_nested:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_nested, .-omp_set_nested
	.align 4
	.global omp_get_nested
	.type	omp_get_nested, #function
	.proc	04
omp_get_nested:
	save	%sp, -96, %sp
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_nested, .-omp_get_nested
	.align 4
	.global omp_set_schedule
	.type	omp_set_schedule, #function
	.proc	020
omp_set_schedule:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %g2
	ld	[%fp-4], %g1
	st	%g2, [%g1+24]
	ld	[%fp-4], %g1
	ld	[%fp+72], %g2
	st	%g2, [%g1+28]
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_schedule, .-omp_set_schedule
	.align 4
	.global omp_get_schedule
	.type	omp_get_schedule, #function
	.proc	020
omp_get_schedule:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%g1+24], %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1]
	ld	[%fp-4], %g1
	ld	[%g1+28], %g2
	ld	[%fp+72], %g1
	st	%g2, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_schedule, .-omp_get_schedule
	.align 4
	.global omp_get_thread_limit
	.type	omp_get_thread_limit, #function
	.proc	04
omp_get_thread_limit:
	save	%sp, -96, %sp
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_thread_limit, .-omp_get_thread_limit
	.align 4
	.global omp_set_max_active_levels
	.type	omp_set_max_active_levels, #function
	.proc	020
omp_set_max_active_levels:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_max_active_levels, .-omp_set_max_active_levels
	.align 4
	.global omp_get_max_active_levels
	.type	omp_get_max_active_levels, #function
	.proc	04
omp_get_max_active_levels:
	save	%sp, -96, %sp
	mov	1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_max_active_levels, .-omp_get_max_active_levels
	.align 4
	.global omp_get_level
	.type	omp_get_level, #function
	.proc	04
omp_get_level:
	save	%sp, -96, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	ld	[%g1+16], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_level, .-omp_get_level
	.align 4
	.global omp_get_active_level
	.type	omp_get_active_level, #function
	.proc	04
omp_get_active_level:
	save	%sp, -96, %sp
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	ld	[%g1], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_active_level, .-omp_get_active_level
	.align 4
	.global omp_get_ancestor_thread_num
	.type	omp_get_ancestor_thread_num, #function
	.proc	04
omp_get_ancestor_thread_num:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %g1
	cmp	%g1, 0
	bl	.LL328
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+16], %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	cmp	%g2, %g1
	bge	.LL329
	 nop
.LL328:
	mov	-1, %g1
	b	.LL330
	 nop
.LL329:
	ld	[%fp+68], %g1
	cmp	%g1, 1
	bne	.LL331
	 nop
	ld	[%fp-4], %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL331
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+4], %g1
	b	.LL332
	 nop
.LL331:
	mov	0, %g1
.LL332:
.LL330:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_ancestor_thread_num, .-omp_get_ancestor_thread_num
	.align 4
	.global omp_get_team_size
	.type	omp_get_team_size, #function
	.proc	04
omp_get_team_size:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %g1
	cmp	%g1, 0
	bl	.LL335
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+16], %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	cmp	%g2, %g1
	bge	.LL336
	 nop
.LL335:
	mov	-1, %g1
	b	.LL337
	 nop
.LL336:
	ld	[%fp+68], %g1
	cmp	%g1, 1
	bne	.LL338
	 nop
	ld	[%fp-4], %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL338
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+8], %g1
	b	.LL339
	 nop
.LL338:
	mov	1, %g1
.LL339:
.LL337:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_get_team_size, .-omp_get_team_size
	.align 4
	.global omp_init_lock
	.type	omp_init_lock, #function
	.proc	020
omp_init_lock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	st	%g0, [%g1]
	restore
	jmp	%o7+8
	 nop
	.size	omp_init_lock, .-omp_init_lock
	.align 4
	.global omp_destroy_lock
	.type	omp_destroy_lock, #function
	.proc	020
omp_destroy_lock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	restore
	jmp	%o7+8
	 nop
	.size	omp_destroy_lock, .-omp_destroy_lock
	.align 4
	.global omp_set_lock
	.type	omp_set_lock, #function
	.proc	020
omp_set_lock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_lock, .-omp_set_lock
	.align 4
	.global omp_unset_lock
	.type	omp_unset_lock, #function
	.proc	020
omp_unset_lock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_unset_lock, .-omp_unset_lock
	.align 4
	.global omp_test_lock
	.type	omp_test_lock, #function
	.proc	04
omp_test_lock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	mov	1, %o1
	call	atomic_swap, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_test_lock, .-omp_test_lock
	.align 4
	.global omp_init_nest_lock
	.type	omp_init_nest_lock, #function
	.proc	020
omp_init_nest_lock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	st	%g0, [%g1]
	ld	[%fp+68], %g1
	st	%g0, [%g1+4]
	ld	[%fp+68], %g1
	st	%g0, [%g1+8]
	restore
	jmp	%o7+8
	 nop
	.size	omp_init_nest_lock, .-omp_init_nest_lock
	.align 4
	.global omp_destroy_nest_lock
	.type	omp_destroy_nest_lock, #function
	.proc	020
omp_destroy_nest_lock:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	restore
	jmp	%o7+8
	 nop
	.size	omp_destroy_nest_lock, .-omp_destroy_nest_lock
	.align 4
	.type	omp_nest_owner_id, #function
	.proc	016
omp_nest_owner_id:
	save	%sp, -96, %sp
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	add	%g1, 1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_nest_owner_id, .-omp_nest_owner_id
	.align 4
	.global omp_set_nest_lock
	.type	omp_set_nest_lock, #function
	.proc	020
omp_set_nest_lock:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_nest_owner_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL358
	 nop
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+4]
.LL358:
	ld	[%fp+68], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	add	%g1, 1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+8]
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_nest_lock, .-omp_set_nest_lock
	.align 4
	.global omp_unset_nest_lock
	.type	omp_unset_nest_lock, #function
	.proc	020
omp_unset_nest_lock:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	add	%g1, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+8]
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bne	.LL362
	 nop
	ld	[%fp+68], %g1
	st	%g0, [%g1+4]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
.LL362:
	restore
	jmp	%o7+8
	 nop
	.size	omp_unset_nest_lock, .-omp_unset_nest_lock
	.align 4
	.global omp_test_nest_lock
	.type	omp_test_nest_lock, #function
	.proc	04
omp_test_nest_lock:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_nest_owner_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	cmp	%g2, %g1
	be	.LL364
	 nop
	ld	[%fp+68], %g1
	mov	%g1, %o0
	mov	1, %o1
	call	atomic_swap, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL365
	 nop
	mov	0, %g1
	b	.LL366
	 nop
.LL365:
	ld	[%fp+68], %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1+4]
.LL364:
	ld	[%fp+68], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+8]
	ld	[%fp-4], %g1
.LL366:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_test_nest_lock, .-omp_test_nest_lock
	.align 4
	.global omp_end_program
	.type	omp_end_program, #function
	.proc	020
omp_end_program:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	call	omp_stop_workers, 0
	 nop
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	omp_halt_this_core, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_end_program, .-omp_end_program
	.align 4
	.type	omp_take_census, #function
	.proc	020
omp_take_census:
	save	%sp, -104, %sp
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	mov	1, %g2
	st	%g2, [%g1]
	mov	1, %g1
	st	%g1, [%fp-8]
	b	.LL371
	 nop
.LL376:
	st	%g0, [%fp-4]
	b	.LL372
	 nop
.LL375:
	ld	[%fp-4], %g2
	sethi	%hi(19456), %g1
	or	%g1, 543, %g1
	cmp	%g2, %g1
	bgu	.LL378
	 nop
.LL373:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL372:
	ld	[%fp-8], %g1
	sll	%g1, 2, %g2
	sethi	%hi(omp_core_online), %g1
	or	%g1, %lo(omp_core_online), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL375
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g2
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	st	%g2, [%g1]
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL371:
	ld	[%fp-8], %g1
	cmp	%g1, 3
	bleu	.LL376
	 nop
	b	.LL377
	 nop
.LL378:
	nop
.LL377:
	restore
	jmp	%o7+8
	 nop
	.size	omp_take_census, .-omp_take_census
	.align 4
	.type	omp_enable_fpu, #function
	.proc	020
omp_enable_fpu:
	save	%sp, -104, %sp
! 1065 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/omp.h" 1
	rd %psr, %g1
! 0 "" 2
	st	%g1, [%fp-4]
	ld	[%fp-4], %g2
	sethi	%hi(4096), %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
! 1067 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/omp.h" 1
	wr %g1, %psr
	nop
	nop
	nop
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	omp_enable_fpu, .-omp_enable_fpu
	.align 4
	.type	omp_thread_local_bytes, #function
	.proc	016
omp_thread_local_bytes:
	save	%sp, -104, %sp
	sethi	%hi(__tls_align), %g1
	or	%g1, %lo(__tls_align), %g1
	st	%g1, [%fp-4]
	sethi	%hi(__tdata_start), %g1
	or	%g1, %lo(__tdata_start), %g1
	ld	[%fp-4], %g2
	sub	%g2, %g1, %g2
	sethi	%hi(__tbss_end), %g1
	or	%g1, %lo(__tbss_end), %g1
	add	%g1, -1, %g1
	add	%g2, %g1, %g2
	ld	[%fp-4], %g1
	sub	%g0, %g1, %g1
	and	%g2, %g1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_thread_local_bytes, .-omp_thread_local_bytes
	.align 4
	.type	omp_set_up_thread_local_variables, #function
	.proc	020
omp_set_up_thread_local_variables:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	call	omp_thread_local_bytes, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	sethi	%hi(__tdata_end), %g1
	or	%g1, %lo(__tdata_end), %g2
	sethi	%hi(__tdata_start), %g1
	or	%g1, %lo(__tdata_start), %g1
	sub	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-12], %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-16]
	b	.LL384
	 nop
.LL387:
	ld	[%fp+68], %g2
	ld	[%fp-16], %g1
	add	%g2, %g1, %g2
	ld	[%fp-16], %g3
	ld	[%fp-8], %g1
	cmp	%g3, %g1
	bgeu	.LL385
	 nop
	ld	[%fp-16], %g1
	sethi	%hi(__tdata_start), %g3
	or	%g3, %lo(__tdata_start), %g3
	ldub	[%g3+%g1], %g1
	b	.LL386
	 nop
.LL385:
	mov	0, %g1
.LL386:
	stb	%g1, [%g2]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL384:
	ld	[%fp-16], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	blu	.LL387
	 nop
	ld	[%fp-4], %g1
! 1089 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/sparc_common_routines/omp.h" 1
	mov %g1, %g7
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	omp_set_up_thread_local_variables, .-omp_set_up_thread_local_variables
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -112, %sp
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	ld	[%fp-12], %g1
	smul	%g1, 644, %g2
	sethi	%hi(omp_threads), %g1
	or	%g1, %lo(omp_threads), %g1
	add	%g2, %g1, %g1
	st	%g1, [%fp-8]
	call	omp_thread_local_bytes, 0
	 nop
	mov	%o0, %g1
	add	%g1, 8, %g1
	add	%g1, 7, %g1
	srl	%g1, 3, %g1
	sll	%g1, 3, %g1
	add	%g1, 7, %g1
	srl	%g1, 3, %g1
	sll	%g1, 3, %g1
	sub	%sp, %g1, %sp
	add	%sp, 92, %g1
	add	%g1, 7, %g1
	srl	%g1, 3, %g1
	sll	%g1, 3, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	add	%g1, 7, %g1
	and	%g1, -8, %g1
	mov	%g1, %o0
	call	omp_set_up_thread_local_variables, 0
	 nop
	call	omp_enable_fpu, 0
	 nop
	ld	[%fp-8], %g1
	mov	1, %g2
	st	%g2, [%g1+8]
	ld	[%fp-8], %g1
	mov	-1, %g2
	st	%g2, [%g1+32]
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL390
	 nop
	ld	[%fp-12], %g1
	sethi	%hi(omp_core_online), %g2
	or	%g2, %lo(omp_core_online), %g2
	sll	%g1, 2, %g1
	mov	1, %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-12], %o0
	call	omp_worker_loop, 0
	 nop
.LL390:
	call	omp_take_census, 0
	 nop
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	mov	%g1, %g2
	ld	[%fp-8], %g1
	st	%g2, [%g1+20]
	ld	[%fp-8], %g1
	mov	2, %g2
	st	%g2, [%g1+24]
	ld	[%fp-8], %g1
	mov	1, %g2
	st	%g2, [%g1+28]
	call	omp_program_main, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	mov	0, %o1
	call	omp_end_program, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.align 4
	.type	report, #function
	.proc	020
report:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL393
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL394
	 nop
.LL393:
	mov	-1, %g1
.LL394:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %o0
	ld	[%fp+68], %o1
	call	omp_end_program, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	report, .-report
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
.LL415:
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	and	%g1, 8, %g1
	cmp	%g1, 0
	bne	.LL415
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
	be	.LL418
	 nop
	ld	[%fp-12], %g1
	srl	%g1, 24, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1]
.LL418:
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
	.align 4
	.global omp_program_main
	.type	omp_program_main, #function
	.proc	04
omp_program_main:
	save	%sp, -96, %sp
	call	console_start, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.0), %g1
	or	%g1, %lo(omp_program_main.omp_fn.0), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.0, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	call	console_wait_until_sent, 0
	 nop
	mov	1, %o0
	mov	1, %o1
	call	report, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main, .-omp_program_main
	.align 4
	.type	omp_program_main.omp_fn.0, #function
	.proc	020
omp_program_main.omp_fn.0:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g1
	sethi	%hi(lines.2849), %g2
	or	%g2, %lo(lines.2849), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	mov	%g1, %o0
	call	console_puts, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.0, .-omp_program_main.omp_fn.0
	.section	".rodata"
	.align 8
.LLC0:
	.asciz	"thread 0 says hello\n"
	.align 8
.LLC1:
	.asciz	"thread 1 says hello\n"
	.align 8
.LLC2:
	.asciz	"thread 2 says hello\n"
	.align 8
.LLC3:
	.asciz	"thread 3 says hello\n"
	.align 4
	.type	lines.2849, #object
	.size	lines.2849, 16
lines.2849:
	.long	.LLC0
	.long	.LLC1
	.long	.LLC2
	.long	.LLC3
	.ident	"GCC: (GNU) 4.4.3"
