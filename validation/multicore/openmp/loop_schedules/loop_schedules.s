	.file	"loop_schedules.c"
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
	.local	count
	.common	count,260,4
	.align 4
	.type	clear_count, #function
	.proc	020
clear_count:
	save	%sp, -104, %sp
	st	%g0, [%fp-4]
	b	.LL372
	 nop
.LL373:
	ld	[%fp-4], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g0, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL372:
	ld	[%fp-4], %g1
	cmp	%g1, 64
	ble	.LL373
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	clear_count, .-clear_count
	.align 4
	.type	ran_once, #function
	.proc	04
ran_once:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	mov	1, %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-12]
	b	.LL376
	 nop
.LL380:
	st	%g0, [%fp-4]
	ld	[%fp+76], %g1
	cmp	%g1, 0
	ble	.LL377
	 nop
	ld	[%fp-12], %g2
	ld	[%fp+68], %g1
	cmp	%g2, %g1
	bl	.LL377
	 nop
	ld	[%fp-12], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	bge	.LL377
	 nop
	ld	[%fp-12], %g2
	ld	[%fp+68], %g1
	sub	%g2, %g1, %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	ld	[%fp+76], %g2
	nop
	nop
	sdiv	%g1, %g2, %g3
	ld	[%fp+76], %g2
	smul	%g3, %g2, %g2
	sub	%g1, %g2, %g1
	cmp	%g1, 0
	bne	.LL377
	 nop
	mov	1, %g1
	st	%g1, [%fp-4]
.LL377:
	ld	[%fp+76], %g1
	cmp	%g1, 0
	bge	.LL378
	 nop
	ld	[%fp-12], %g2
	ld	[%fp+68], %g1
	cmp	%g2, %g1
	bg	.LL378
	 nop
	ld	[%fp-12], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	ble	.LL378
	 nop
	ld	[%fp+68], %g2
	ld	[%fp-12], %g1
	sub	%g2, %g1, %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	ld	[%fp+76], %g2
	nop
	nop
	sdiv	%g1, %g2, %g3
	ld	[%fp+76], %g2
	smul	%g3, %g2, %g2
	sub	%g1, %g2, %g1
	cmp	%g1, 0
	bne	.LL378
	 nop
	mov	1, %g1
	st	%g1, [%fp-4]
.LL378:
	ld	[%fp-12], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	be	.LL379
	 nop
	st	%g0, [%fp-8]
.LL379:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL376:
	ld	[%fp-12], %g1
	cmp	%g1, 64
	ble	.LL380
	 nop
	ld	[%fp-8], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	ran_once, .-ran_once
	.align 4
	.global omp_program_main
	.type	omp_program_main, #function
	.proc	04
omp_program_main:
	save	%sp, -1328, %sp
	st	%g0, [%fp-1184]
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
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
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL383
	 nop
	st	%g0, [%fp-1180]
.LL383:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.1), %g1
	or	%g1, %lo(omp_program_main.omp_fn.1), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.1, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL384
	 nop
	st	%g0, [%fp-1180]
.LL384:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.2), %g1
	or	%g1, %lo(omp_program_main.omp_fn.2), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.2, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL385
	 nop
	st	%g0, [%fp-1180]
.LL385:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.3), %g1
	or	%g1, %lo(omp_program_main.omp_fn.3), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.3, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL386
	 nop
	st	%g0, [%fp-1180]
.LL386:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.4), %g1
	or	%g1, %lo(omp_program_main.omp_fn.4), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.4, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL387
	 nop
	st	%g0, [%fp-1180]
.LL387:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.5), %g1
	or	%g1, %lo(omp_program_main.omp_fn.5), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.5, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL388
	 nop
	st	%g0, [%fp-1180]
.LL388:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	be	.LL389
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-1184]
.LL389:
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.6), %g1
	or	%g1, %lo(omp_program_main.omp_fn.6), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.6, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL390
	 nop
	st	%g0, [%fp-1180]
.LL390:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.7), %g1
	or	%g1, %lo(omp_program_main.omp_fn.7), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.7, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL391
	 nop
	st	%g0, [%fp-1180]
.LL391:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.8), %g1
	or	%g1, %lo(omp_program_main.omp_fn.8), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.8, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL392
	 nop
	st	%g0, [%fp-1180]
.LL392:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.9), %g1
	or	%g1, %lo(omp_program_main.omp_fn.9), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.9, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL393
	 nop
	st	%g0, [%fp-1180]
.LL393:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.10), %g1
	or	%g1, %lo(omp_program_main.omp_fn.10), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.10, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL394
	 nop
	st	%g0, [%fp-1180]
.LL394:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.11), %g1
	or	%g1, %lo(omp_program_main.omp_fn.11), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.11, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL395
	 nop
	st	%g0, [%fp-1180]
.LL395:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	be	.LL396
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-1184]
.LL396:
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.12), %g1
	or	%g1, %lo(omp_program_main.omp_fn.12), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.12, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL397
	 nop
	st	%g0, [%fp-1180]
.LL397:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.13), %g1
	or	%g1, %lo(omp_program_main.omp_fn.13), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.13, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL398
	 nop
	st	%g0, [%fp-1180]
.LL398:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.14), %g1
	or	%g1, %lo(omp_program_main.omp_fn.14), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.14, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL399
	 nop
	st	%g0, [%fp-1180]
.LL399:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.15), %g1
	or	%g1, %lo(omp_program_main.omp_fn.15), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.15, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL400
	 nop
	st	%g0, [%fp-1180]
.LL400:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.16), %g1
	or	%g1, %lo(omp_program_main.omp_fn.16), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.16, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL401
	 nop
	st	%g0, [%fp-1180]
.LL401:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.17), %g1
	or	%g1, %lo(omp_program_main.omp_fn.17), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.17, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL402
	 nop
	st	%g0, [%fp-1180]
.LL402:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	be	.LL403
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-1184]
.LL403:
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	mov	5, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.18), %g1
	or	%g1, %lo(omp_program_main.omp_fn.18), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.18, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL404
	 nop
	st	%g0, [%fp-1180]
.LL404:
	call	clear_count, 0
	 nop
	mov	5, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.19), %g1
	or	%g1, %lo(omp_program_main.omp_fn.19), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.19, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL405
	 nop
	st	%g0, [%fp-1180]
.LL405:
	call	clear_count, 0
	 nop
	mov	5, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.20), %g1
	or	%g1, %lo(omp_program_main.omp_fn.20), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.20, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL406
	 nop
	st	%g0, [%fp-1180]
.LL406:
	call	clear_count, 0
	 nop
	mov	5, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.21), %g1
	or	%g1, %lo(omp_program_main.omp_fn.21), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.21, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL407
	 nop
	st	%g0, [%fp-1180]
.LL407:
	call	clear_count, 0
	 nop
	mov	5, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.22), %g1
	or	%g1, %lo(omp_program_main.omp_fn.22), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.22, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL408
	 nop
	st	%g0, [%fp-1180]
.LL408:
	call	clear_count, 0
	 nop
	mov	5, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.23), %g1
	or	%g1, %lo(omp_program_main.omp_fn.23), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.23, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL409
	 nop
	st	%g0, [%fp-1180]
.LL409:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	be	.LL410
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-1184]
.LL410:
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.24), %g1
	or	%g1, %lo(omp_program_main.omp_fn.24), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.24, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL411
	 nop
	st	%g0, [%fp-1180]
.LL411:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.25), %g1
	or	%g1, %lo(omp_program_main.omp_fn.25), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.25, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL412
	 nop
	st	%g0, [%fp-1180]
.LL412:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.26), %g1
	or	%g1, %lo(omp_program_main.omp_fn.26), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.26, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL413
	 nop
	st	%g0, [%fp-1180]
.LL413:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.27), %g1
	or	%g1, %lo(omp_program_main.omp_fn.27), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.27, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL414
	 nop
	st	%g0, [%fp-1180]
.LL414:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.28), %g1
	or	%g1, %lo(omp_program_main.omp_fn.28), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.28, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL415
	 nop
	st	%g0, [%fp-1180]
.LL415:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.29), %g1
	or	%g1, %lo(omp_program_main.omp_fn.29), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.29, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL416
	 nop
	st	%g0, [%fp-1180]
.LL416:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	be	.LL417
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-1184]
.LL417:
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.30), %g1
	or	%g1, %lo(omp_program_main.omp_fn.30), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.30, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL418
	 nop
	st	%g0, [%fp-1180]
.LL418:
	call	clear_count, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.31), %g1
	or	%g1, %lo(omp_program_main.omp_fn.31), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.31, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL419
	 nop
	st	%g0, [%fp-1180]
.LL419:
	call	clear_count, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.32), %g1
	or	%g1, %lo(omp_program_main.omp_fn.32), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.32, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL420
	 nop
	st	%g0, [%fp-1180]
.LL420:
	call	clear_count, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.33), %g1
	or	%g1, %lo(omp_program_main.omp_fn.33), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.33, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL421
	 nop
	st	%g0, [%fp-1180]
.LL421:
	call	clear_count, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.34), %g1
	or	%g1, %lo(omp_program_main.omp_fn.34), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.34, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL422
	 nop
	st	%g0, [%fp-1180]
.LL422:
	call	clear_count, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.35), %g1
	or	%g1, %lo(omp_program_main.omp_fn.35), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.35, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL423
	 nop
	st	%g0, [%fp-1180]
.LL423:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	be	.LL424
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 32, %g1
	st	%g1, [%fp-1184]
.LL424:
	mov	1, %g1
	st	%g1, [%fp-860]
	mov	1, %o0
	mov	4, %o1
	call	omp_set_schedule, 0
	 nop
	add	%fp, -1204, %g2
	add	%fp, -1208, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	omp_get_schedule, 0
	 nop
	ld	[%fp-1204], %g1
	cmp	%g1, 1
	bne	.LL425
	 nop
	ld	[%fp-1208], %g1
	cmp	%g1, 4
	be	.LL426
	 nop
.LL425:
	st	%g0, [%fp-860]
.LL426:
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.36), %g1
	or	%g1, %lo(omp_program_main.omp_fn.36), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.36, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL427
	 nop
	st	%g0, [%fp-1180]
.LL427:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.37), %g1
	or	%g1, %lo(omp_program_main.omp_fn.37), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.37, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL428
	 nop
	st	%g0, [%fp-1180]
.LL428:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.38), %g1
	or	%g1, %lo(omp_program_main.omp_fn.38), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.38, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL429
	 nop
	st	%g0, [%fp-1180]
.LL429:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.39), %g1
	or	%g1, %lo(omp_program_main.omp_fn.39), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.39, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL430
	 nop
	st	%g0, [%fp-1180]
.LL430:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.40), %g1
	or	%g1, %lo(omp_program_main.omp_fn.40), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.40, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL431
	 nop
	st	%g0, [%fp-1180]
.LL431:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.41), %g1
	or	%g1, %lo(omp_program_main.omp_fn.41), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.41, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL432
	 nop
	st	%g0, [%fp-1180]
.LL432:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	bne	.LL433
	 nop
	st	%g0, [%fp-860]
.LL433:
	mov	1, %o0
	mov	0, %o1
	call	omp_set_schedule, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.42), %g1
	or	%g1, %lo(omp_program_main.omp_fn.42), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.42, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL434
	 nop
	st	%g0, [%fp-1180]
.LL434:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.43), %g1
	or	%g1, %lo(omp_program_main.omp_fn.43), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.43, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL435
	 nop
	st	%g0, [%fp-1180]
.LL435:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.44), %g1
	or	%g1, %lo(omp_program_main.omp_fn.44), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.44, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL436
	 nop
	st	%g0, [%fp-1180]
.LL436:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.45), %g1
	or	%g1, %lo(omp_program_main.omp_fn.45), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.45, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL437
	 nop
	st	%g0, [%fp-1180]
.LL437:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.46), %g1
	or	%g1, %lo(omp_program_main.omp_fn.46), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.46, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL438
	 nop
	st	%g0, [%fp-1180]
.LL438:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.47), %g1
	or	%g1, %lo(omp_program_main.omp_fn.47), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.47, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL439
	 nop
	st	%g0, [%fp-1180]
.LL439:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	bne	.LL440
	 nop
	st	%g0, [%fp-860]
.LL440:
	mov	2, %o0
	mov	3, %o1
	call	omp_set_schedule, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.48), %g1
	or	%g1, %lo(omp_program_main.omp_fn.48), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.48, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL441
	 nop
	st	%g0, [%fp-1180]
.LL441:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.49), %g1
	or	%g1, %lo(omp_program_main.omp_fn.49), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.49, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL442
	 nop
	st	%g0, [%fp-1180]
.LL442:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.50), %g1
	or	%g1, %lo(omp_program_main.omp_fn.50), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.50, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL443
	 nop
	st	%g0, [%fp-1180]
.LL443:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.51), %g1
	or	%g1, %lo(omp_program_main.omp_fn.51), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.51, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL444
	 nop
	st	%g0, [%fp-1180]
.LL444:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.52), %g1
	or	%g1, %lo(omp_program_main.omp_fn.52), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.52, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL445
	 nop
	st	%g0, [%fp-1180]
.LL445:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.53), %g1
	or	%g1, %lo(omp_program_main.omp_fn.53), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.53, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL446
	 nop
	st	%g0, [%fp-1180]
.LL446:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	bne	.LL447
	 nop
	st	%g0, [%fp-860]
.LL447:
	mov	3, %o0
	mov	2, %o1
	call	omp_set_schedule, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-1180]
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.54), %g1
	or	%g1, %lo(omp_program_main.omp_fn.54), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.54, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL448
	 nop
	st	%g0, [%fp-1180]
.LL448:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.55), %g1
	or	%g1, %lo(omp_program_main.omp_fn.55), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	3, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.55, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	3, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL449
	 nop
	st	%g0, [%fp-1180]
.LL449:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.56), %g1
	or	%g1, %lo(omp_program_main.omp_fn.56), %o0
	mov	0, %o1
	mov	0, %o2
	mov	64, %o3
	mov	0, %o4
	mov	-2, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.56, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	64, %o0
	mov	0, %o1
	mov	-2, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL450
	 nop
	st	%g0, [%fp-1180]
.LL450:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.57), %g1
	or	%g1, %lo(omp_program_main.omp_fn.57), %o0
	mov	0, %o1
	mov	0, %o2
	mov	10, %o3
	mov	13, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.57, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	10, %o0
	mov	13, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL451
	 nop
	st	%g0, [%fp-1180]
.LL451:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.58), %g1
	or	%g1, %lo(omp_program_main.omp_fn.58), %o0
	mov	0, %o1
	mov	0, %o2
	mov	7, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.58, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	7, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL452
	 nop
	st	%g0, [%fp-1180]
.LL452:
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.59), %g1
	or	%g1, %lo(omp_program_main.omp_fn.59), %o0
	mov	0, %o1
	mov	0, %o2
	mov	8, %o3
	mov	8, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.59, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	8, %o0
	mov	8, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL453
	 nop
	st	%g0, [%fp-1180]
.LL453:
	ld	[%fp-1180], %g1
	cmp	%g1, 0
	bne	.LL454
	 nop
	st	%g0, [%fp-860]
.LL454:
	ld	[%fp-860], %g1
	cmp	%g1, 0
	be	.LL455
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 64, %g1
	st	%g1, [%fp-1184]
.LL455:
	mov	1, %g1
	st	%g1, [%fp-648]
	call	clear_count, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.60), %g1
	or	%g1, %lo(omp_program_main.omp_fn.60), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.60, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL456
	 nop
	st	%g0, [%fp-648]
.LL456:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.61), %g1
	or	%g1, %lo(omp_program_main.omp_fn.61), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.61, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL457
	 nop
	st	%g0, [%fp-648]
.LL457:
	mov	1, %o0
	mov	2, %o1
	call	omp_set_schedule, 0
	 nop
	call	clear_count, 0
	 nop
	sethi	%hi(omp_program_main.omp_fn.62), %g1
	or	%g1, %lo(omp_program_main.omp_fn.62), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_runtime_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.62, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL458
	 nop
	st	%g0, [%fp-648]
.LL458:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.63), %g1
	or	%g1, %lo(omp_program_main.omp_fn.63), %o0
	mov	0, %o1
	mov	2, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.63, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL459
	 nop
	st	%g0, [%fp-648]
.LL459:
	call	clear_count, 0
	 nop
	mov	3, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.64), %g1
	or	%g1, %lo(omp_program_main.omp_fn.64), %o0
	mov	0, %o1
	mov	3, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.64, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL460
	 nop
	st	%g0, [%fp-648]
.LL460:
	call	clear_count, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.65), %g1
	or	%g1, %lo(omp_program_main.omp_fn.65), %o0
	mov	0, %o1
	mov	1, %o2
	mov	0, %o3
	mov	64, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.65, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	0, %o0
	mov	64, %o1
	mov	1, %o2
	call	ran_once, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL461
	 nop
	st	%g0, [%fp-648]
.LL461:
	ld	[%fp-648], %g1
	cmp	%g1, 0
	be	.LL462
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 128, %g1
	st	%g1, [%fp-1184]
.LL462:
	mov	1, %g1
	st	%g1, [%fp-596]
	sethi	%hi(omp_program_main.omp_fn.66), %g1
	or	%g1, %lo(omp_program_main.omp_fn.66), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.66, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	st	%g0, [%fp-588]
	st	%g0, [%fp-584]
	sethi	%hi(owner.2666), %g1
	or	%g1, %lo(owner.2666), %g1
	ld	[%g1], %g1
	cmp	%g1, 0
	be	.LL463
	 nop
	st	%g0, [%fp-596]
.LL463:
	st	%g0, [%fp-1176]
	b	.LL464
	 nop
.LL469:
	ld	[%fp-1176], %g1
	sethi	%hi(owner.2666), %g2
	or	%g2, %lo(owner.2666), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-584], %g1
	cmp	%g2, %g1
	bne	.LL465
	 nop
	ld	[%fp-588], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-588]
	b	.LL466
	 nop
.LL465:
	ld	[%fp-1176], %g1
	sethi	%hi(owner.2666), %g2
	or	%g2, %lo(owner.2666), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-584], %g1
	add	%g1, 1, %g1
	cmp	%g2, %g1
	be	.LL467
	 nop
	st	%g0, [%fp-596]
.LL467:
	ld	[%fp-1176], %g1
	sethi	%hi(owner.2666), %g2
	or	%g2, %lo(owner.2666), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-584]
	mov	1, %g1
	st	%g1, [%fp-588]
.LL466:
	ld	[%fp-588], %g1
	cmp	%g1, 3
	ble	.LL468
	 nop
	st	%g0, [%fp-596]
.LL468:
	ld	[%fp-1176], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-1176]
.LL464:
	ld	[%fp-1176], %g1
	cmp	%g1, 9
	ble	.LL469
	 nop
	sethi	%hi(omp_program_main.omp_fn.67), %g1
	or	%g1, %lo(omp_program_main.omp_fn.67), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.67, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	st	%g0, [%fp-1176]
	b	.LL470
	 nop
.LL472:
	ld	[%fp-1176], %g1
	sethi	%hi(owner.2666), %g2
	or	%g2, %lo(owner.2666), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g3
	ld	[%fp-1176], %g1
	srl	%g1, 31, %g2
	add	%g2, %g1, %g1
	sra	%g1, 1, %g1
	mov	%g1, %g2
	sra	%g2, 31, %g1
	srl	%g1, 30, %g1
	add	%g2, %g1, %g2
	and	%g2, 3, %g2
	sub	%g2, %g1, %g1
	cmp	%g3, %g1
	be	.LL471
	 nop
	st	%g0, [%fp-596]
.LL471:
	ld	[%fp-1176], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-1176]
.LL470:
	ld	[%fp-1176], %g1
	cmp	%g1, 9
	ble	.LL472
	 nop
	ld	[%fp-596], %g1
	cmp	%g1, 0
	be	.LL473
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 256, %g1
	st	%g1, [%fp-1184]
.LL473:
	st	%g0, [%fp-576]
	ld	[%fp-576], %g1
	st	%g1, [%fp-1200]
	add	%fp, -1200, %g1
	sethi	%hi(omp_program_main.omp_fn.68), %g2
	or	%g2, %lo(omp_program_main.omp_fn.68), %o0
	mov	%g1, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -1200, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.68, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-1200], %g1
	st	%g1, [%fp-576]
	ld	[%fp-576], %g2
	sethi	%hi(4096), %g1
	or	%g1, 954, %g1
	cmp	%g2, %g1
	bne	.LL474
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 512, %g1
	st	%g1, [%fp-1184]
.LL474:
	mov	5, %g1
	st	%g1, [%fp-1212]
	mov	2, %g1
	st	%g1, [%fp-1216]
	st	%g0, [%fp-1220]
	ld	[%fp-1212], %g1
	st	%g1, [%fp-1196]
	ld	[%fp-1216], %g1
	st	%g1, [%fp-1192]
	ld	[%fp-1220], %g1
	st	%g1, [%fp-1188]
	add	%fp, -1196, %g1
	sethi	%hi(omp_program_main.omp_fn.69), %g2
	or	%g2, %lo(omp_program_main.omp_fn.69), %o0
	mov	%g1, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	add	%fp, -1196, %g1
	mov	%g1, %o0
	call	omp_program_main.omp_fn.69, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	ld	[%fp-1196], %g1
	st	%g1, [%fp-1212]
	ld	[%fp-1192], %g1
	st	%g1, [%fp-1216]
	ld	[%fp-1188], %g1
	st	%g1, [%fp-1220]
	ld	[%fp-1220], %g1
	cmp	%g1, 0
	bne	.LL475
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 1024, %g1
	st	%g1, [%fp-1184]
.LL475:
	mov	1, %g1
	st	%g1, [%fp-540]
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.70), %g1
	or	%g1, %lo(omp_program_main.omp_fn.70), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	40, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.70, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-1176]
	b	.LL476
	 nop
.LL478:
	ld	[%fp-1176], %g1
	sethi	%hi(owner.2680), %g2
	or	%g2, %lo(owner.2680), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	sethi	%hi(owner.2680), %g1
	or	%g1, %lo(owner.2680), %g1
	ld	[%g1], %g1
	cmp	%g2, %g1
	be	.LL477
	 nop
	st	%g0, [%fp-540]
.LL477:
	ld	[%fp-1176], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-1176]
.LL476:
	ld	[%fp-1176], %g1
	cmp	%g1, 9
	ble	.LL478
	 nop
	ld	[%fp-540], %g1
	cmp	%g1, 0
	be	.LL479
	 nop
	ld	[%fp-1184], %g1
	or	%g1, 2048, %g1
	st	%g1, [%fp-1184]
.LL479:
	mov	1, %g1
	st	%g1, [%fp-520]
	sethi	%hi(omp_program_main.omp_fn.71), %g1
	or	%g1, %lo(omp_program_main.omp_fn.71), %o0
	mov	0, %o1
	mov	0, %o2
	call	GOMP_parallel_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.71, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	2, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.72), %g1
	or	%g1, %lo(omp_program_main.omp_fn.72), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	30, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_dynamic_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.72, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	mov	1, %g1
	st	%g1, [%sp+92]
	sethi	%hi(omp_program_main.omp_fn.73), %g1
	or	%g1, %lo(omp_program_main.omp_fn.73), %o0
	mov	0, %o1
	mov	0, %o2
	mov	0, %o3
	mov	30, %o4
	mov	1, %o5
	call	GOMP_parallel_loop_guided_start, 0
	 nop
	mov	0, %o0
	call	omp_program_main.omp_fn.73, 0
	 nop
	call	GOMP_parallel_end, 0
	 nop
	st	%g0, [%fp-1176]
	b	.LL480
	 nop
.LL484:
	st	%g0, [%fp-524]
	b	.LL481
	 nop
.LL483:
	ld	[%fp-1176], %g2
	ld	[%fp-524], %g4
	sethi	%hi(cell.2689), %g1
	or	%g1, %lo(cell.2689), %g3
	mov	%g2, %g1
	sll	%g1, 2, %g1
	add	%g1, %g2, %g1
	add	%g1, %g4, %g1
	sll	%g1, 2, %g1
	ld	[%g3+%g1], %g1
	cmp	%g1, 3
	be	.LL482
	 nop
	st	%g0, [%fp-520]
.LL482:
	ld	[%fp-524], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-524]
.LL481:
	ld	[%fp-524], %g1
	cmp	%g1, 4
	ble	.LL483
	 nop
	ld	[%fp-1176], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-1176]
.LL480:
	ld	[%fp-1176], %g1
	cmp	%g1, 5
	ble	.LL484
	 nop
	ld	[%fp-520], %g1
	cmp	%g1, 0
	be	.LL485
	 nop
	ld	[%fp-1184], %g2
	sethi	%hi(4096), %g1
	or	%g2, %g1, %g1
	st	%g1, [%fp-1184]
.LL485:
	ld	[%fp-1184], %o0
	mov	13, %o1
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
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l0
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g3
	mov	64, %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	nop
	nop
	nop
	sdiv	%g1, %l0, %g1
	smul	%g1, %l0, %g2
	xor	%g2, 64, %g2
	subcc	%g0, %g2, %g0
	addx	%g0, 0, %g2
	add	%g2, %g1, %g2
	smul	%g2, %g3, %g1
	add	%g1, %g2, %g2
	mov	%g2, %l0
	cmp	%l0, 64
	ble	.LL488
	 nop
	mov	64, %l0
.LL488:
	cmp	%g1, %l0
	bge	.LL491
	 nop
	st	%g1, [%fp-8]
.LL490:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL490
	 nop
.LL491:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.0, .-omp_program_main.omp_fn.0
	.align 4
	.type	omp_program_main.omp_fn.1, #function
	.proc	020
omp_program_main.omp_fn.1:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l0
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g2
	mov	22, %g1
	sra	%g1, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g1, %l0, %g1
	smul	%g1, %l0, %g3
	xor	%g3, 22, %g3
	subcc	%g0, %g3, %g0
	addx	%g0, 0, %g3
	add	%g3, %g1, %g1
	smul	%g1, %g2, %g2
	add	%g2, %g1, %g1
	cmp	%g1, 22
	ble	.LL493
	 nop
	mov	22, %g1
.LL493:
	cmp	%g2, %g1
	bge	.LL494
	 nop
	mov	%g2, %g3
	add	%g3, %g3, %g3
	add	%g3, %g2, %g2
	st	%g2, [%fp-8]
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %l0
.LL495:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL495
	 nop
.LL494:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.1, .-omp_program_main.omp_fn.1
	.align 4
	.type	omp_program_main.omp_fn.2, #function
	.proc	020
omp_program_main.omp_fn.2:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l0
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g2
	mov	32, %g1
	sra	%g1, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g1, %l0, %g1
	smul	%g1, %l0, %g3
	xor	%g3, 32, %g3
	subcc	%g0, %g3, %g0
	addx	%g0, 0, %g3
	add	%g3, %g1, %g1
	smul	%g1, %g2, %g2
	add	%g2, %g1, %g1
	cmp	%g1, 32
	ble	.LL498
	 nop
	mov	32, %g1
.LL498:
	cmp	%g2, %g1
	bge	.LL499
	 nop
	mov	32, %g3
	sub	%g3, %g2, %g2
	add	%g2, %g2, %g2
	st	%g2, [%fp-8]
	mov	32, %g2
	sub	%g2, %g1, %g1
	add	%g1, %g1, %g1
	mov	%g1, %l0
.LL500:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL500
	 nop
.LL499:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.2, .-omp_program_main.omp_fn.2
	.align 4
	.type	omp_program_main.omp_fn.3, #function
	.proc	020
omp_program_main.omp_fn.3:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l0
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g2
	mov	3, %g1
	sra	%g1, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g1, %l0, %g1
	smul	%g1, %l0, %g3
	xor	%g3, 3, %g3
	subcc	%g0, %g3, %g0
	addx	%g0, 0, %g3
	add	%g3, %g1, %g1
	smul	%g1, %g2, %g2
	add	%g2, %g1, %g1
	cmp	%g1, 3
	ble	.LL503
	 nop
	mov	3, %g1
.LL503:
	cmp	%g2, %g1
	bge	.LL504
	 nop
	add	%g2, 10, %g2
	st	%g2, [%fp-8]
	add	%g1, 10, %l0
.LL505:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL505
	 nop
.LL504:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.3, .-omp_program_main.omp_fn.3
	.align 4
	.type	omp_program_main.omp_fn.4, #function
	.proc	020
omp_program_main.omp_fn.4:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l0
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g2
	mov	1, %g1
	sra	%g1, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g1, %l0, %g1
	smul	%g1, %l0, %g3
	xor	%g3, 1, %g3
	subcc	%g0, %g3, %g0
	addx	%g0, 0, %g3
	add	%g3, %g1, %g1
	smul	%g1, %g2, %g2
	add	%g2, %g1, %g1
	cmp	%g1, 0
	ble	.LL508
	 nop
	mov	1, %g1
.LL508:
	cmp	%g2, %g1
	bge	.LL509
	 nop
	add	%g2, 7, %g2
	st	%g2, [%fp-8]
	add	%g1, 7, %l0
.LL510:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL510
	 nop
.LL509:
	call	GOMP_barrier, 0
	 nop
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
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l0
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g2
	mov	0, %g1
	sra	%g1, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g1, %l0, %g1
	smul	%g1, %l0, %g3
	xor	%g3, 0, %g3
	subcc	%g0, %g3, %g0
	addx	%g0, 0, %g3
	add	%g3, %g1, %g1
	smul	%g1, %g2, %g2
	add	%g2, %g1, %g1
	cmp	%g1, 0
	ble	.LL513
	 nop
	mov	0, %g1
.LL513:
	cmp	%g2, %g1
	bge	.LL514
	 nop
	add	%g2, 8, %g2
	st	%g2, [%fp-8]
	add	%g1, 8, %l0
.LL515:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL515
	 nop
.LL514:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.5, .-omp_program_main.omp_fn.5
	.align 4
	.type	omp_program_main.omp_fn.6, #function
	.proc	020
omp_program_main.omp_fn.6:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l3
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %l2
	mov	0, %l0
.LL521:
	smul	%l0, %l3, %g1
	add	%g1, %l2, %g1
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %g1
	add	%g1, 3, %g2
	mov	%g2, %l1
	cmp	%l1, 64
	ble	.LL518
	 nop
	mov	64, %l1
.LL518:
	cmp	%g1, 64
	bge	.LL522
	 nop
	st	%g1, [%fp-8]
.LL520:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l1
	bl	.LL520
	 nop
	add	%l0, 1, %l0
	b	.LL521
	 nop
.LL522:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.6, .-omp_program_main.omp_fn.6
	.align 4
	.type	omp_program_main.omp_fn.7, #function
	.proc	020
omp_program_main.omp_fn.7:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l2
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %l1
	mov	0, %l0
.LL527:
	smul	%l0, %l2, %g1
	add	%g1, %l1, %g1
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %g2
	add	%g2, 3, %g1
	cmp	%g1, 22
	ble	.LL524
	 nop
	mov	22, %g1
.LL524:
	cmp	%g2, 22
	bge	.LL525
	 nop
	mov	%g2, %g3
	add	%g3, %g3, %g3
	add	%g3, %g2, %g2
	st	%g2, [%fp-8]
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %l3
.LL526:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l3
	bl	.LL526
	 nop
	add	%l0, 1, %l0
	b	.LL527
	 nop
.LL525:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.7, .-omp_program_main.omp_fn.7
	.align 4
	.type	omp_program_main.omp_fn.8, #function
	.proc	020
omp_program_main.omp_fn.8:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l2
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %l1
	mov	0, %l0
.LL533:
	smul	%l0, %l2, %g1
	add	%g1, %l1, %g1
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %g2
	add	%g2, 3, %g1
	cmp	%g1, 32
	ble	.LL530
	 nop
	mov	32, %g1
.LL530:
	cmp	%g2, 32
	bge	.LL531
	 nop
	mov	32, %g3
	sub	%g3, %g2, %g2
	add	%g2, %g2, %g2
	st	%g2, [%fp-8]
	mov	32, %g2
	sub	%g2, %g1, %g1
	add	%g1, %g1, %g1
	mov	%g1, %l3
.LL532:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l3
	bg	.LL532
	 nop
	add	%l0, 1, %l0
	b	.LL533
	 nop
.LL531:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.8, .-omp_program_main.omp_fn.8
	.align 4
	.type	omp_program_main.omp_fn.9, #function
	.proc	020
omp_program_main.omp_fn.9:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l2
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %l1
	mov	0, %l0
.LL539:
	smul	%l0, %l2, %g1
	add	%g1, %l1, %g1
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %g2
	add	%g2, 3, %g1
	cmp	%g1, 3
	ble	.LL536
	 nop
	mov	3, %g1
.LL536:
	cmp	%g2, 3
	bge	.LL537
	 nop
	add	%g2, 10, %g2
	st	%g2, [%fp-8]
	add	%g1, 10, %l3
.LL538:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l3
	bl	.LL538
	 nop
	add	%l0, 1, %l0
	b	.LL539
	 nop
.LL537:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.9, .-omp_program_main.omp_fn.9
	.align 4
	.type	omp_program_main.omp_fn.10, #function
	.proc	020
omp_program_main.omp_fn.10:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l2
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %l1
	mov	0, %l0
.LL545:
	smul	%l0, %l2, %g1
	add	%g1, %l1, %g1
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %g2
	add	%g2, 3, %g1
	cmp	%g1, 0
	ble	.LL542
	 nop
	mov	1, %g1
.LL542:
	cmp	%g2, 0
	bg	.LL543
	 nop
	add	%g2, 7, %g2
	st	%g2, [%fp-8]
	add	%g1, 7, %l3
.LL544:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l3
	bl	.LL544
	 nop
	add	%l0, 1, %l0
	b	.LL545
	 nop
.LL543:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.10, .-omp_program_main.omp_fn.10
	.align 4
	.type	omp_program_main.omp_fn.11, #function
	.proc	020
omp_program_main.omp_fn.11:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l2
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %l1
	mov	0, %l0
.LL551:
	smul	%l0, %l2, %g1
	add	%g1, %l1, %g1
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %g2
	add	%g2, 3, %g1
	cmp	%g1, 0
	ble	.LL548
	 nop
	mov	0, %g1
.LL548:
	cmp	%g2, 0
	bge	.LL549
	 nop
	add	%g2, 8, %g2
	st	%g2, [%fp-8]
	add	%g1, 8, %l3
.LL550:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l3
	bl	.LL550
	 nop
	add	%l0, 1, %l0
	b	.LL551
	 nop
.LL549:
	call	GOMP_barrier, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.11, .-omp_program_main.omp_fn.11
	.align 4
	.type	omp_program_main.omp_fn.12, #function
	.proc	020
omp_program_main.omp_fn.12:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL554
	 nop
.LL556:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL555:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL555
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL556
	 nop
.LL554:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.12, .-omp_program_main.omp_fn.12
	.align 4
	.type	omp_program_main.omp_fn.13, #function
	.proc	020
omp_program_main.omp_fn.13:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL559
	 nop
.LL561:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL560:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL560
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL561
	 nop
.LL559:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.13, .-omp_program_main.omp_fn.13
	.align 4
	.type	omp_program_main.omp_fn.14, #function
	.proc	020
omp_program_main.omp_fn.14:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL564
	 nop
.LL566:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL565:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL565
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL566
	 nop
.LL564:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.14, .-omp_program_main.omp_fn.14
	.align 4
	.type	omp_program_main.omp_fn.15, #function
	.proc	020
omp_program_main.omp_fn.15:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL569
	 nop
.LL571:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL570:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL570
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL571
	 nop
.LL569:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.15, .-omp_program_main.omp_fn.15
	.align 4
	.type	omp_program_main.omp_fn.16, #function
	.proc	020
omp_program_main.omp_fn.16:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL574
	 nop
.LL576:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL575:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL575
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL576
	 nop
.LL574:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.16, .-omp_program_main.omp_fn.16
	.align 4
	.type	omp_program_main.omp_fn.17, #function
	.proc	020
omp_program_main.omp_fn.17:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL579
	 nop
.LL581:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL580:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL580
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL581
	 nop
.LL579:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.17, .-omp_program_main.omp_fn.17
	.align 4
	.type	omp_program_main.omp_fn.18, #function
	.proc	020
omp_program_main.omp_fn.18:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL584
	 nop
.LL586:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL585:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL585
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL586
	 nop
.LL584:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.18, .-omp_program_main.omp_fn.18
	.align 4
	.type	omp_program_main.omp_fn.19, #function
	.proc	020
omp_program_main.omp_fn.19:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL589
	 nop
.LL591:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL590:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL590
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL591
	 nop
.LL589:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.19, .-omp_program_main.omp_fn.19
	.align 4
	.type	omp_program_main.omp_fn.20, #function
	.proc	020
omp_program_main.omp_fn.20:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL594
	 nop
.LL596:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL595:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL595
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL596
	 nop
.LL594:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.20, .-omp_program_main.omp_fn.20
	.align 4
	.type	omp_program_main.omp_fn.21, #function
	.proc	020
omp_program_main.omp_fn.21:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL599
	 nop
.LL601:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL600:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL600
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL601
	 nop
.LL599:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.21, .-omp_program_main.omp_fn.21
	.align 4
	.type	omp_program_main.omp_fn.22, #function
	.proc	020
omp_program_main.omp_fn.22:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL604
	 nop
.LL606:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL605:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL605
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL606
	 nop
.LL604:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.22, .-omp_program_main.omp_fn.22
	.align 4
	.type	omp_program_main.omp_fn.23, #function
	.proc	020
omp_program_main.omp_fn.23:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL609
	 nop
.LL611:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL610:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL610
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL611
	 nop
.LL609:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.23, .-omp_program_main.omp_fn.23
	.align 4
	.type	omp_program_main.omp_fn.24, #function
	.proc	020
omp_program_main.omp_fn.24:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL614
	 nop
.LL616:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL615:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL615
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL616
	 nop
.LL614:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.24, .-omp_program_main.omp_fn.24
	.align 4
	.type	omp_program_main.omp_fn.25, #function
	.proc	020
omp_program_main.omp_fn.25:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL619
	 nop
.LL621:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL620:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL620
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL621
	 nop
.LL619:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.25, .-omp_program_main.omp_fn.25
	.align 4
	.type	omp_program_main.omp_fn.26, #function
	.proc	020
omp_program_main.omp_fn.26:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL624
	 nop
.LL626:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL625:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL625
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL626
	 nop
.LL624:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.26, .-omp_program_main.omp_fn.26
	.align 4
	.type	omp_program_main.omp_fn.27, #function
	.proc	020
omp_program_main.omp_fn.27:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL629
	 nop
.LL631:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL630:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL630
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL631
	 nop
.LL629:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.27, .-omp_program_main.omp_fn.27
	.align 4
	.type	omp_program_main.omp_fn.28, #function
	.proc	020
omp_program_main.omp_fn.28:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL634
	 nop
.LL636:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL635:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL635
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL636
	 nop
.LL634:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.28, .-omp_program_main.omp_fn.28
	.align 4
	.type	omp_program_main.omp_fn.29, #function
	.proc	020
omp_program_main.omp_fn.29:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL639
	 nop
.LL641:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL640:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL640
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL641
	 nop
.LL639:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.29, .-omp_program_main.omp_fn.29
	.align 4
	.type	omp_program_main.omp_fn.30, #function
	.proc	020
omp_program_main.omp_fn.30:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL644
	 nop
.LL646:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL645:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL645
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL646
	 nop
.LL644:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.30, .-omp_program_main.omp_fn.30
	.align 4
	.type	omp_program_main.omp_fn.31, #function
	.proc	020
omp_program_main.omp_fn.31:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL649
	 nop
.LL651:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL650:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL650
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL651
	 nop
.LL649:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.31, .-omp_program_main.omp_fn.31
	.align 4
	.type	omp_program_main.omp_fn.32, #function
	.proc	020
omp_program_main.omp_fn.32:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL654
	 nop
.LL656:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL655:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL655
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL656
	 nop
.LL654:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.32, .-omp_program_main.omp_fn.32
	.align 4
	.type	omp_program_main.omp_fn.33, #function
	.proc	020
omp_program_main.omp_fn.33:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL659
	 nop
.LL661:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL660:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL660
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL661
	 nop
.LL659:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.33, .-omp_program_main.omp_fn.33
	.align 4
	.type	omp_program_main.omp_fn.34, #function
	.proc	020
omp_program_main.omp_fn.34:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL664
	 nop
.LL666:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL665:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL665
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL666
	 nop
.LL664:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.34, .-omp_program_main.omp_fn.34
	.align 4
	.type	omp_program_main.omp_fn.35, #function
	.proc	020
omp_program_main.omp_fn.35:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL669
	 nop
.LL671:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL670:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL670
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL671
	 nop
.LL669:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.35, .-omp_program_main.omp_fn.35
	.align 4
	.type	omp_program_main.omp_fn.36, #function
	.proc	020
omp_program_main.omp_fn.36:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL674
	 nop
.LL676:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL675:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL675
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL676
	 nop
.LL674:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.36, .-omp_program_main.omp_fn.36
	.align 4
	.type	omp_program_main.omp_fn.37, #function
	.proc	020
omp_program_main.omp_fn.37:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL679
	 nop
.LL681:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL680:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL680
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL681
	 nop
.LL679:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.37, .-omp_program_main.omp_fn.37
	.align 4
	.type	omp_program_main.omp_fn.38, #function
	.proc	020
omp_program_main.omp_fn.38:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL684
	 nop
.LL686:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL685:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL685
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL686
	 nop
.LL684:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.38, .-omp_program_main.omp_fn.38
	.align 4
	.type	omp_program_main.omp_fn.39, #function
	.proc	020
omp_program_main.omp_fn.39:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL689
	 nop
.LL691:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL690:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL690
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL691
	 nop
.LL689:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.39, .-omp_program_main.omp_fn.39
	.align 4
	.type	omp_program_main.omp_fn.40, #function
	.proc	020
omp_program_main.omp_fn.40:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL694
	 nop
.LL696:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL695:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL695
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL696
	 nop
.LL694:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.40, .-omp_program_main.omp_fn.40
	.align 4
	.type	omp_program_main.omp_fn.41, #function
	.proc	020
omp_program_main.omp_fn.41:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL699
	 nop
.LL701:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL700:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL700
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL701
	 nop
.LL699:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.41, .-omp_program_main.omp_fn.41
	.align 4
	.type	omp_program_main.omp_fn.42, #function
	.proc	020
omp_program_main.omp_fn.42:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL704
	 nop
.LL706:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL705:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL705
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL706
	 nop
.LL704:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.42, .-omp_program_main.omp_fn.42
	.align 4
	.type	omp_program_main.omp_fn.43, #function
	.proc	020
omp_program_main.omp_fn.43:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL709
	 nop
.LL711:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL710:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL710
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL711
	 nop
.LL709:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.43, .-omp_program_main.omp_fn.43
	.align 4
	.type	omp_program_main.omp_fn.44, #function
	.proc	020
omp_program_main.omp_fn.44:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL714
	 nop
.LL716:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL715:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL715
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL716
	 nop
.LL714:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.44, .-omp_program_main.omp_fn.44
	.align 4
	.type	omp_program_main.omp_fn.45, #function
	.proc	020
omp_program_main.omp_fn.45:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL719
	 nop
.LL721:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL720:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL720
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL721
	 nop
.LL719:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.45, .-omp_program_main.omp_fn.45
	.align 4
	.type	omp_program_main.omp_fn.46, #function
	.proc	020
omp_program_main.omp_fn.46:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL724
	 nop
.LL726:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL725:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL725
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL726
	 nop
.LL724:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.46, .-omp_program_main.omp_fn.46
	.align 4
	.type	omp_program_main.omp_fn.47, #function
	.proc	020
omp_program_main.omp_fn.47:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL729
	 nop
.LL731:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL730:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL730
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL731
	 nop
.LL729:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.47, .-omp_program_main.omp_fn.47
	.align 4
	.type	omp_program_main.omp_fn.48, #function
	.proc	020
omp_program_main.omp_fn.48:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL734
	 nop
.LL736:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL735:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL735
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL736
	 nop
.LL734:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.48, .-omp_program_main.omp_fn.48
	.align 4
	.type	omp_program_main.omp_fn.49, #function
	.proc	020
omp_program_main.omp_fn.49:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL739
	 nop
.LL741:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL740:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL740
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL741
	 nop
.LL739:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.49, .-omp_program_main.omp_fn.49
	.align 4
	.type	omp_program_main.omp_fn.50, #function
	.proc	020
omp_program_main.omp_fn.50:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL744
	 nop
.LL746:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL745:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL745
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL746
	 nop
.LL744:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.50, .-omp_program_main.omp_fn.50
	.align 4
	.type	omp_program_main.omp_fn.51, #function
	.proc	020
omp_program_main.omp_fn.51:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL749
	 nop
.LL751:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL750:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL750
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL751
	 nop
.LL749:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.51, .-omp_program_main.omp_fn.51
	.align 4
	.type	omp_program_main.omp_fn.52, #function
	.proc	020
omp_program_main.omp_fn.52:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL754
	 nop
.LL756:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL755:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL755
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL756
	 nop
.LL754:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.52, .-omp_program_main.omp_fn.52
	.align 4
	.type	omp_program_main.omp_fn.53, #function
	.proc	020
omp_program_main.omp_fn.53:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL759
	 nop
.LL761:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL760:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL760
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL761
	 nop
.LL759:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.53, .-omp_program_main.omp_fn.53
	.align 4
	.type	omp_program_main.omp_fn.54, #function
	.proc	020
omp_program_main.omp_fn.54:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL764
	 nop
.LL766:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL765:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL765
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL766
	 nop
.LL764:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.54, .-omp_program_main.omp_fn.54
	.align 4
	.type	omp_program_main.omp_fn.55, #function
	.proc	020
omp_program_main.omp_fn.55:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL769
	 nop
.LL771:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL770:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL770
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL771
	 nop
.LL769:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.55, .-omp_program_main.omp_fn.55
	.align 4
	.type	omp_program_main.omp_fn.56, #function
	.proc	020
omp_program_main.omp_fn.56:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL774
	 nop
.LL776:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL775:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, -2, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bg	.LL775
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL776
	 nop
.LL774:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.56, .-omp_program_main.omp_fn.56
	.align 4
	.type	omp_program_main.omp_fn.57, #function
	.proc	020
omp_program_main.omp_fn.57:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL779
	 nop
.LL781:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL780:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL780
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL781
	 nop
.LL779:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.57, .-omp_program_main.omp_fn.57
	.align 4
	.type	omp_program_main.omp_fn.58, #function
	.proc	020
omp_program_main.omp_fn.58:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL784
	 nop
.LL786:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL785:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL785
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL786
	 nop
.LL784:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.58, .-omp_program_main.omp_fn.58
	.align 4
	.type	omp_program_main.omp_fn.59, #function
	.proc	020
omp_program_main.omp_fn.59:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL789
	 nop
.LL791:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL790:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL790
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL791
	 nop
.LL789:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.59, .-omp_program_main.omp_fn.59
	.align 4
	.type	omp_program_main.omp_fn.60, #function
	.proc	020
omp_program_main.omp_fn.60:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL794
	 nop
.LL796:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL795:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL795
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL796
	 nop
.LL794:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.60, .-omp_program_main.omp_fn.60
	.align 4
	.type	omp_program_main.omp_fn.61, #function
	.proc	020
omp_program_main.omp_fn.61:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL799
	 nop
.LL801:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL800:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL800
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL801
	 nop
.LL799:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.61, .-omp_program_main.omp_fn.61
	.align 4
	.type	omp_program_main.omp_fn.62, #function
	.proc	020
omp_program_main.omp_fn.62:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL804
	 nop
.LL806:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL805:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL805
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_runtime_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL806
	 nop
.LL804:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.62, .-omp_program_main.omp_fn.62
	.align 4
	.type	omp_program_main.omp_fn.63, #function
	.proc	020
omp_program_main.omp_fn.63:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL809
	 nop
.LL811:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL810:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL810
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL811
	 nop
.LL809:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.63, .-omp_program_main.omp_fn.63
	.align 4
	.type	omp_program_main.omp_fn.64, #function
	.proc	020
omp_program_main.omp_fn.64:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL814
	 nop
.LL816:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL815:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL815
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL816
	 nop
.LL814:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.64, .-omp_program_main.omp_fn.64
	.align 4
	.type	omp_program_main.omp_fn.65, #function
	.proc	020
omp_program_main.omp_fn.65:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL819
	 nop
.LL821:
	ld	[%fp-16], %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %l0
.LL820:
	call	GOMP_critical_start, 0
	 nop
	ld	[%fp-8], %g1
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
	ld	[%fp-4], %g2
	add	%g2, 1, %g3
	sethi	%hi(count), %g2
	or	%g2, %lo(count), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	call	GOMP_critical_end, 0
	 nop
	ld	[%fp-8], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %g1
	cmp	%g1, %l0
	bl	.LL820
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL821
	 nop
.LL819:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.65, .-omp_program_main.omp_fn.65
	.align 4
	.type	omp_program_main.omp_fn.66, #function
	.proc	020
omp_program_main.omp_fn.66:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l0
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g3
	mov	10, %g1
	sra	%g1, 31, %g2
	wr	%g2, 0, %y
	nop
	nop
	nop
	sdiv	%g1, %l0, %g1
	smul	%g1, %l0, %g2
	xor	%g2, 10, %g2
	subcc	%g0, %g2, %g0
	addx	%g0, 0, %g2
	add	%g2, %g1, %g2
	smul	%g2, %g3, %g1
	add	%g1, %g2, %g2
	mov	%g2, %l0
	cmp	%l0, 10
	ble	.LL824
	 nop
	mov	10, %l0
.LL824:
	cmp	%g1, %l0
	bge	.LL827
	 nop
	st	%g1, [%fp-4]
.LL826:
	ld	[%fp-4], %l1
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g3
	sethi	%hi(owner.2666), %g1
	or	%g1, %lo(owner.2666), %g2
	sll	%l1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, %l0
	bl	.LL826
	 nop
.LL827:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.66, .-omp_program_main.omp_fn.66
	.local	owner.2666
	.common	owner.2666,40,4
	.align 4
	.type	omp_program_main.omp_fn.67, #function
	.proc	020
omp_program_main.omp_fn.67:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l3
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %l2
	mov	0, %l0
.LL832:
	smul	%l0, %l3, %g1
	add	%g1, %l2, %g1
	add	%g1, %g1, %g1
	add	%g1, 2, %g2
	mov	%g2, %l1
	cmp	%l1, 10
	ble	.LL829
	 nop
	mov	10, %l1
.LL829:
	cmp	%g1, 10
	bge	.LL833
	 nop
	st	%g1, [%fp-4]
.LL831:
	ld	[%fp-4], %l4
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g3
	sethi	%hi(owner.2666), %g1
	or	%g1, %lo(owner.2666), %g2
	sll	%l4, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, %l1
	bl	.LL831
	 nop
	add	%l0, 1, %l0
	b	.LL832
	 nop
.LL833:
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.67, .-omp_program_main.omp_fn.67
	.align 4
	.type	omp_program_main.omp_fn.68, #function
	.proc	020
omp_program_main.omp_fn.68:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%g0, [%fp-16]
	add	%fp, -12, %g2
	add	%fp, -8, %g1
	mov	1, %o0
	mov	101, %o1
	mov	1, %o2
	mov	3, %o3
	mov	%g2, %o4
	mov	%g1, %o5
	call	GOMP_loop_dynamic_start, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL835
	 nop
.LL837:
	ld	[%fp-12], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
.LL836:
	ld	[%fp-16], %g3
	ld	[%fp-4], %g2
	add	%g3, %g2, %g2
	st	%g2, [%fp-16]
	ld	[%fp-4], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-4]
	ld	[%fp-4], %g2
	cmp	%g2, %g1
	bl	.LL836
	 nop
	add	%fp, -12, %g2
	add	%fp, -8, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL837
	 nop
.LL835:
	call	GOMP_loop_end_nowait, 0
	 nop
	ld	[%fp+68], %l0
	call	GOMP_atomic_start, 0
	 nop
	ld	[%l0], %g2
	ld	[%fp-16], %g1
	add	%g2, %g1, %g1
	st	%g1, [%l0]
	call	GOMP_atomic_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.68, .-omp_program_main.omp_fn.68
	.align 4
	.type	omp_program_main.omp_fn.69, #function
	.proc	020
omp_program_main.omp_fn.69:
	save	%sp, -160, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	ld	[%g1], %g2
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	mov	%g2, %l0
	mov	%g1, %l2
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l1
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g3
	sub	%l2, %l0, %g2
	sra	%g2, 31, %g4
	wr	%g4, 0, %y
	nop
	nop
	nop
	sdiv	%g2, %l1, %g1
	smul	%g1, %l1, %g4
	xor	%g4, %g2, %g4
	subcc	%g0, %g4, %g0
	addx	%g0, 0, %g4
	add	%g4, %g1, %g1
	smul	%g1, %g3, %g3
	add	%g3, %g1, %g1
	cmp	%g1, %g2
	ble	.LL840
	 nop
	mov	%g2, %g1
.LL840:
	cmp	%g3, %g1
	bge	.LL841
	 nop
	add	%g3, %l0, %g2
	st	%g2, [%fp-60]
	add	%g1, %l0, %g1
.LL842:
	ld	[%fp+68], %g2
	mov	1, %g3
	st	%g3, [%g2+8]
	ld	[%fp-60], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-60]
	ld	[%fp-60], %g2
	cmp	%g2, %g1
	bl	.LL842
	 nop
.LL841:
	call	GOMP_barrier, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1], %g2
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	mov	%g2, %l0
	mov	%g1, %l2
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l1
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %o5
	sub	%l2, %l0, %g2
	mov	0, %g1
.LL846:
	smul	%g1, %l1, %g3
	add	%g3, %o5, %g3
	add	%g3, %g3, %g3
	mov	%g3, %g4
	add	%g4, 2, %g3
	cmp	%g3, %g2
	ble	.LL843
	 nop
	mov	%g2, %g3
.LL843:
	cmp	%g4, %g2
	bge	.LL844
	 nop
	add	%g4, %l0, %g4
	st	%g4, [%fp-56]
	add	%g3, %l0, %g3
.LL845:
	ld	[%fp+68], %g4
	mov	1, %o4
	st	%o4, [%g4+8]
	ld	[%fp-56], %g4
	add	%g4, 1, %g4
	st	%g4, [%fp-56]
	ld	[%fp-56], %g4
	cmp	%g4, %g3
	bl	.LL845
	 nop
	add	%g1, 1, %g1
	b	.LL846
	 nop
.LL844:
	call	GOMP_barrier, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1], %g2
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	mov	%g2, %g4
	mov	%g1, %g3
	add	%fp, -52, %g2
	add	%fp, -48, %g1
	mov	%g4, %o0
	mov	%g3, %o1
	mov	1, %o2
	mov	1, %o3
	mov	%g2, %o4
	mov	%g1, %o5
	call	GOMP_loop_dynamic_start, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL847
	 nop
.LL849:
	ld	[%fp-52], %g1
	st	%g1, [%fp-44]
	ld	[%fp-48], %g1
.LL848:
	ld	[%fp+68], %g2
	mov	1, %g3
	st	%g3, [%g2+8]
	ld	[%fp-44], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-44]
	ld	[%fp-44], %g2
	cmp	%g2, %g1
	bl	.LL848
	 nop
	add	%fp, -52, %g2
	add	%fp, -48, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL849
	 nop
.LL847:
	call	GOMP_loop_end, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1], %g2
	ld	[%fp+68], %g1
	ld	[%g1+4], %g1
	mov	%g2, %g4
	mov	%g1, %g3
	add	%fp, -40, %g2
	add	%fp, -36, %g1
	mov	%g4, %o0
	mov	%g3, %o1
	mov	1, %o2
	mov	1, %o3
	mov	%g2, %o4
	mov	%g1, %o5
	call	GOMP_loop_guided_start, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL850
	 nop
.LL852:
	ld	[%fp-40], %g1
	st	%g1, [%fp-32]
	ld	[%fp-36], %g1
.LL851:
	ld	[%fp+68], %g2
	mov	1, %g3
	st	%g3, [%g2+8]
	ld	[%fp-32], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-32]
	ld	[%fp-32], %g2
	cmp	%g2, %g1
	bl	.LL851
	 nop
	add	%fp, -40, %g2
	add	%fp, -36, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL852
	 nop
.LL850:
	call	GOMP_loop_end, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+4], %g2
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g2, %l0
	mov	%g1, %l2
	call	omp_get_num_threads, 0
	 nop
	mov	%o0, %l1
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %o5
	sub	%l0, %l2, %g2
	mov	0, %g1
.LL856:
	smul	%g1, %l1, %g3
	add	%g3, %o5, %g3
	add	%g3, %g3, %g3
	mov	%g3, %g4
	add	%g4, 2, %g3
	cmp	%g3, %g2
	ble	.LL853
	 nop
	mov	%g2, %g3
.LL853:
	cmp	%g4, %g2
	bge	.LL854
	 nop
	sub	%l0, %g4, %g4
	st	%g4, [%fp-28]
	sub	%l0, %g3, %g3
.LL855:
	ld	[%fp+68], %g4
	mov	1, %o4
	st	%o4, [%g4+8]
	ld	[%fp-28], %g4
	add	%g4, -1, %g4
	st	%g4, [%fp-28]
	ld	[%fp-28], %g4
	cmp	%g4, %g3
	bg	.LL855
	 nop
	add	%g1, 1, %g1
	b	.LL856
	 nop
.LL854:
	call	GOMP_barrier, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1+4], %g2
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g2, %g4
	mov	%g1, %g3
	add	%fp, -24, %g2
	add	%fp, -20, %g1
	mov	%g4, %o0
	mov	%g3, %o1
	mov	-1, %o2
	mov	1, %o3
	mov	%g2, %o4
	mov	%g1, %o5
	call	GOMP_loop_dynamic_start, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL857
	 nop
.LL859:
	ld	[%fp-24], %g1
	st	%g1, [%fp-16]
	ld	[%fp-20], %g1
.LL858:
	ld	[%fp+68], %g2
	mov	1, %g3
	st	%g3, [%g2+8]
	ld	[%fp-16], %g2
	add	%g2, -1, %g2
	st	%g2, [%fp-16]
	ld	[%fp-16], %g2
	cmp	%g2, %g1
	bg	.LL858
	 nop
	add	%fp, -24, %g2
	add	%fp, -20, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL859
	 nop
.LL857:
	call	GOMP_loop_end, 0
	 nop
	ld	[%fp+68], %g1
	ld	[%g1], %g2
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	mov	%g2, %g4
	mov	%g1, %g3
	add	%fp, -12, %g2
	add	%fp, -8, %g1
	mov	%g4, %o0
	mov	%g3, %o1
	mov	1, %o2
	mov	1, %o3
	mov	%g2, %o4
	mov	%g1, %o5
	call	GOMP_loop_dynamic_start, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL860
	 nop
.LL862:
	ld	[%fp-12], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %g1
.LL861:
	ld	[%fp+68], %g2
	mov	1, %g3
	st	%g3, [%g2+8]
	ld	[%fp-4], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-4]
	ld	[%fp-4], %g2
	cmp	%g2, %g1
	bl	.LL861
	 nop
	add	%fp, -12, %g2
	add	%fp, -8, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL862
	 nop
.LL860:
	call	GOMP_loop_end, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.69, .-omp_program_main.omp_fn.69
	.align 4
	.type	omp_program_main.omp_fn.70, #function
	.proc	020
omp_program_main.omp_fn.70:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -12, %g2
	add	%fp, -8, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL865
	 nop
.LL868:
	ld	[%fp-12], %g1
	st	%g1, [%fp-4]
	ld	[%fp-8], %l0
.LL867:
	ld	[%fp-4], %g1
	cmp	%g1, 0
	be	.LL866
	 nop
.LL869:
	ld	[%fp-4], %l1
	call	omp_get_thread_num, 0
	 nop
	mov	%o0, %g3
	sethi	%hi(owner.2680), %g1
	or	%g1, %lo(owner.2680), %g2
	sll	%l1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, %l0
	bl	.LL867
	 nop
	add	%fp, -12, %g2
	add	%fp, -8, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL868
	 nop
	b	.LL865
	 nop
.LL866:
	st	%g0, [%fp-16]
.LL870:
	ld	[%fp-16], %g1
	cmp	%g1, 499
	bg	.LL869
	 nop
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
	b	.LL870
	 nop
.LL865:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.70, .-omp_program_main.omp_fn.70
	.local	owner.2680
	.common	owner.2680,160,4
	.align 4
	.type	omp_program_main.omp_fn.71, #function
	.proc	020
omp_program_main.omp_fn.71:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	0, %o0
	mov	30, %o1
	mov	1, %o2
	mov	0, %o3
	mov	%g2, %o4
	mov	%g1, %o5
	call	GOMP_loop_static_start, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL873
	 nop
.LL875:
	ld	[%fp-16], %g1
	ld	[%fp-12], %o5
	mov	%g1, %g2
	sra	%g2, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g2, 5, %g4
	mov	%g4, %g3
	sll	%g3, 2, %g3
	add	%g3, %g4, %g3
	sub	%g2, %g3, %g3
	st	%g3, [%fp-8]
	sra	%g2, 31, %g4
	wr	%g4, 0, %y
	nop
	nop
	nop
	sdiv	%g2, 5, %g3
	sra	%g3, 31, %g2
	wr	%g2, 0, %y
	nop
	nop
	nop
	sdiv	%g3, 6, %g4
	mov	%g4, %g2
	add	%g2, %g2, %g2
	add	%g2, %g4, %g2
	add	%g2, %g2, %g2
	sub	%g3, %g2, %g2
	st	%g2, [%fp-4]
.LL876:
	ld	[%fp-4], %g3
	ld	[%fp-8], %o4
	sethi	%hi(cell.2689), %g2
	or	%g2, %lo(cell.2689), %g4
	mov	%g3, %g2
	sll	%g2, 2, %g2
	add	%g2, %g3, %g2
	add	%g2, %o4, %g2
	sll	%g2, 2, %g2
	mov	1, %g3
	st	%g3, [%g4+%g2]
	add	%g1, 1, %g1
	cmp	%g1, %o5
	bl	.LL874
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_static_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL875
	 nop
	b	.LL873
	 nop
.LL874:
	ld	[%fp-8], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-8]
	ld	[%fp-8], %g2
	cmp	%g2, 4
	ble	.LL876
	 nop
	st	%g0, [%fp-8]
	ld	[%fp-4], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-4]
	b	.LL876
	 nop
.LL873:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.71, .-omp_program_main.omp_fn.71
	.local	cell.2689
	.common	cell.2689,120,4
	.align 4
	.type	omp_program_main.omp_fn.72, #function
	.proc	020
omp_program_main.omp_fn.72:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL879
	 nop
.LL881:
	ld	[%fp-16], %g1
	ld	[%fp-12], %o5
	mov	%g1, %g2
	sra	%g2, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g2, 5, %g4
	mov	%g4, %g3
	sll	%g3, 2, %g3
	add	%g3, %g4, %g3
	sub	%g2, %g3, %g3
	st	%g3, [%fp-8]
	sra	%g2, 31, %g4
	wr	%g4, 0, %y
	nop
	nop
	nop
	sdiv	%g2, 5, %g3
	sra	%g3, 31, %g2
	wr	%g2, 0, %y
	nop
	nop
	nop
	sdiv	%g3, 6, %g4
	mov	%g4, %g2
	add	%g2, %g2, %g2
	add	%g2, %g4, %g2
	add	%g2, %g2, %g2
	sub	%g3, %g2, %g2
	st	%g2, [%fp-4]
.LL882:
	ld	[%fp-4], %g3
	ld	[%fp-8], %o3
	ld	[%fp-4], %g4
	ld	[%fp-8], %o2
	sethi	%hi(cell.2689), %g2
	or	%g2, %lo(cell.2689), %o4
	mov	%g4, %g2
	sll	%g2, 2, %g2
	add	%g2, %g4, %g2
	add	%g2, %o2, %g2
	sll	%g2, 2, %g2
	ld	[%o4+%g2], %g2
	add	%g2, 1, %o4
	sethi	%hi(cell.2689), %g2
	or	%g2, %lo(cell.2689), %g4
	mov	%g3, %g2
	sll	%g2, 2, %g2
	add	%g2, %g3, %g2
	add	%g2, %o3, %g2
	sll	%g2, 2, %g2
	st	%o4, [%g4+%g2]
	add	%g1, 1, %g1
	cmp	%g1, %o5
	bl	.LL880
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_dynamic_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL881
	 nop
	b	.LL879
	 nop
.LL880:
	ld	[%fp-8], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-8]
	ld	[%fp-8], %g2
	cmp	%g2, 4
	ble	.LL882
	 nop
	st	%g0, [%fp-8]
	ld	[%fp-4], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-4]
	b	.LL882
	 nop
.LL879:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.72, .-omp_program_main.omp_fn.72
	.align 4
	.type	omp_program_main.omp_fn.73, #function
	.proc	020
omp_program_main.omp_fn.73:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL885
	 nop
.LL887:
	ld	[%fp-16], %g1
	ld	[%fp-12], %o5
	mov	%g1, %g2
	sra	%g2, 31, %g3
	wr	%g3, 0, %y
	nop
	nop
	nop
	sdiv	%g2, 5, %g4
	mov	%g4, %g3
	sll	%g3, 2, %g3
	add	%g3, %g4, %g3
	sub	%g2, %g3, %g3
	st	%g3, [%fp-8]
	sra	%g2, 31, %g4
	wr	%g4, 0, %y
	nop
	nop
	nop
	sdiv	%g2, 5, %g3
	sra	%g3, 31, %g2
	wr	%g2, 0, %y
	nop
	nop
	nop
	sdiv	%g3, 6, %g4
	mov	%g4, %g2
	add	%g2, %g2, %g2
	add	%g2, %g4, %g2
	add	%g2, %g2, %g2
	sub	%g3, %g2, %g2
	st	%g2, [%fp-4]
.LL888:
	ld	[%fp-4], %g3
	ld	[%fp-8], %o3
	ld	[%fp-4], %g4
	ld	[%fp-8], %o2
	sethi	%hi(cell.2689), %g2
	or	%g2, %lo(cell.2689), %o4
	mov	%g4, %g2
	sll	%g2, 2, %g2
	add	%g2, %g4, %g2
	add	%g2, %o2, %g2
	sll	%g2, 2, %g2
	ld	[%o4+%g2], %g2
	add	%g2, 1, %o4
	sethi	%hi(cell.2689), %g2
	or	%g2, %lo(cell.2689), %g4
	mov	%g3, %g2
	sll	%g2, 2, %g2
	add	%g2, %g3, %g2
	add	%g2, %o3, %g2
	sll	%g2, 2, %g2
	st	%o4, [%g4+%g2]
	add	%g1, 1, %g1
	cmp	%g1, %o5
	bl	.LL886
	 nop
	add	%fp, -16, %g2
	add	%fp, -12, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	GOMP_loop_guided_next, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL887
	 nop
	b	.LL885
	 nop
.LL886:
	ld	[%fp-8], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-8]
	ld	[%fp-8], %g2
	cmp	%g2, 4
	ble	.LL888
	 nop
	st	%g0, [%fp-8]
	ld	[%fp-4], %g2
	add	%g2, 1, %g2
	st	%g2, [%fp-4]
	b	.LL888
	 nop
.LL885:
	call	GOMP_loop_end_nowait, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	omp_program_main.omp_fn.73, .-omp_program_main.omp_fn.73
	.ident	"GCC: (GNU) 4.4.3"
