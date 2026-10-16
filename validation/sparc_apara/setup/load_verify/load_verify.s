	.file	"load_verify.c"
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
! 29 "validation/sparc_apara/setup/load_verify/../../../C/devices/devices_common.h" 1
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
	.type	apara_dma_read, #function
	.proc	016
apara_dma_read:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+68], %g2
	sethi	%hi(134213632), %g1
	or	%g1, 256, %g1
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
	.size	apara_dma_read, .-apara_dma_read
	.align 4
	.type	apara_dma_write, #function
	.proc	020
apara_dma_write:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+68], %g2
	sethi	%hi(134213632), %g1
	or	%g1, 256, %g1
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
	.size	apara_dma_write, .-apara_dma_write
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
.LL23:
	ld	[%fp+68], %o0
	call	apara_ccu_command_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL23
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
	.type	apara_load_program, #function
	.proc	020
apara_load_program:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%g0, [%fp-4]
	b	.LL30
	 nop
.LL31:
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
.LL30:
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	blu	.LL31
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_load_program, .-apara_load_program
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
	.type	apara_dma_start, #function
	.proc	020
apara_dma_start:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	st	%i4, [%fp+84]
	st	%i5, [%fp+88]
	ld	[%fp+68], %o0
	mov	1, %o1
	ld	[%fp+76], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	2, %o1
	ld	[%fp+80], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+84], %g2
	ld	[%fp+92], %g1
	smul	%g2, %g1, %g1
	ld	[%fp+68], %o0
	mov	3, %o1
	mov	%g1, %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	4, %o1
	ld	[%fp+84], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	5, %o1
	ld	[%fp+88], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+68], %o0
	mov	6, %o1
	ld	[%fp+92], %o2
	call	apara_dma_write, 0
	 nop
	ld	[%fp+72], %g1
	sll	%g1, 24, %g2
	ld	[%fp+96], %g1
	cmp	%g1, 0
	be	.LL38
	 nop
	mov	8, %g1
	b	.LL39
	 nop
.LL38:
	mov	0, %g1
.LL39:
	or	%g2, %g1, %g1
	or	%g1, 1, %g1
	ld	[%fp+68], %o0
	mov	0, %o1
	mov	%g1, %o2
	call	apara_dma_write, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_start, .-apara_dma_start
	.align 4
	.type	apara_dma_done, #function
	.proc	04
apara_dma_done:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	mov	0, %o1
	call	apara_dma_read, 0
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
	.size	apara_dma_done, .-apara_dma_done
	.align 4
	.type	apara_dma_wait, #function
	.proc	016
apara_dma_wait:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
.LL44:
	ld	[%fp+68], %o0
	call	apara_dma_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL44
	 nop
	ld	[%fp+68], %o0
	mov	0, %o1
	call	apara_dma_read, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_wait, .-apara_dma_wait
	.align 4
	.type	apara_dma_load, #function
	.proc	016
apara_dma_load:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	ld	[%fp+80], %g1
	st	%g1, [%sp+92]
	st	%g0, [%sp+96]
	ld	[%fp+68], %o0
	mov	1, %o1
	ld	[%fp+76], %o2
	ld	[%fp+72], %o3
	mov	1, %o4
	mov	0, %o5
	call	apara_dma_start, 0
	 nop
	ld	[%fp+68], %o0
	call	apara_dma_wait, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_load, .-apara_dma_load
	.align 4
	.type	apara_dma_store, #function
	.proc	016
apara_dma_store:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	ld	[%fp+80], %g1
	st	%g1, [%sp+92]
	st	%g0, [%sp+96]
	ld	[%fp+68], %o0
	mov	2, %o1
	ld	[%fp+76], %o2
	ld	[%fp+72], %o3
	mov	1, %o4
	mov	0, %o5
	call	apara_dma_start, 0
	 nop
	ld	[%fp+68], %o0
	call	apara_dma_wait, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_dma_store, .-apara_dma_store
	.align 4
	.type	physical_word, #function
	.proc	016
physical_word:
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
	.size	physical_word, .-physical_word
	.align 4
	.type	next_random, #function
	.proc	016
next_random:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %g1
	ld	[%g1], %g2
	sethi	%hi(1664000), %g1
	or	%g1, 525, %g1
	smul	%g2, %g1, %g2
	sethi	%hi(1013903360), %g1
	or	%g1, 863, %g1
	add	%g2, %g1, %g2
	ld	[%fp+68], %g1
	st	%g2, [%g1]
	ld	[%fp+68], %g1
	ld	[%g1], %g1
	srl	%g1, 8, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	next_random, .-next_random
	.local	program
	.common	program,2048,4
	.local	block_in
	.common	block_in,1024,4
	.local	block_out
	.common	block_out,1024,4
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	st	%g0, [%fp-20]
	mov	7, %g1
	st	%g1, [%fp-24]
	st	%g0, [%fp-16]
	b	.LL55
	 nop
.LL56:
	ld	[%fp-16], %l0
	add	%fp, -24, %g1
	mov	%g1, %o0
	call	next_random, 0
	 nop
	mov	%o0, %g1
	sll	%g1, 8, %l1
	add	%fp, -24, %g1
	mov	%g1, %o0
	call	next_random, 0
	 nop
	mov	%o0, %g1
	xor	%l1, %g1, %g3
	sethi	%hi(program), %g1
	or	%g1, %lo(program), %g2
	sll	%l0, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL55:
	ld	[%fp-16], %g1
	cmp	%g1, 511
	bleu	.LL56
	 nop
	sethi	%hi(program), %g1
	or	%g1, %lo(program), %o0
	mov	512, %o1
	call	apara_load_program, 0
	 nop
	mov	1, %g1
	st	%g1, [%fp-12]
	st	%g0, [%fp-16]
	b	.LL57
	 nop
.LL58:
	ld	[%fp-16], %o0
	call	apara_read_imem, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-16], %g1
	sethi	%hi(program), %g3
	or	%g3, %lo(program), %g3
	sll	%g1, 2, %g1
	ld	[%g3+%g1], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-12], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL57:
	ld	[%fp-16], %g1
	cmp	%g1, 511
	bleu	.LL58
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL59
	 nop
	ld	[%fp-20], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL59:
	st	%g0, [%fp-16]
	b	.LL60
	 nop
.LL61:
	ld	[%fp-16], %g1
	sll	%g1, 2, %g3
	ld	[%fp-16], %g2
	mov	%g2, %g1
	sll	%g1, 8, %g1
	add	%g1, %g2, %g1
	sll	%g1, 16, %g2
	add	%g1, %g2, %g2
	sethi	%hi(1509949440), %g1
	xor	%g2, %g1, %g1
	mov	%g3, %o0
	mov	%g1, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL60:
	ld	[%fp-16], %g1
	cmp	%g1, 255
	bleu	.LL61
	 nop
	mov	1, %g1
	st	%g1, [%fp-12]
	st	%g0, [%fp-16]
	b	.LL62
	 nop
.LL63:
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g3
	ld	[%fp-16], %g2
	mov	%g2, %g1
	sll	%g1, 8, %g1
	add	%g1, %g2, %g1
	sll	%g1, 16, %g2
	add	%g1, %g2, %g2
	sethi	%hi(1509949440), %g1
	xor	%g2, %g1, %g1
	xor	%g3, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-12], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL62:
	ld	[%fp-16], %g1
	cmp	%g1, 255
	bleu	.LL63
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL64
	 nop
	ld	[%fp-20], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-20]
.LL64:
	st	%g0, [%fp-16]
	b	.LL65
	 nop
.LL66:
	ld	[%fp-16], %l0
	add	%fp, -24, %g1
	mov	%g1, %o0
	call	next_random, 0
	 nop
	mov	%o0, %g1
	sll	%g1, 8, %g2
	ld	[%fp-16], %g1
	xor	%g2, %g1, %g3
	sethi	%hi(block_in), %g1
	or	%g1, %lo(block_in), %g2
	sll	%l0, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL65:
	ld	[%fp-16], %g1
	cmp	%g1, 255
	bleu	.LL66
	 nop
	sethi	%hi(block_in), %g1
	or	%g1, %lo(block_in), %g1
	mov	0, %o0
	mov	1024, %o1
	mov	%g1, %o2
	mov	1024, %o3
	call	apara_dma_load, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-8]
	mov	1, %g1
	st	%g1, [%fp-12]
	st	%g0, [%fp-16]
	b	.LL67
	 nop
.LL68:
	ld	[%fp-16], %g1
	add	%g1, 256, %g1
	sll	%g1, 2, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-16], %g1
	sethi	%hi(block_in), %g3
	or	%g3, %lo(block_in), %g3
	sll	%g1, 2, %g1
	ld	[%g3+%g1], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-12], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL67:
	ld	[%fp-16], %g1
	cmp	%g1, 255
	bleu	.LL68
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL69
	 nop
	ld	[%fp-20], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-20]
.LL69:
	sethi	%hi(block_out), %g1
	or	%g1, %lo(block_out), %g1
	mov	1, %o0
	mov	%g1, %o1
	mov	1024, %o2
	mov	1024, %o3
	call	apara_dma_store, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	mov	1, %g1
	st	%g1, [%fp-12]
	st	%g0, [%fp-16]
	b	.LL70
	 nop
.LL71:
	sethi	%hi(block_out), %g1
	or	%g1, %lo(block_out), %g2
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	physical_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-16], %g1
	sethi	%hi(block_in), %g3
	or	%g3, %lo(block_in), %g3
	sll	%g1, 2, %g1
	ld	[%g3+%g1], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-12], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL70:
	ld	[%fp-16], %g1
	cmp	%g1, 255
	bleu	.LL71
	 nop
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL72
	 nop
	ld	[%fp-20], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-20]
.LL72:
	ld	[%fp-8], %g1
	and	%g1, 16, %g1
	cmp	%g1, 0
	bne	.LL73
	 nop
	ld	[%fp-4], %g1
	and	%g1, 16, %g1
	cmp	%g1, 0
	bne	.LL73
	 nop
	ld	[%fp-20], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-20]
.LL73:
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
