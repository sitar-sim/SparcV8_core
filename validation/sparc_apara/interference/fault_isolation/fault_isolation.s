	.file	"fault_isolation.c"
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
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL6
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL7
	 nop
.LL6:
	mov	-1, %g1
.LL7:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 29 "validation/sparc_apara/interference/fault_isolation/../../../C/devices/devices_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL8:
	b	.LL8
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
.LL19:
	ld	[%fp+68], %o0
	call	apara_ccu_command_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL19
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
	b	.LL24
	 nop
.LL25:
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
.LL24:
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	blu	.LL25
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
	.type	apara_reset_thread, #function
	.proc	020
apara_reset_thread:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	3, %o1
	call	apara_ccu_command, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_reset_thread, .-apara_reset_thread
	.align 4
	.type	apara_poll_thread, #function
	.proc	016
apara_poll_thread:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	7, %o1
	call	apara_ccu_command, 0
	 nop
	ld	[%fp+68], %o0
	mov	5, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_poll_thread, .-apara_poll_thread
	.align 4
	.type	apara_wait_thread, #function
	.proc	016
apara_wait_thread:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
.LL36:
	ld	[%fp+68], %o0
	call	apara_poll_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bge	.LL36
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_wait_thread, .-apara_wait_thread
	.align 4
	.type	apara_thread_stop_pc, #function
	.proc	016
apara_thread_stop_pc:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	6, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_thread_stop_pc, .-apara_thread_stop_pc
	.align 4
	.type	apara_dmem_write_word, #function
	.proc	020
apara_dmem_write_word:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g2
	sethi	%hi(16777216), %g1
	add	%g2, %g1, %g1
	ld	[%fp+72], %o0
	mov	%g1, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_dmem_write_word, .-apara_dmem_write_word
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
	.type	dword_equals, #function
	.proc	04
dword_equals:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+72], %g1
	cmp	%g1, 0
	bge	.LL45
	 nop
	mov	-1, %g1
	b	.LL46
	 nop
.LL45:
	mov	0, %g1
.LL46:
	cmp	%g2, %g1
	bne	.LL47
	 nop
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	bne	.LL47
	 nop
	mov	1, %g1
	b	.LL48
	 nop
.LL47:
	mov	0, %g1
.LL48:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	dword_equals, .-dword_equals
	.section	".rodata"
	.align 4
	.type	divide_program, #object
	.size	divide_program, 68
divide_program:
	.long	-402653184
	.long	478414850
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1350835200
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-335544320
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	st	%g0, [%fp-8]
	sethi	%hi(divide_program), %g1
	or	%g1, %lo(divide_program), %o0
	mov	17, %o1
	call	apara_load_program, 0
	 nop
	st	%g0, [%fp-4]
	b	.LL51
	 nop
.LL54:
	ld	[%fp-4], %g1
	add	%g1, 192, %g1
	sll	%g1, 3, %g1
	mov	%g1, %o0
	sethi	%hi(-286331904), %g1
	or	%g1, 750, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-4], %g1
	sll	%g1, 3, %g1
	add	%g1, 1540, %g1
	mov	%g1, %o0
	sethi	%hi(-286331904), %g1
	or	%g1, 750, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1000, %g1
	mov	0, %g2
	mov	%g1, %g3
	ld	[%fp-4], %o0
	mov	1, %o1
	mov	%g2, %o2
	mov	%g3, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-4], %g1
	cmp	%g1, 2
	be	.LL52
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	mov	0, %g2
	mov	%g1, %g3
	b	.LL53
	 nop
.LL52:
	mov	0, %g2
	mov	0, %g3
.LL53:
	ld	[%fp-4], %o0
	mov	2, %o1
	mov	%g2, %o2
	mov	%g3, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-4], %g2
	sethi	%hi(2097152), %g1
	or	%g1, 192, %g1
	add	%g2, %g1, %g1
	sll	%g1, 3, %g1
	mov	0, %g2
	mov	%g1, %g3
	ld	[%fp-4], %o0
	mov	3, %o1
	mov	%g2, %o2
	mov	%g3, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL51:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	bleu	.LL54
	 nop
	st	%g0, [%fp-4]
	b	.LL55
	 nop
.LL56:
	ld	[%fp-4], %o0
	mov	0, %o1
	call	apara_start_thread, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL55:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	bleu	.LL56
	 nop
	st	%g0, [%fp-4]
	b	.LL57
	 nop
.LL58:
	ld	[%fp-4], %l0
	ld	[%fp-4], %o0
	call	apara_wait_thread, 0
	 nop
	mov	%o0, %g2
	sll	%l0, 2, %g1
	add	%fp, %g1, %g1
	st	%g2, [%g1-24]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL57:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	bleu	.LL58
	 nop
	ld	[%fp-24], %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL59
	 nop
	ld	[%fp-20], %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL59
	 nop
	ld	[%fp-12], %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL59
	 nop
	mov	1536, %o0
	mov	1000, %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL59
	 nop
	mov	1544, %o0
	mov	500, %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL59
	 nop
	mov	1560, %o0
	mov	250, %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL59
	 nop
	ld	[%fp-8], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL59:
	ld	[%fp-16], %g1
	cmp	%g1, 0
	bge	.LL60
	 nop
	ld	[%fp-16], %g2
	sethi	%hi(16777216), %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	be	.LL60
	 nop
	ld	[%fp-16], %g2
	sethi	%hi(33554432), %g1
	and	%g2, %g1, %g1
	cmp	%g1, 0
	bne	.LL60
	 nop
	ld	[%fp-16], %g1
	srl	%g1, 3, %g1
	and	%g1, 7, %g1
	cmp	%g1, 1
	bne	.LL60
	 nop
	ld	[%fp-8], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-8]
.LL60:
	mov	2, %o0
	call	apara_thread_stop_pc, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL61
	 nop
	mov	1552, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(-286331904), %g1
	or	%g1, 750, %g1
	cmp	%g2, %g1
	bne	.LL61
	 nop
	ld	[%fp-8], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-8]
.LL61:
	mov	2, %o0
	call	apara_reset_thread, 0
	 nop
	mov	2, %o0
	mov	2, %o1
	mov	0, %o2
	mov	7, %o3
	call	apara_write_thread_register, 0
	 nop
	mov	2, %o0
	mov	0, %o1
	call	apara_start_thread, 0
	 nop
	mov	2, %o0
	call	apara_wait_thread, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL62
	 nop
	ld	[%fp-8], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-8]
.LL62:
	mov	1552, %o0
	mov	143, %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL63
	 nop
	ld	[%fp-8], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-8]
.LL63:
	ld	[%fp-8], %o0
	mov	5, %o1
	call	report_and_halt, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
