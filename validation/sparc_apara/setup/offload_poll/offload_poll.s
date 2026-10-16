	.file	"offload_poll.c"
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
! 29 "validation/sparc_apara/setup/offload_poll/../../../C/devices/devices_common.h" 1
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
	.type	apara_load_dmem_image, #function
	.proc	020
apara_load_dmem_image:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%g0, [%fp-4]
	b	.LL43
	 nop
.LL44:
	ld	[%fp-4], %g1
	sll	%g1, 3, %g1
	ld	[%fp+68], %g2
	add	%g2, %g1, %g1
	ld	[%g1], %g2
	ld	[%fp-4], %g1
	add	%g1, %g1, %g1
	add	%g1, 1, %g1
	sll	%g1, 2, %g1
	ld	[%fp+68], %g3
	add	%g3, %g1, %g1
	ld	[%g1], %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	apara_dmem_write_word, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL43:
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	blu	.LL44
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	apara_load_dmem_image, .-apara_load_dmem_image
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
	be	.LL47
	 nop
	mov	8, %g1
	b	.LL48
	 nop
.LL47:
	mov	0, %g1
.LL48:
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
.LL53:
	ld	[%fp+68], %o0
	call	apara_dma_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL53
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
	bge	.LL58
	 nop
	mov	-1, %g1
	b	.LL59
	 nop
.LL58:
	mov	0, %g1
.LL59:
	cmp	%g2, %g1
	bne	.LL60
	 nop
	ld	[%fp+68], %g1
	add	%g1, 4, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	bne	.LL60
	 nop
	mov	1, %g1
	b	.LL61
	 nop
.LL60:
	mov	0, %g1
.LL61:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	dword_equals, .-dword_equals
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
	.type	vector_stats_program, #object
	.size	vector_stats_program, 640
vector_stats_program:
	.long	-1870593024
	.long	1413873920
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1281831936
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1870514176
	.long	1413873920
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1281831936
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1870448640
	.long	277087232
	.long	-1803148224
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1994389242
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1199168510
	.long	1413939456
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1281898502
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1870315520
	.long	-402653184
	.long	-1870591995
	.long	344336386
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1994391258
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1870518272
	.long	-1803147261
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1993866970
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1870452736
	.long	-402653184
	.long	-1870388223
	.long	-1803148224
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1994786554
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-737804032
	.long	1413939456
	.long	-1601818617
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-737804024
	.long	1413939456
	.long	1744830464
	.long	1744830464
	.long	1350644736
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1601818617
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-737804016
	.long	1413939456
	.long	1744830464
	.long	1744830464
	.long	1350710272
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1601818617
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-335544320
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1350775808
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.align 4
	.type	vector_stats_dmem_image, #object
	.size	vector_stats_dmem_image, 8
vector_stats_dmem_image:
	.skip	8
	.local	data
	.common	data,256,4
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	st	%g0, [%fp-20]
	mov	3, %g1
	st	%g1, [%fp-24]
	st	%g0, [%fp-12]
	st	%g0, [%fp-16]
	b	.LL66
	 nop
.LL67:
	ld	[%fp-16], %l0
	add	%fp, -24, %g1
	mov	%g1, %o0
	call	next_random, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	sethi	%hi(64512), %g1
	or	%g1, 1023, %g1
	and	%g2, %g1, %g2
	sethi	%hi(-32768), %g1
	add	%g2, %g1, %g3
	sethi	%hi(data), %g1
	or	%g1, %lo(data), %g2
	sll	%l0, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL66:
	ld	[%fp-16], %g1
	cmp	%g1, 63
	bleu	.LL67
	 nop
	sethi	%hi(data), %g1
	or	%g1, %lo(data), %g1
	ld	[%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-16]
	b	.LL68
	 nop
.LL71:
	ld	[%fp-16], %g1
	sethi	%hi(data), %g2
	or	%g2, %lo(data), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	ld	[%fp-12], %g2
	add	%g2, %g1, %g1
	st	%g1, [%fp-12]
	ld	[%fp-16], %g1
	sethi	%hi(data), %g2
	or	%g2, %lo(data), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-8], %g1
	cmp	%g2, %g1
	bge	.LL69
	 nop
	ld	[%fp-16], %g1
	sethi	%hi(data), %g2
	or	%g2, %lo(data), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-8]
.LL69:
	ld	[%fp-16], %g1
	sethi	%hi(data), %g2
	or	%g2, %lo(data), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g2
	ld	[%fp-4], %g1
	cmp	%g2, %g1
	ble	.LL70
	 nop
	ld	[%fp-16], %g1
	sethi	%hi(data), %g2
	or	%g2, %lo(data), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %g1
	st	%g1, [%fp-4]
.LL70:
	ld	[%fp-16], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL68:
	ld	[%fp-16], %g1
	cmp	%g1, 63
	bleu	.LL71
	 nop
	sethi	%hi(vector_stats_program), %g1
	or	%g1, %lo(vector_stats_program), %o0
	mov	160, %o1
	call	apara_load_program, 0
	 nop
	sethi	%hi(vector_stats_dmem_image), %g1
	or	%g1, %lo(vector_stats_dmem_image), %o0
	mov	0, %o1
	call	apara_load_dmem_image, 0
	 nop
	sethi	%hi(data), %g1
	or	%g1, %lo(data), %g1
	mov	0, %o0
	mov	0, %o1
	mov	%g1, %o2
	mov	256, %o3
	call	apara_dma_load, 0
	 nop
	mov	0, %o0
	mov	0, %o1
	call	apara_start_thread, 0
	 nop
	mov	0, %o0
	call	apara_wait_thread, 0
	 nop
	mov	%o0, %g2
	sethi	%hi(-2113929216), %g1
	cmp	%g2, %g1
	bne	.LL72
	 nop
	ld	[%fp-20], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-20]
.LL72:
	mov	256, %o0
	ld	[%fp-12], %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL73
	 nop
	ld	[%fp-20], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-20]
.LL73:
	mov	264, %o0
	ld	[%fp-8], %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL74
	 nop
	ld	[%fp-20], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-20]
.LL74:
	mov	272, %o0
	ld	[%fp-4], %o1
	call	dword_equals, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL75
	 nop
	ld	[%fp-20], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-20]
.LL75:
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
