	.file	"cold_state.c"
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
! 29 "validation/sparc_apara/setup/cold_state/../../../C/devices/devices_common.h" 1
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
	.type	apara_read_imem, #function
	.proc	016
apara_read_imem:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	mov	0, %o0
	mov	2, %o1
	ld	[%fp+68], %o2
	call	apara_ccu_write, 0
	 nop
	mov	0, %o0
	mov	1, %o1
	call	apara_ccu_command, 0
	 nop
	mov	0, %o0
	mov	4, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_read_imem, .-apara_read_imem
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
	.type	apara_read_timer, #function
	.proc	017
apara_read_timer:
	save	%sp, -96, %sp
	mov	0, %o0
	mov	10, %o1
	call	apara_ccu_command, 0
	 nop
	mov	0, %o0
	mov	3, %o1
	call	apara_ccu_read, 0
	 nop
	mov	%o0, %g1
	mov	0, %g2
	mov	%g1, %g3
	sll	%g3, 0, %l0
	mov	0, %l1
	mov	0, %o0
	mov	4, %o1
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
	.size	apara_read_timer, .-apara_read_timer
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
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -136, %sp
	st	%g0, [%fp-36]
	mov	1, %g1
	st	%g1, [%fp-20]
	st	%g0, [%fp-32]
	b	.LL32
	 nop
.LL33:
	ld	[%fp-32], %o0
	call	apara_read_imem, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-20], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-20]
	ld	[%fp-32], %g1
	add	%g1, 32, %g1
	st	%g1, [%fp-32]
.LL32:
	ld	[%fp-32], %g1
	cmp	%g1, 4095
	bleu	.LL33
	 nop
	ld	[%fp-20], %g1
	cmp	%g1, 0
	be	.LL34
	 nop
	ld	[%fp-36], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-36]
.LL34:
	mov	1, %g1
	st	%g1, [%fp-20]
	st	%g0, [%fp-32]
	b	.LL35
	 nop
.LL36:
	ld	[%fp-32], %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-20], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-20]
	ld	[%fp-32], %g1
	add	%g1, 256, %g1
	st	%g1, [%fp-32]
.LL35:
	ld	[%fp-32], %g2
	sethi	%hi(64512), %g1
	or	%g1, 1023, %g1
	cmp	%g2, %g1
	bleu	.LL36
	 nop
	ld	[%fp-20], %g1
	cmp	%g1, 0
	be	.LL37
	 nop
	ld	[%fp-36], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-36]
.LL37:
	mov	1, %g1
	st	%g1, [%fp-20]
	st	%g0, [%fp-28]
	b	.LL38
	 nop
.LL42:
	mov	1, %g1
	st	%g1, [%fp-24]
	b	.LL39
	 nop
.LL41:
	ld	[%fp-28], %o0
	ld	[%fp-24], %o1
	call	apara_read_thread_register, 0
	 nop
	mov	%o0, %g2
	mov	%o1, %g3
	mov	0, %g4
	mov	%g2, %g1
	or	%g1, %g3, %g1
	cmp	%g1, 0
	bne	.LL40
	 nop
	mov	1, %g4
.LL40:
	ld	[%fp-20], %g1
	and	%g1, %g4, %g1
	st	%g1, [%fp-20]
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL39:
	ld	[%fp-24], %g1
	cmp	%g1, 31
	bleu	.LL41
	 nop
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL38:
	ld	[%fp-28], %g1
	cmp	%g1, 3
	bleu	.LL42
	 nop
	ld	[%fp-20], %g1
	cmp	%g1, 0
	be	.LL43
	 nop
	ld	[%fp-36], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-36]
.LL43:
	mov	1, %g1
	st	%g1, [%fp-20]
	st	%g0, [%fp-28]
	b	.LL44
	 nop
.LL45:
	ld	[%fp-28], %o0
	call	apara_poll_thread, 0
	 nop
	mov	%o0, %g1
	xor	%g1, 0, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-20], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-20]
	ld	[%fp-28], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-28]
.LL44:
	ld	[%fp-28], %g1
	cmp	%g1, 3
	bleu	.LL45
	 nop
	ld	[%fp-20], %g1
	cmp	%g1, 0
	be	.LL46
	 nop
	ld	[%fp-36], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-36]
.LL46:
	call	apara_read_timer, 0
	 nop
	mov	%o0, %g2
	mov	%o1, %g3
	std	%g2, [%fp-16]
	call	apara_read_timer, 0
	 nop
	mov	%o0, %g2
	mov	%o1, %g3
	std	%g2, [%fp-8]
	ld	[%fp-8], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bgu	.LL50
	 nop
	ld	[%fp-8], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bne	.LL47
	 nop
	ld	[%fp-4], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	bgu	.LL50
	 nop
	ld	[%fp-4], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	b	.LL47
	 nop
.LL50:
	ld	[%fp-36], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-36]
.LL47:
	ld	[%fp-36], %o0
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
