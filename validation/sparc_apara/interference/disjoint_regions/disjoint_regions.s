	.file	"disjoint_regions.c"
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
! 29 "validation/sparc_apara/interference/disjoint_regions/../../../C/devices/devices_common.h" 1
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
.LL34:
	ld	[%fp+68], %o0
	call	apara_poll_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bge	.LL34
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_wait_thread, .-apara_wait_thread
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
	bge	.LL41
	 nop
	mov	-1, %g1
	b	.LL42
	 nop
.LL41:
	mov	0, %g1
.LL42:
	cmp	%g2, %g1
	bne	.LL43
	 nop
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	bne	.LL43
	 nop
	mov	1, %g1
	b	.LL44
	 nop
.LL43:
	mov	0, %g1
.LL44:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	dword_equals, .-dword_equals
	.section	".rodata"
	.align 4
	.type	fill_program, #object
	.size	fill_program, 68
fill_program:
	.long	-1870590968
	.long	277027841
	.long	1744830464
	.long	1744830464
	.long	1350765568
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1994916094
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
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
	st	%g0, [%fp-20]
	sethi	%hi(fill_program), %g1
	or	%g1, %lo(fill_program), %o0
	mov	17, %o1
	call	apara_load_program, 0
	 nop
	st	%g0, [%fp-16]
	b	.LL47
	 nop
.LL48:
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g1
	add	%g1, 4088, %g1
	mov	%g1, %o0
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g1
	add	%g1, 4092, %g1
	mov	%g1, %o0
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g2
	sethi	%hi(4096), %g1
	or	%g1, 512, %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g2
	sethi	%hi(4096), %g1
	or	%g1, 516, %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g2
	sethi	%hi(16781312), %g1
	add	%g2, %g1, %g1
	mov	0, %g2
	mov	%g1, %g3
	ld	[%fp-16], %o0
	mov	1, %o1
	mov	%g2, %o2
	mov	%g3, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-16], %o0
	mov	2, %o1
	mov	0, %o2
	mov	63, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	smul	%g1, 1000, %g1
	mov	0, %g2
	mov	%g1, %g3
	ld	[%fp-16], %o0
	mov	3, %o1
	mov	%g2, %o2
	mov	%g3, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL47:
	ld	[%fp-16], %g1
	cmp	%g1, 3
	bleu	.LL48
	 nop
	st	%g0, [%fp-16]
	b	.LL49
	 nop
.LL50:
	ld	[%fp-16], %o0
	mov	0, %o1
	call	apara_start_thread, 0
	 nop
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL49:
	ld	[%fp-16], %g1
	cmp	%g1, 3
	bleu	.LL50
	 nop
	st	%g0, [%fp-16]
	b	.LL51
	 nop
.LL55:
	ld	[%fp-16], %o0
	call	apara_wait_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	mov	1, %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-12]
	b	.LL52
	 nop
.LL53:
	ld	[%fp-16], %g1
	mov	%g1, %g2
	sll	%g2, 6, %g2
	add	%g2, %g1, %g2
	ld	[%fp-12], %g1
	add	%g2, %g1, %g1
	add	%g1, 512, %g1
	sll	%g1, 3, %g2
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	smul	%g1, 1000, %g3
	ld	[%fp-12], %g1
	add	%g3, %g1, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	ld	[%fp-8], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL52:
	ld	[%fp-12], %g1
	cmp	%g1, 63
	bleu	.LL53
	 nop
	ld	[%fp-4], %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL54
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 0
	be	.LL54
	 nop
	ld	[%fp-16], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	ld	[%fp-20], %g2
	or	%g2, %g1, %g1
	st	%g1, [%fp-20]
.LL54:
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL51:
	ld	[%fp-16], %g1
	cmp	%g1, 3
	bleu	.LL55
	 nop
	mov	1, %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-16]
	b	.LL56
	 nop
.LL59:
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g1
	add	%g1, 4088, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %g1
	cmp	%g2, %g1
	bne	.LL57
	 nop
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g1
	add	%g1, 4092, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %g1
	cmp	%g2, %g1
	bne	.LL57
	 nop
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g2
	sethi	%hi(4096), %g1
	or	%g1, 512, %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %g1
	cmp	%g2, %g1
	bne	.LL57
	 nop
	ld	[%fp-16], %g1
	sll	%g1, 3, %g1
	sll	%g1, 6, %g2
	add	%g1, %g2, %g2
	sethi	%hi(4096), %g1
	or	%g1, 516, %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(1785358336), %g1
	or	%g1, 618, %g1
	cmp	%g2, %g1
	bne	.LL57
	 nop
	mov	1, %g1
	b	.LL58
	 nop
.LL57:
	mov	0, %g1
.LL58:
	ld	[%fp-8], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL56:
	ld	[%fp-16], %g1
	cmp	%g1, 3
	bleu	.LL59
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 0
	be	.LL60
	 nop
	ld	[%fp-20], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-20]
.LL60:
	ld	[%fp-20], %o0
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
