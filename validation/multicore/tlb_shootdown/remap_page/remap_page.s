	.file	"remap_page.c"
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
! 59 "validation/multicore/tlb_shootdown/remap_page/../../mmu_coherence/../multicore_common.h" 1
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
	b	.LL50
	 nop
.LL51:
	ld	[%fp-4], %o0
	call	read_shared_byte, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL51
	 nop
.LL50:
	ld	[%fp-4], %o0
	call	atomic_ldstub, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL51
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
	bne	.LL58
	 nop
	ld	[%fp+68], %g1
	st	%g0, [%g1+4]
	call	memory_fence, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+8]
	b	.LL60
	 nop
.LL58:
	ld	[%fp+68], %g1
	add	%g1, 8, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bne	.LL58
	 nop
.LL60:
	restore
	jmp	%o7+8
	 nop
	.size	barrier_wait, .-barrier_wait
	.local	context_table
	.common	context_table,1024,1024
	.local	per_core_context_tables
	.common	per_core_context_tables,4096,1024
	.local	l1_tables
	.common	l1_tables,4096,1024
	.local	l2_tables
	.common	l2_tables,1024,1024
	.local	l3_tables
	.common	l3_tables,1024,1024
	.local	frame
	.common	frame,4096,4096
	.local	other_frames
	.common	other_frames,16384,4096
	.local	barrier
	.common	barrier,28,4
	.align 4
	.type	sync_cores, #function
	.proc	020
sync_cores:
	save	%sp, -96, %sp
	sethi	%hi(barrier), %g1
	or	%g1, %lo(barrier), %o0
	mov	4, %o1
	call	barrier_wait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	sync_cores, .-sync_cores
	.align 4
	.type	build_context, #function
	.proc	020
build_context:
	save	%sp, -160, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	ld	[%fp+68], %g2
	sll	%g2, 8, %g3
	sethi	%hi(l3_tables), %g2
	or	%g2, %lo(l3_tables), %g2
	add	%g3, %g2, %g2
	st	%g2, [%fp-60]
	ld	[%fp-60], %g2
	st	%g2, [%fp-56]
	ld	[%fp-56], %g2
	srl	%g2, 6, %g2
	sll	%g2, 2, %g2
	or	%g2, 1, %g2
	mov	%g2, %g3
	sethi	%hi(l2_tables), %g2
	or	%g2, %lo(l2_tables), %g2
	sll	%g1, 8, %g1
	st	%g3, [%g2+%g1]
	sethi	%hi(l1_tables), %g1
	or	%g1, %lo(l1_tables), %g2
	ld	[%fp+68], %g1
	sll	%g1, 10, %g1
	add	%g2, %g1, %g2
	ld	[%fp+68], %g1
	sll	%g1, 8, %g3
	sethi	%hi(l2_tables), %g1
	or	%g1, %lo(l2_tables), %g1
	add	%g3, %g1, %g1
	st	%g1, [%fp-52]
	ld	[%fp-52], %g1
	st	%g1, [%fp-48]
	ld	[%fp-48], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g2, [%fp-40]
	st	%g1, [%fp-44]
	st	%g0, [%fp-36]
	b	.LL64
	 nop
.LL65:
	ld	[%fp-36], %g1
	sll	%g1, 2, %g1
	ld	[%fp-40], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-36], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-36]
.LL64:
	ld	[%fp-36], %g1
	cmp	%g1, 255
	ble	.LL65
	 nop
	st	%g0, [%fp-24]
	mov	3, %g1
	st	%g1, [%fp-28]
	mov	1, %g1
	st	%g1, [%fp-32]
	ld	[%fp-24], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-32], %g1
	cmp	%g1, 0
	be	.LL66
	 nop
	mov	128, %g1
	b	.LL67
	 nop
.LL66:
	mov	0, %g1
.LL67:
	or	%g2, %g1, %g2
	ld	[%fp-28], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-40], %g1
	st	%g2, [%g1]
	ld	[%fp-40], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-12]
	mov	3, %g1
	st	%g1, [%fp-16]
	mov	1, %g1
	st	%g1, [%fp-20]
	ld	[%fp-12], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-20], %g1
	cmp	%g1, 0
	be	.LL68
	 nop
	mov	128, %g1
	b	.LL69
	 nop
.LL68:
	mov	0, %g1
.LL69:
	or	%g3, %g1, %g3
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-40], %g1
	add	%g1, 64, %g1
	ld	[%fp-44], %g2
	st	%g2, [%g1]
	ld	[%fp+68], %g1
	ld	[%fp+68], %g2
	sll	%g2, 10, %g3
	sethi	%hi(l1_tables), %g2
	or	%g2, %lo(l1_tables), %g2
	add	%g3, %g2, %g2
	st	%g2, [%fp-8]
	ld	[%fp-8], %g2
	st	%g2, [%fp-4]
	ld	[%fp-4], %g2
	srl	%g2, 6, %g2
	sll	%g2, 2, %g2
	or	%g2, 1, %g2
	mov	%g2, %g3
	sethi	%hi(context_table), %g2
	or	%g2, %lo(context_table), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	restore
	jmp	%o7+8
	 nop
	.size	build_context, .-build_context
	.align 4
	.type	map_page, #function
	.proc	020
map_page:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %o5
	ld	[%fp+72], %g1
	srl	%g1, 12, %g1
	and	%g1, 63, %g4
	ld	[%fp+76], %g1
	st	%g1, [%fp-4]
	mov	3, %g1
	st	%g1, [%fp-8]
	mov	1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-4], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL72
	 nop
	mov	128, %g1
	b	.LL73
	 nop
.LL72:
	mov	0, %g1
.LL73:
	or	%g2, %g1, %g2
	ld	[%fp-8], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g3
	sethi	%hi(l3_tables), %g1
	or	%g1, %lo(l3_tables), %g2
	sll	%o5, 6, %g1
	add	%g1, %g4, %g1
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	restore
	jmp	%o7+8
	 nop
	.size	map_page, .-map_page
	.align 4
	.type	release_tables, #function
	.proc	020
release_tables:
	save	%sp, -96, %sp
	mov	1, %o0
	sethi	%hi(-54272), %g1
	or	%g1, 48, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	release_tables, .-release_tables
	.align 4
	.type	wait_for_tables, #function
	.proc	020
wait_for_tables:
	save	%sp, -96, %sp
.LL78:
	sethi	%hi(-54272), %g1
	or	%g1, 48, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL78
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	wait_for_tables, .-wait_for_tables
	.align 4
	.type	set_context, #function
	.proc	020
set_context:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	st	%g1, [%fp-4]
	mov	512, %g1
	st	%g1, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/multicore/tlb_shootdown/remap_page/../../mmu_coherence/../../C/mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	set_context, .-set_context
	.align 4
	.type	start_mmu, #function
	.proc	020
start_mmu:
	save	%sp, -120, %sp
	st	%i0, [%fp+68]
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
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
! 96 "validation/multicore/tlb_shootdown/remap_page/../../mmu_coherence/../../C/mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%fp+68], %o0
	call	set_context, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/multicore/tlb_shootdown/remap_page/../../mmu_coherence/../../C/mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	start_mmu, .-start_mmu
	.align 4
	.type	check_every_kind_of_write, #function
	.proc	016
check_every_kind_of_write:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%g0, [%fp-8]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+72], %g1
	ld	[%g1], %g1
	call	sync_cores, 0
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bne	.LL85
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(4096), %g2
	or	%g2, 273, %g2
	st	%g2, [%g1]
.LL85:
	call	sync_cores, 0
	 nop
	ld	[%fp+72], %g1
	ld	[%g1], %g2
	sethi	%hi(4096), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL86
	 nop
	ld	[%fp-8], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL86:
	call	sync_cores, 0
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bne	.LL87
	 nop
	ld	[%fp+68], %g1
	mov	-85, %g2
	stb	%g2, [%g1]
.LL87:
	call	sync_cores, 0
	 nop
	ld	[%fp+72], %g1
	ld	[%g1], %g2
	sethi	%hi(-1426059264), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL88
	 nop
	ld	[%fp-8], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-8]
.LL88:
	call	sync_cores, 0
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bne	.LL89
	 nop
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	atomic_ldstub, 0
	 nop
.LL89:
	call	sync_cores, 0
	 nop
	ld	[%fp+72], %g1
	ld	[%g1], %g2
	sethi	%hi(-16773120), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL90
	 nop
	ld	[%fp-8], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-8]
.LL90:
	call	sync_cores, 0
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bne	.LL91
	 nop
	ld	[%fp+68], %o0
	sethi	%hi(8192), %g1
	or	%g1, 546, %o1
	call	atomic_swap, 0
	 nop
.LL91:
	call	sync_cores, 0
	 nop
	ld	[%fp+72], %g1
	ld	[%g1], %g2
	sethi	%hi(8192), %g1
	or	%g1, 546, %g1
	cmp	%g2, %g1
	bne	.LL92
	 nop
	ld	[%fp-8], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-8]
.LL92:
	call	sync_cores, 0
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bne	.LL93
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(12288), %g2
	or	%g2, 819, %g2
	st	%g2, [%g1]
.LL93:
	call	sync_cores, 0
	 nop
	ld	[%fp+72], %g1
	ld	[%g1], %g2
	sethi	%hi(12288), %g1
	or	%g1, 819, %g1
	cmp	%g2, %g1
	bne	.LL94
	 nop
	ld	[%fp-8], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-8]
.LL94:
	call	sync_cores, 0
	 nop
	ld	[%fp-8], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	check_every_kind_of_write, .-check_every_kind_of_write
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
	ld	[%fp-12], %g2
	ld	[%fp-16], %g1
	and	%g2, %g1, %g2
	ld	[%fp-20], %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	be	.LL101
	 nop
	mov	1, %g1
	b	.LL102
	 nop
.LL101:
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
	ld	[%fp-20], %g1
	or	%g2, %g1, %g2
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	mov	0, %g1
.LL102:
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
	be	.LL107
	 nop
	mov	1, %g1
	b	.LL108
	 nop
.LL107:
	ld	[%fp-4], %g2
	ld	[%fp-8], %g1
	or	%g2, %g1, %g1
	mov	%g1, %o0
	ld	[%fp+68], %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	mov	0, %g1
.LL108:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_enable_ipi_interrupt__, .-__ajit_enable_ipi_interrupt__
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
	.local	ipi_lock
	.common	ipi_lock,1,1
	.align 4
	.type	ipi_start_on_this_core, #function
	.proc	020
ipi_start_on_this_core:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	sethi	%hi(ipi_lock), %g1
	or	%g1, %lo(ipi_lock), %o0
	call	platform_lock, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	mov	11, %o0
	ld	[%fp+68], %o1
	call	ajit_set_interrupt_handler, 0
	 nop
	ld	[%fp-8], %g1
	and	%g1, 0xff, %g1
	sethi	%hi(-53248), %g2
	or	%g2, 128, %o0
	mov	%g1, %o1
	mov	0, %o2
	call	__ajit_enable_ipi_interrupt__, 0
	 nop
	sethi	%hi(ipi_lock), %g1
	or	%g1, %lo(ipi_lock), %o0
	ld	[%fp-4], %o1
	call	platform_unlock, 0
	 nop
	ld	[%fp-8], %l0
	ld	[%fp-8], %g1
	mov	%g1, %o0
	mov	0, %o1
	call	readInterruptControlRegister, 0
	 nop
	mov	%o0, %g1
	or	%g1, 2049, %g1
	mov	%l0, %o0
	mov	0, %o1
	mov	%g1, %o2
	call	writeInterruptControlRegister, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	ipi_start_on_this_core, .-ipi_start_on_this_core
	.align 4
	.type	ipi_try_send, #function
	.proc	04
ipi_try_send:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	sethi	%hi(ipi_lock), %g1
	or	%g1, %lo(ipi_lock), %o0
	call	platform_lock, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g2
	ld	[%fp+68], %g1
	and	%g1, 0xff, %g1
	sethi	%hi(-53248), %g3
	or	%g3, 128, %o0
	mov	%g2, %o1
	mov	0, %o2
	mov	%g1, %o3
	mov	0, %o4
	ld	[%fp+72], %o5
	call	__ajit_set_ipi_interrupt__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	sethi	%hi(ipi_lock), %g1
	or	%g1, %lo(ipi_lock), %o0
	ld	[%fp-8], %o1
	call	platform_unlock, 0
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ipi_try_send, .-ipi_try_send
	.align 4
	.type	ipi_pending, #function
	.proc	04
ipi_pending:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	sethi	%hi(-53248), %g1
	or	%g1, 128, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	sethi	%hi(-53248), %g1
	or	%g1, 132, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g2
	ld	[%fp-4], %g1
	and	%g2, %g1, %l0
	ld	[%fp+68], %g1
	and	%g1, 0xff, %g1
	mov	%g1, %o0
	mov	0, %o1
	call	ajitIpiDestinationBit, 0
	 nop
	mov	%o0, %g1
	and	%l0, %g1, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	addx	%g0, 0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ipi_pending, .-ipi_pending
	.align 4
	.type	ipi_send, #function
	.proc	020
ipi_send:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
.LL125:
	ld	[%fp+68], %o0
	call	ipi_pending, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL125
	 nop
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	ipi_try_send, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL125
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	ipi_send, .-ipi_send
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
	be	.LL128
	 nop
	ld	[%fp-12], %g1
	srl	%g1, 24, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1]
.LL128:
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
	.type	tlb_shootdown_start_on_this_core, #function
	.proc	020
tlb_shootdown_start_on_this_core:
	save	%sp, -96, %sp
	sethi	%hi(tlb_shootdown_ipi_handler), %g1
	or	%g1, %lo(tlb_shootdown_ipi_handler), %o0
	call	ipi_start_on_this_core, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	tlb_shootdown_start_on_this_core, .-tlb_shootdown_start_on_this_core
	.align 4
	.type	tlb_shootdown_page, #function
	.proc	016
tlb_shootdown_page:
	save	%sp, -120, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%g0, [%fp-8]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp+68], %o0
	ld	[%fp+72], %o1
	call	tlb_flush_page, 0
	 nop
	sethi	%hi(shootdown_lock), %g1
	or	%g1, %lo(shootdown_lock), %g1
	mov	%g1, %o0
	call	acquire_mutex_using_ldstub, 0
	 nop
	sethi	%hi(shootdown_number), %g1
	or	%g1, %lo(shootdown_number), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
	sethi	%hi(shootdown_va), %g1
	or	%g1, %lo(shootdown_va), %g1
	ld	[%fp+68], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	sethi	%hi(shootdown_context), %g1
	or	%g1, %lo(shootdown_context), %g1
	ld	[%fp+72], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	sethi	%hi(shootdown_number), %g1
	or	%g1, %lo(shootdown_number), %g1
	ld	[%fp-12], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	st	%g0, [%fp-20]
	b	.LL141
	 nop
.LL143:
	ld	[%fp-20], %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL142
	 nop
	ld	[%fp-20], %o0
	mov	0, %o1
	call	ipi_send, 0
	 nop
.LL142:
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL141:
	ld	[%fp-20], %g2
	ld	[%fp+76], %g1
	cmp	%g2, %g1
	blu	.LL143
	 nop
	st	%g0, [%fp-20]
	b	.LL144
	 nop
.LL150:
	ld	[%fp-20], %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL152
	 nop
.LL145:
	st	%g0, [%fp-16]
	b	.LL147
	 nop
.LL149:
	ld	[%fp-16], %g2
	sethi	%hi(1999872), %g1
	or	%g1, 127, %g1
	cmp	%g2, %g1
	bleu	.LL148
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	b	.LL146
	 nop
.LL148:
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL147:
	ld	[%fp-20], %g1
	sll	%g1, 2, %g2
	sethi	%hi(shootdown_done), %g1
	or	%g1, %lo(shootdown_done), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	bne	.LL149
	 nop
	b	.LL146
	 nop
.LL152:
	nop
.LL146:
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL144:
	ld	[%fp-20], %g2
	ld	[%fp+76], %g1
	cmp	%g2, %g1
	blu	.LL150
	 nop
	sethi	%hi(shootdown_lock), %g1
	or	%g1, %lo(shootdown_lock), %g1
	mov	%g1, %o0
	call	release_mutex_using_ldstub, 0
	 nop
	ld	[%fp-8], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	tlb_shootdown_page, .-tlb_shootdown_page
	.align 4
	.type	write_pte, #function
	.proc	020
write_pte:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	ld	[%fp+76], %g1
	st	%g1, [%fp-4]
	ld	[%fp+80], %g1
	st	%g1, [%fp-8]
	mov	1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-4], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL154
	 nop
	mov	128, %g1
	b	.LL155
	 nop
.LL154:
	mov	0, %g1
.LL155:
	or	%g2, %g1, %g2
	ld	[%fp-8], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	sethi	%hi(l3_tables), %g1
	or	%g1, %lo(l3_tables), %g3
	ld	[%fp+68], %g1
	sll	%g1, 6, %g4
	ld	[%fp+72], %g1
	srl	%g1, 12, %g1
	and	%g1, 63, %g1
	add	%g4, %g1, %g1
	sll	%g1, 2, %g1
	add	%g3, %g1, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	write_pte, .-write_pte
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	mov	3, %g1
	st	%g1, [%fp-20]
	call	this_core_id, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-16]
	sethi	%hi(268500992), %g1
	st	%g1, [%fp-8]
	ld	[%fp-16], %g1
	cmp	%g1, 0
	bne	.LL158
	 nop
	mov	0, %o0
	call	build_context, 0
	 nop
	mov	0, %o0
	sethi	%hi(268500992), %o1
	sethi	%hi(frame), %g1
	or	%g1, %lo(frame), %o2
	call	map_page, 0
	 nop
	sethi	%hi(frame), %g1
	or	%g1, %lo(frame), %g1
	mov	256, %g2
	st	%g2, [%g1]
	call	release_tables, 0
	 nop
	b	.LL159
	 nop
.LL158:
	call	wait_for_tables, 0
	 nop
.LL159:
	mov	0, %o0
	call	start_mmu, 0
	 nop
	call	tlb_shootdown_start_on_this_core, 0
	 nop
	call	sync_cores, 0
	 nop
	st	%g0, [%fp-12]
	b	.LL160
	 nop
.LL165:
	ld	[%fp-8], %g1
	ld	[%g1], %g2
	ld	[%fp-12], %g1
	add	%g1, 256, %g1
	cmp	%g2, %g1
	be	.LL161
	 nop
	ld	[%fp-20], %g1
	and	%g1, -2, %g1
	st	%g1, [%fp-20]
.LL161:
	call	sync_cores, 0
	 nop
	ld	[%fp-16], %g1
	cmp	%g1, 0
	bne	.LL162
	 nop
	ld	[%fp-12], %g1
	and	%g1, 1, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL163
	 nop
	sethi	%hi(frame), %g1
	or	%g1, %lo(frame), %g1
	b	.LL164
	 nop
.LL163:
	sethi	%hi(other_frames), %g1
	or	%g1, %lo(other_frames), %g1
.LL164:
	st	%g1, [%fp-4]
	ld	[%fp-12], %g1
	add	%g1, 257, %g2
	ld	[%fp-4], %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	mov	0, %o0
	sethi	%hi(268500992), %o1
	ld	[%fp-4], %o2
	mov	3, %o3
	call	write_pte, 0
	 nop
	sethi	%hi(268500992), %o0
	mov	0, %o1
	mov	4, %o2
	call	tlb_shootdown_page, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL162
	 nop
	ld	[%fp-20], %g1
	and	%g1, -3, %g1
	st	%g1, [%fp-20]
.LL162:
	call	sync_cores, 0
	 nop
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL160:
	ld	[%fp-12], %g1
	cmp	%g1, 7
	bleu	.LL165
	 nop
	ld	[%fp-20], %o0
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
