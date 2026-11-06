	.file	"locks.c"
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
	b	.LL22
	 nop
.LL23:
	ld	[%fp-4], %o0
	call	read_shared_byte, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL23
	 nop
.LL22:
	ld	[%fp-4], %o0
	call	atomic_ldstub, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL23
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
	b	.LL28
	 nop
.LL29:
	ld	[%fp-4], %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL29
	 nop
.LL28:
	ld	[%fp-4], %o0
	mov	1, %o1
	call	atomic_swap, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL29
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
	b	.LL48
	 nop
.LL49:
	ld	[%fp-4], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL48:
	ld	[%fp-4], %g1
	cmp	%g1, 15
	ble	.LL49
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
	bgu	.LL53
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(ajit_global_interrupt_handlers), %g2
	or	%g2, %lo(ajit_global_interrupt_handlers), %g2
	sll	%g1, 2, %g1
	ld	[%fp+72], %g3
	st	%g3, [%g2+%g1]
.LL53:
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
	bleu	.LL55
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 31
	bgu	.LL55
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
	be	.LL55
	 nop
	ld	[%fp-4], %g1
	call	%g1, 0
	 nop
	st	%g0, [%fp-12]
.LL55:
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
	be	.LL57
	 nop
! 149 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_mt_irc.h" 1
	ta 0
! 0 "" 2
.LL57:
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
	be	.LL63
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+12], %g1
	cmp	%g1, 0
	bne	.LL63
	 nop
	mov	1, %g1
	b	.LL64
	 nop
.LL63:
	mov	0, %g1
.LL64:
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
	be	.LL67
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+8], %g1
	b	.LL68
	 nop
.LL67:
	mov	1, %g1
.LL68:
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
	be	.LL71
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	b	.LL72
	 nop
.LL71:
	mov	0, %g1
.LL72:
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
.LL75:
	b	.LL75
	 nop
	.size	omp_halt_this_core, .-omp_halt_this_core
	.align 4
	.type	omp_stop_workers, #function
	.proc	020
omp_stop_workers:
	save	%sp, -104, %sp
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL78
	 nop
.LL79:
	ld	[%fp-4], %g1
	sethi	%hi(omp_go), %g2
	or	%g2, %lo(omp_go), %g2
	sll	%g1, 2, %g1
	mov	2, %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL78:
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	ld	[%fp-4], %g2
	cmp	%g2, %g1
	blu	.LL79
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
	bleu	.LL88
	 nop
.LL84:
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
	bne	.LL86
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
	b	.LL87
	 nop
.LL86:
	sethi	%hi(omp_team+36), %g1
	or	%g1, %lo(omp_team+36), %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL86
	 nop
	b	.LL87
	 nop
.LL88:
	nop
.LL87:
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
	be	.LL92
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
	b	.LL93
	 nop
.LL92:
	ld	[%fp+68], %g1
	add	%g1, 212, %g3
	ld	[%fp+68], %g1
	ld	[%g1+12], %g2
	mov	%g2, %g1
	add	%g1, %g1, %g1
	add	%g1, %g2, %g1
	sll	%g1, 4, %g1
	add	%g3, %g1, %g1
.LL93:
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
	bne	.LL96
	 nop
	ld	[%fp-8], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-8], %g1
	b	.LL97
	 nop
.LL96:
	ld	[%fp-12], %g1
	ld	[%g1], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	b	.LL103
	 nop
.LL105:
	nop
.LL103:
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
	bne	.LL98
	 nop
	ld	[%fp+72], %g1
	st	%g0, [%g1]
	ld	[%fp-8], %g1
	b	.LL97
	 nop
.LL98:
	ld	[%fp-8], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL99
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
	bne	.LL100
	 nop
.LL99:
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+4]
	ld	[%fp-8], %g1
	st	%g0, [%g1+8]
	ld	[%fp+72], %g1
	mov	1, %g2
	st	%g2, [%g1]
	ld	[%fp-8], %g1
	b	.LL97
	 nop
.LL100:
	ld	[%fp-8], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
.LL102:
	ld	[%fp-8], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL105
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
	bne	.LL102
	 nop
	b	.LL103
	 nop
.LL97:
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
	be	.LL109
	 nop
.LL108:
	ld	[%fp+72], %g1
	add	%g1, 40, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+68], %g1
	ld	[%g1+12], %g1
	cmp	%g2, %g1
	bne	.LL108
	 nop
	call	memory_fence, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+16], %g2
	ld	[%fp+72], %g1
	st	%g2, [%g1+40]
	ld	[%fp+68], %g1
	st	%g0, [%g1+8]
.LL109:
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
	be	.LL112
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
.LL112:
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
	bne	.LL114
	 nop
	mov	1, %g1
	st	%g1, [%fp+72]
.LL114:
	ld	[%fp+72], %g1
	cmp	%g1, 1
	be	.LL115
	 nop
	ld	[%fp+88], %g1
	cmp	%g1, 0
	bg	.LL115
	 nop
	mov	1, %g1
	st	%g1, [%fp+88]
.LL115:
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
	ble	.LL118
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
	b	.LL119
	 nop
.LL118:
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
.LL119:
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
	bg	.LL122
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
	be	.LL123
	 nop
	mov	0, %g1
	b	.LL124
	 nop
.LL123:
	ld	[%fp-24], %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bge	.LL125
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-4]
.LL125:
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
	b	.LL126
	 nop
.LL122:
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
.LL126:
	ld	[%fp-48], %g1
	ld	[%g1+4], %g1
	add	%g1, 1, %g2
	ld	[%fp-48], %g1
	st	%g2, [%g1+4]
	ld	[%fp-16], %g2
	ld	[%fp-28], %g1
	cmp	%g2, %g1
	bl	.LL127
	 nop
	mov	0, %g1
	b	.LL124
	 nop
.LL127:
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
	bge	.LL128
	 nop
	ld	[%fp-12], %g2
	ld	[%fp-36], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-44], %g1
	add	%g2, %g1, %g1
	b	.LL129
	 nop
.LL128:
	ld	[%fp-40], %g1
.LL129:
	ld	[%fp+80], %g2
	st	%g1, [%g2]
	mov	1, %g1
.LL124:
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
	ble	.LL132
	 nop
	ld	[%fp+72], %g1
	add	%g1, 12, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 3
	bne	.LL133
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
	ble	.LL133
	 nop
	ld	[%fp-4], %g1
	st	%g1, [%fp-20]
.LL133:
	ld	[%fp+76], %g1
	ld	[%fp-32], %g2
	st	%g2, [%g1]
	ld	[%fp-20], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bge	.LL134
	 nop
	ld	[%fp-20], %g2
	ld	[%fp-24], %g1
	smul	%g2, %g1, %g2
	ld	[%fp-32], %g1
	add	%g2, %g1, %g1
	b	.LL135
	 nop
.LL134:
	ld	[%fp-28], %g1
.LL135:
	ld	[%fp+80], %g2
	st	%g1, [%g2]
	ld	[%fp+80], %g1
	ld	[%g1], %g2
	ld	[%fp+72], %g1
	st	%g2, [%g1+16]
	mov	1, %g1
	st	%g1, [%fp-12]
.LL132:
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
	bne	.LL138
	 nop
	ld	[%fp+68], %o0
	ld	[%fp-12], %o1
	ld	[%fp+72], %o2
	ld	[%fp+76], %o3
	call	omp_take_static_chunk, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	b	.LL139
	 nop
.LL138:
	ld	[%fp+68], %o0
	ld	[%fp-12], %o1
	ld	[%fp+72], %o2
	ld	[%fp+76], %o3
	call	omp_take_shared_chunk, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
.LL139:
	ld	[%fp-4], %g1
	cmp	%g1, 0
	be	.LL140
	 nop
	ld	[%fp-12], %g1
	add	%g1, 36, %g1
	mov	%g1, %o0
	call	read_shared, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL140
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
.LL140:
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
	be	.LL143
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
.LL143:
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
	bne	.LL148
	 nop
	ld	[%fp-16], %g1
	ld	[%g1+20], %g1
	b	.LL149
	 nop
.LL148:
	ld	[%fp+76], %g1
.LL149:
	st	%g1, [%fp-8]
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	ld	[%fp-8], %g2
	cmp	%g2, %g1
	bleu	.LL150
	 nop
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	ld	[%g1], %g1
	st	%g1, [%fp-8]
.LL150:
	ld	[%fp-8], %g1
	cmp	%g1, 1
	bleu	.LL151
	 nop
	ld	[%fp-16], %g1
	ld	[%g1+16], %g1
	cmp	%g1, 0
	be	.LL152
	 nop
.LL151:
	ld	[%fp-16], %g1
	ld	[%g1+12], %g1
	cmp	%g1, 8
	bne	.LL153
	 nop
	sethi	%hi(-1160715264), %g1
	or	%g1, 369, %o0
	call	omp_fatal, 0
	 nop
.LL153:
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
	be	.LL162
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
	b	.LL161
	 nop
.LL152:
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
	b	.LL156
	 nop
.LL157:
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
.LL156:
	ld	[%fp-12], %g1
	cmp	%g1, 7
	bleu	.LL157
	 nop
	sethi	%hi(omp_team), %g1
	or	%g1, %lo(omp_team), %g1
	mov	-1, %g2
	st	%g2, [%g1+12]
	ld	[%fp+80], %g1
	cmp	%g1, 0
	be	.LL158
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
.LL158:
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
	b	.LL159
	 nop
.LL160:
	ld	[%fp-12], %g1
	sethi	%hi(omp_go), %g2
	or	%g2, %lo(omp_go), %g2
	sll	%g1, 2, %g1
	mov	1, %g3
	st	%g3, [%g2+%g1]
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL159:
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	cmp	%g2, %g1
	blu	.LL160
	 nop
	b	.LL161
	 nop
.LL162:
	nop
.LL161:
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
.LL164:
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
	be	.LL164
	 nop
	ld	[%fp+68], %g1
	sethi	%hi(omp_go), %g2
	or	%g2, %lo(omp_go), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	cmp	%g1, 2
	bne	.LL165
	 nop
	mov	1, %o0
	mov	0, %o1
	call	omp_halt_this_core, 0
	 nop
.LL165:
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
	b	.LL164
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
	be	.LL170
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
	b	.LL172
	 nop
.LL170:
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
.LL172:
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
	be	.LL190
	 nop
.LL189:
	ld	[%fp-4], %g1
	add	%g1, 40, %g1
	mov	%g1, %o0
	call	omp_read, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-8], %g1
	ld	[%g1+12], %g1
	cmp	%g2, %g1
	bne	.LL189
	 nop
.LL190:
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
	be	.LL238
	 nop
	ld	[%fp-4], %g1
	b	.LL239
	 nop
.LL238:
	mov	0, %g1
.LL239:
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
	be	.LL242
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
.LL242:
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
	be	.LL255
	 nop
	mov	0, %g1
	b	.LL256
	 nop
.LL255:
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
.LL256:
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
	be	.LL261
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
	b	.LL263
	 nop
.LL261:
	ld	[%fp+68], %g1
	ld	[%fp+72], %o0
	call	%g1, 0
	 nop
.LL263:
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
	ble	.LL268
	 nop
	call	omp_this_thread, 0
	 nop
	mov	%o0, %g1
	ld	[%fp+68], %g2
	st	%g2, [%g1+20]
.LL268:
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
	ble	.LL272
	 nop
	mov	%g2, %g1
.LL272:
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
	bl	.LL303
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+16], %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	cmp	%g2, %g1
	bge	.LL304
	 nop
.LL303:
	mov	-1, %g1
	b	.LL305
	 nop
.LL304:
	ld	[%fp+68], %g1
	cmp	%g1, 1
	bne	.LL306
	 nop
	ld	[%fp-4], %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL306
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+4], %g1
	b	.LL307
	 nop
.LL306:
	mov	0, %g1
.LL307:
.LL305:
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
	bl	.LL310
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+16], %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	cmp	%g2, %g1
	bge	.LL311
	 nop
.LL310:
	mov	-1, %g1
	b	.LL312
	 nop
.LL311:
	ld	[%fp+68], %g1
	cmp	%g1, 1
	bne	.LL313
	 nop
	ld	[%fp-4], %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL313
	 nop
	ld	[%fp-4], %g1
	ld	[%g1+8], %g1
	b	.LL314
	 nop
.LL313:
	mov	1, %g1
.LL314:
.LL312:
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
	be	.LL333
	 nop
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	acquire_mutex_using_swap, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%fp-4], %g2
	st	%g2, [%g1+4]
.LL333:
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
	bne	.LL337
	 nop
	ld	[%fp+68], %g1
	st	%g0, [%g1+4]
	ld	[%fp+68], %g1
	mov	%g1, %o0
	call	release_mutex_using_swap, 0
	 nop
.LL337:
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
	be	.LL339
	 nop
	ld	[%fp+68], %g1
	mov	%g1, %o0
	mov	1, %o1
	call	atomic_swap, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL340
	 nop
	mov	0, %g1
	b	.LL341
	 nop
.LL340:
	ld	[%fp+68], %g1
	ld	[%fp-8], %g2
	st	%g2, [%g1+4]
.LL339:
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
.LL341:
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
	b	.LL346
	 nop
.LL351:
	st	%g0, [%fp-4]
	b	.LL347
	 nop
.LL350:
	ld	[%fp-4], %g2
	sethi	%hi(19456), %g1
	or	%g1, 543, %g1
	cmp	%g2, %g1
	bgu	.LL353
	 nop
.LL348:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL347:
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
	bne	.LL350
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g2
	sethi	%hi(omp_num_procs), %g1
	or	%g1, %lo(omp_num_procs), %g1
	st	%g2, [%g1]
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL346:
	ld	[%fp-8], %g1
	cmp	%g1, 3
	bleu	.LL351
	 nop
	b	.LL352
	 nop
.LL353:
	nop
.LL352:
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
	b	.LL359
	 nop
.LL362:
	ld	[%fp+68], %g2
	ld	[%fp-16], %g1
	add	%g2, %g1, %g2
	ld	[%fp-16], %g3
	ld	[%fp-8], %g1
	cmp	%g3, %g1
	bgeu	.LL360
	 nop
	ld	[%fp-16], %g1
	sethi	%hi(__tdata_start), %g3
	or	%g3, %lo(__tdata_start), %g3
	ldub	[%g3+%g1], %g1
	b	.LL361
	 nop
.LL360:
	mov	0, %g1
.LL361:
	stb	%g1, [%g2]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL359:
	ld	[%fp-16], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	blu	.LL362
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
	be	.LL365
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
.LL365:
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
	bgu	.LL368
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL369
	 nop
.LL368:
	mov	-1, %g1
.LL369:
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
	.global omp_program_main
	.type	omp_program_main, #function
	.proc	04
omp_program_main:
	save	%sp, -216, %sp
	st	%g0, [%fp-32]
	st	%g0, [%fp-100]
	add	%fp, -84, %g1
	mov	%g1, %o0
	call	omp_init_lock, 0
	 nop
	add	%fp, -84, %g1
	st	%g1, [%fp-80]
	ld	[%fp-100], %g1
	st	%g1, [%fp-76]
	add	%fp, -80, %g1
	sethi	%hi(omp_program_main.omp_fn.0), %g2
	or	%g2, %lo(omp_program_main.omp_fn.0), %o0
	mov	%g1, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -80, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.0, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-76], %g1
	st	%g1, [%fp-100]
	ld	[%fp-100], %g1
	cmp	%g1, 200
	bne	.LL372
	 nop
	ld	[%fp-32], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-32]
.LL372:
	mov	-1, %g1
	st	%g1, [%fp-104]
	add	%fp, -84, %g1
	mov	%g1, %o0
	call	omp_test_lock, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-20]
	add	%fp, -84, %g1
	st	%g1, [%fp-72]
	ld	[%fp-104], %g1
	st	%g1, [%fp-68]
	add	%fp, -72, %g1
	sethi	%hi(omp_program_main.omp_fn.1), %g2
	or	%g2, %lo(omp_program_main.omp_fn.1), %o0
	mov	%g1, %o1
	mov	2, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -72, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.1, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-68], %g1
	st	%g1, [%fp-104]
	add	%fp, -84, %g1
	mov	%g1, %o0
	call	omp_unset_lock, 0
	 nop
	ld	[%fp-20], %g1
	cmp	%g1, 0
	be	.LL373
	 nop
	ld	[%fp-104], %g1
	cmp	%g1, 0
	bne	.LL373
	 nop
	add	%fp, -84, %g1
	mov	%g1, %o0
	call	omp_test_lock, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL373
	 nop
	ld	[%fp-32], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-32]
.LL373:
	add	%fp, -84, %g1
	mov	%g1, %o0
	call	omp_unset_lock, 0
	 nop
	add	%fp, -84, %g1
	mov	%g1, %o0
	call	omp_destroy_lock, 0
	 nop
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_init_nest_lock, 0
	 nop
	mov	-1, %g1
	st	%g1, [%fp-108]
	mov	-1, %g1
	st	%g1, [%fp-112]
	mov	-1, %g1
	st	%g1, [%fp-116]
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_set_nest_lock, 0
	 nop
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_set_nest_lock, 0
	 nop
	add	%fp, -96, %g1
	st	%g1, [%fp-64]
	ld	[%fp-108], %g1
	st	%g1, [%fp-60]
	add	%fp, -64, %g1
	sethi	%hi(omp_program_main.omp_fn.2), %g2
	or	%g2, %lo(omp_program_main.omp_fn.2), %o0
	mov	%g1, %o1
	mov	2, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -64, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.2, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-60], %g1
	st	%g1, [%fp-108]
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_unset_nest_lock, 0
	 nop
	add	%fp, -96, %g1
	st	%g1, [%fp-56]
	ld	[%fp-112], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	sethi	%hi(omp_program_main.omp_fn.3), %g2
	or	%g2, %lo(omp_program_main.omp_fn.3), %o0
	mov	%g1, %o1
	mov	2, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.3, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-52], %g1
	st	%g1, [%fp-112]
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_unset_nest_lock, 0
	 nop
	add	%fp, -96, %g1
	st	%g1, [%fp-48]
	ld	[%fp-116], %g1
	st	%g1, [%fp-44]
	add	%fp, -48, %g1
	sethi	%hi(omp_program_main.omp_fn.4), %g2
	or	%g2, %lo(omp_program_main.omp_fn.4), %o0
	mov	%g1, %o1
	mov	2, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -48, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.4, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-44], %g1
	st	%g1, [%fp-116]
	ld	[%fp-108], %g1
	cmp	%g1, 0
	bne	.LL374
	 nop
	ld	[%fp-112], %g1
	cmp	%g1, 0
	bne	.LL374
	 nop
	ld	[%fp-116], %g1
	cmp	%g1, 1
	bne	.LL374
	 nop
	ld	[%fp-32], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-32]
.LL374:
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_test_nest_lock, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-16]
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_test_nest_lock, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-12]
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_unset_nest_lock, 0
	 nop
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_unset_nest_lock, 0
	 nop
	ld	[%fp-16], %g1
	cmp	%g1, 1
	bne	.LL375
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 2
	bne	.LL375
	 nop
	ld	[%fp-32], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-32]
.LL375:
	st	%g0, [%fp-100]
	add	%fp, -96, %g1
	st	%g1, [%fp-40]
	ld	[%fp-100], %g1
	st	%g1, [%fp-36]
	add	%fp, -40, %g1
	sethi	%hi(omp_program_main.omp_fn.5), %g2
	or	%g2, %lo(omp_program_main.omp_fn.5), %o0
	mov	%g1, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -40, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.5, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-36], %g1
	st	%g1, [%fp-100]
	ld	[%fp-100], %g1
	cmp	%g1, 200
	bne	.LL376
	 nop
	ld	[%fp-32], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-32]
.LL376:
	add	%fp, -96, %g1
	mov	%g1, %o0
	call	omp_destroy_nest_lock, 0
	 nop
	ld	[%fp-32], %o0
	mov	5, %o1
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
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%g0, [%fp-8]
.LL380:
	ld	[%fp-8], %g1
	cmp	%g1, 49
	bg	.LL382
	 nop
.LL379:
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_set_lock, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	add	%g1, 1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+4]
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_unset_lock, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	b	.LL380
	 nop
.LL382:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.0, .-omp_program_main.omp_fn.0
	.align 4
	.type	omp_program_main.omp_fn.1, #function
	.proc	020
omp_program_main.omp_fn.1:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL386
	 nop
.LL384:
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_test_lock, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+4]
.LL386:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.1, .-omp_program_main.omp_fn.1
	.align 4
	.type	omp_program_main.omp_fn.2, #function
	.proc	020
omp_program_main.omp_fn.2:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL390
	 nop
.LL388:
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_test_nest_lock, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+4]
.LL390:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.2, .-omp_program_main.omp_fn.2
	.align 4
	.type	omp_program_main.omp_fn.3, #function
	.proc	020
omp_program_main.omp_fn.3:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL394
	 nop
.LL392:
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_test_nest_lock, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+4]
.LL394:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.3, .-omp_program_main.omp_fn.3
	.align 4
	.type	omp_program_main.omp_fn.4, #function
	.proc	020
omp_program_main.omp_fn.4:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 1
	bne	.LL398
	 nop
.LL396:
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_test_nest_lock, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+4]
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_unset_nest_lock, 0
	 nop
.LL398:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.4, .-omp_program_main.omp_fn.4
	.align 4
	.type	omp_program_main.omp_fn.5, #function
	.proc	020
omp_program_main.omp_fn.5:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%g0, [%fp-8]
.LL401:
	ld	[%fp-8], %g1
	cmp	%g1, 49
	bg	.LL403
	 nop
.LL400:
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_set_nest_lock, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_set_nest_lock, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	add	%g1, 1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1+4]
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_unset_nest_lock, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g1, %o0
	call	omp_unset_nest_lock, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	b	.LL401
	 nop
.LL403:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.5, .-omp_program_main.omp_fn.5
	.ident	"GCC: (GNU) 4.4.3"
