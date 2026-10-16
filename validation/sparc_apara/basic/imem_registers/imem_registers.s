	.file	"imem_registers.c"
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
! 29 "validation/sparc_apara/basic/imem_registers/../../../C/devices/devices_common.h" 1
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
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	st	%g0, [%fp-20]
	mov	0, %o0
	sethi	%hi(-2147483648), %o1
	call	apara_write_imem, 0
	 nop
	mov	4095, %o0
	sethi	%hi(-559039488), %g1
	or	%g1, 751, %o1
	call	apara_write_imem, 0
	 nop
	mov	0, %o0
	call	apara_read_imem, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(-2147483648), %g1
	cmp	%g2, %g1
	bne	.LL32
	 nop
	mov	4095, %o0
	call	apara_read_imem, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(-559039488), %g1
	or	%g1, 751, %g1
	cmp	%g2, %g1
	bne	.LL32
	 nop
	ld	[%fp-20], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL32:
	mov	1, %o0
	mov	5, %o1
	sethi	%hi(19088384), %o2
	or	%o2, 359, %o2
	sethi	%hi(2309737472), %o3
	or	%o3, 495, %o3
	call	apara_write_thread_register, 0
	 nop
	mov	3, %o0
	mov	5, %o1
	sethi	%hi(286330880), %o2
	or	%o2, 273, %o2
	sethi	%hi(572661760), %o3
	or	%o3, 546, %o3
	call	apara_write_thread_register, 0
	 nop
	mov	1, %o0
	mov	5, %o1
	call	apara_read_thread_register, 0
	 nop
	mov	%o0, %g2
	mov	%o1, %g3
	sethi	%hi(19088384), %g1
	or	%g1, 359, %g1
	cmp	%g2, %g1
	bne	.LL33
	 nop
	sethi	%hi(-1985229824), %g1
	or	%g1, 495, %g1
	cmp	%g3, %g1
	bne	.LL33
	 nop
	ld	[%fp-20], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-20]
.LL33:
	mov	3, %o0
	mov	5, %o1
	call	apara_read_thread_register, 0
	 nop
	mov	%o0, %g2
	mov	%o1, %g3
	sethi	%hi(286330880), %g1
	or	%g1, 273, %g1
	cmp	%g2, %g1
	bne	.LL34
	 nop
	sethi	%hi(572661760), %g1
	or	%g1, 546, %g1
	cmp	%g3, %g1
	bne	.LL34
	 nop
	ld	[%fp-20], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-20]
.LL34:
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
	bgu	.LL38
	 nop
	ld	[%fp-8], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bne	.LL35
	 nop
	ld	[%fp-4], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	bgu	.LL38
	 nop
	ld	[%fp-4], %g2
	ld	[%fp-12], %g1
	cmp	%g2, %g1
	b	.LL35
	 nop
.LL38:
	ld	[%fp-20], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-20]
.LL35:
	ld	[%fp-20], %o0
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
