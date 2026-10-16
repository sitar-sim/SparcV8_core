	.file	"matmul.c"
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
! 29 "validation/sparc_apara/linalg/matmul/../../../C/devices/devices_common.h" 1
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
	.type	apara_load_program, #function
	.proc	020
apara_load_program:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%g0, [%fp-4]
	b	.LL28
	 nop
.LL29:
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
.LL28:
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	blu	.LL29
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
.LL38:
	ld	[%fp+68], %o0
	call	apara_poll_thread, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bge	.LL38
	 nop
	ld	[%fp-4], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	apara_wait_thread, .-apara_wait_thread
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
	be	.LL41
	 nop
	mov	8, %g1
	b	.LL42
	 nop
.LL41:
	mov	0, %g1
.LL42:
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
.LL47:
	ld	[%fp+68], %o0
	call	apara_dma_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL47
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
	.section	".rodata"
	.align 4
	.type	matmul_program, #object
	.size	matmul_program, 164
matmul_program:
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1309260864
	.long	1309523040
	.long	1744830464
	.long	1744830464
	.long	-1869306872
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1283564544
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-950532087
	.long	1197017098
	.long	1197082635
	.long	1197148172
	.long	1197213709
	.long	1197279246
	.long	1197344783
	.long	1197410320
	.long	-1869239232
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1377348608
	.long	1377610784
	.long	1744830464
	.long	1744830464
	.long	-1994916586
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-335544320
	.local	A
	.common	A,64,1
	.local	BT
	.common	BT,64,1
	.local	C
	.common	C,512,4
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -128, %sp
	st	%g0, [%fp-28]
	mov	13, %g1
	st	%g1, [%fp-32]
	mov	1, %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-24]
	b	.LL58
	 nop
.LL61:
	st	%g0, [%fp-20]
	b	.LL59
	 nop
.LL60:
	ld	[%fp-24], %l1
	ld	[%fp-20], %l0
	add	%fp, -32, %g1
	mov	%g1, %o0
	call	next_random, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g3
	sethi	%hi(A), %g1
	or	%g1, %lo(A), %g1
	sll	%l1, 3, %g2
	add	%g2, %l0, %g2
	stb	%g3, [%g2+%g1]
	ld	[%fp-20], %l1
	ld	[%fp-24], %l0
	add	%fp, -32, %g1
	mov	%g1, %o0
	call	next_random, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g3
	sethi	%hi(BT), %g1
	or	%g1, %lo(BT), %g1
	sll	%l1, 3, %g2
	add	%g2, %l0, %g2
	stb	%g3, [%g2+%g1]
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL59:
	ld	[%fp-20], %g1
	cmp	%g1, 7
	bleu	.LL60
	 nop
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL58:
	ld	[%fp-24], %g1
	cmp	%g1, 7
	bleu	.LL61
	 nop
	sethi	%hi(matmul_program), %g1
	or	%g1, %lo(matmul_program), %o0
	mov	41, %o1
	call	apara_load_program, 0
	 nop
	sethi	%hi(A), %g1
	or	%g1, %lo(A), %g1
	mov	0, %o0
	mov	0, %o1
	mov	%g1, %o2
	mov	64, %o3
	call	apara_dma_load, 0
	 nop
	sethi	%hi(BT), %g1
	or	%g1, %lo(BT), %g1
	mov	1, %o0
	mov	64, %o1
	mov	%g1, %o2
	mov	64, %o3
	call	apara_dma_load, 0
	 nop
	st	%g0, [%fp-12]
	b	.LL62
	 nop
.LL63:
	ld	[%fp-12], %g2
	sethi	%hi(1048576), %g1
	add	%g2, %g1, %g1
	sll	%g1, 4, %g1
	mov	0, %g2
	mov	%g1, %g3
	ld	[%fp-12], %o0
	mov	20, %o1
	mov	%g2, %o2
	mov	%g3, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-12], %g2
	sethi	%hi(131072), %g1
	or	%g1, 2, %g1
	add	%g2, %g1, %g1
	sll	%g1, 7, %g1
	mov	0, %g2
	mov	%g1, %g3
	ld	[%fp-12], %o0
	mov	21, %o1
	mov	%g2, %o2
	mov	%g3, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-12], %o0
	mov	22, %o1
	mov	0, %o2
	mov	1, %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-12], %o0
	mov	23, %o1
	mov	0, %o2
	sethi	%hi(16777216), %o3
	call	apara_write_thread_register, 0
	 nop
	ld	[%fp-12], %o0
	mov	0, %o1
	call	apara_start_thread, 0
	 nop
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL62:
	ld	[%fp-12], %g1
	cmp	%g1, 3
	bleu	.LL63
	 nop
	st	%g0, [%fp-12]
	b	.LL64
	 nop
.LL66:
	ld	[%fp-12], %o0
	call	apara_wait_thread, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL65
	 nop
	ld	[%fp-12], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	ld	[%fp-28], %g2
	or	%g2, %g1, %g1
	st	%g1, [%fp-28]
.LL65:
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL64:
	ld	[%fp-12], %g1
	cmp	%g1, 3
	bleu	.LL66
	 nop
	sethi	%hi(C), %g1
	or	%g1, %lo(C), %g1
	mov	2, %o0
	mov	%g1, %o1
	mov	256, %o2
	mov	512, %o3
	call	apara_dma_store, 0
	 nop
	st	%g0, [%fp-24]
	b	.LL67
	 nop
.LL76:
	st	%g0, [%fp-20]
	b	.LL68
	 nop
.LL75:
	st	%g0, [%fp-4]
	st	%g0, [%fp-16]
	b	.LL69
	 nop
.LL70:
	ld	[%fp-24], %g3
	ld	[%fp-16], %g2
	sethi	%hi(A), %g1
	or	%g1, %lo(A), %g1
	sll	%g3, 3, %g3
	add	%g3, %g2, %g2
	ldub	[%g2+%g1], %g1
	sll	%g1, 24, %g1
	sra	%g1, 24, %g2
	ld	[%fp-20], %g4
	ld	[%fp-16], %g3
	sethi	%hi(BT), %g1
	or	%g1, %lo(BT), %g1
	sll	%g4, 3, %g4
	add	%g4, %g3, %g3
	ldub	[%g3+%g1], %g1
	sll	%g1, 24, %g1
	sra	%g1, 24, %g1
	smul	%g2, %g1, %g1
	ld	[%fp-4], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL69:
	ld	[%fp-16], %g1
	cmp	%g1, 7
	bleu	.LL70
	 nop
	sethi	%hi(C), %g1
	or	%g1, %lo(C), %g2
	ld	[%fp-24], %g1
	sll	%g1, 3, %g3
	ld	[%fp-20], %g1
	add	%g3, %g1, %g1
	sll	%g1, 3, %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	physical_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g1, 0
	bge	.LL71
	 nop
	mov	-1, %g1
	b	.LL72
	 nop
.LL71:
	mov	0, %g1
.LL72:
	cmp	%g2, %g1
	bne	.LL73
	 nop
	ld	[%fp-24], %g1
	sll	%g1, 3, %g2
	ld	[%fp-20], %g1
	add	%g2, %g1, %g1
	add	%g1, %g1, %g1
	add	%g1, 1, %g1
	sll	%g1, 2, %g2
	sethi	%hi(C), %g1
	or	%g1, %lo(C), %g1
	add	%g2, %g1, %g1
	mov	%g1, %o0
	call	physical_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	bne	.LL73
	 nop
	mov	1, %g1
	b	.LL74
	 nop
.LL73:
	mov	0, %g1
.LL74:
	ld	[%fp-8], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-20], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL68:
	ld	[%fp-20], %g1
	cmp	%g1, 7
	bleu	.LL75
	 nop
	ld	[%fp-24], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-24]
.LL67:
	ld	[%fp-24], %g1
	cmp	%g1, 7
	bleu	.LL76
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 0
	be	.LL77
	 nop
	ld	[%fp-28], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-28]
.LL77:
	ld	[%fp-28], %o0
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
