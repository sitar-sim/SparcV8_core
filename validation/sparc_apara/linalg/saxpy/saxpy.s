	.file	"saxpy.c"
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
! 29 "validation/sparc_apara/linalg/saxpy/../../../C/devices/devices_common.h" 1
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
	be	.LL43
	 nop
	mov	8, %g1
	b	.LL44
	 nop
.LL43:
	mov	0, %g1
.LL44:
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
.LL49:
	ld	[%fp+68], %o0
	call	apara_dma_done, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL49
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
	.type	enable_fpu, #function
	.proc	020
enable_fpu:
	save	%sp, -96, %sp
! 42 "validation/sparc_apara/linalg/saxpy/../../apara_common.h" 1
	rd %psr, %g1
	set 0x1000, %g2
	or %g1, %g2, %g1
	wr %g1, %psr
	nop
	nop
	nop
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	enable_fpu, .-enable_fpu
	.section	".rodata"
	.align 4
	.type	saxpy_kernel_program, #object
	.size	saxpy_kernel_program, 388
saxpy_kernel_program:
	.long	-738000640
	.long	1413742848
	.long	-1602021372
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1292114944
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1870585856
	.long	276956160
	.long	-1803348960
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1994389245
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1199369214
	.long	1413742848
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
	.long	1292181507
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1717237755
	.long	948114434
	.long	1409548416
	.long	1413873920
	.long	-1601953786
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1292247043
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1851447290
	.long	948114434
	.long	1409548416
	.long	1413873920
	.long	-1601953786
	.long	-402653184
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1359290371
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1870523391
	.long	-1803348960
	.long	-402653184
	.long	1744830464
	.long	-402653184
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-1994786557
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	1744830464
	.long	-335544320
	.align 4
	.type	saxpy_kernel_dmem_image, #object
	.size	saxpy_kernel_dmem_image, 8
saxpy_kernel_dmem_image:
	.skip	8
	.local	x
	.common	x,128,4
	.local	y
	.common	y,128,4
	.local	expected
	.common	expected,128,4
	.align 4
.LLC0:
	.long	1069547520
	.align 4
.LLC1:
	.long	1048576000
	.align 4
.LLC2:
	.long	1056964608
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -128, %sp
	st	%g0, [%fp-16]
	mov	1, %g1
	st	%g1, [%fp-8]
	call	enable_fpu, 0
	 nop
	sethi	%hi(.LLC0), %g1
	or	%g1, %lo(.LLC0), %g1
	ld	[%g1], %f8
	st	%f8, [%fp-4]
	st	%g0, [%fp-12]
	b	.LL56
	 nop
.LL57:
	ld	[%fp-12], %g1
	ld	[%fp-12], %g2
	add	%g2, -16, %g2
	st	%g2, [%fp-28]
	ld	[%fp-28], %f8
	fitos	%f8, %f9
	sethi	%hi(.LLC1), %g2
	or	%g2, %lo(.LLC1), %g2
	ld	[%g2], %f8
	fmuls	%f9, %f8, %f8
	sethi	%hi(x), %g2
	or	%g2, %lo(x), %g2
	sll	%g1, 2, %g1
	st	%f8, [%g2+%g1]
	ld	[%fp-12], %g3
	ld	[%fp-12], %g1
	mov	%g1, %g2
	add	%g2, %g2, %g2
	add	%g2, %g1, %g1
	add	%g1, -40, %g1
	st	%g1, [%fp-28]
	ld	[%fp-28], %f8
	fitos	%f8, %f9
	sethi	%hi(.LLC2), %g1
	or	%g1, %lo(.LLC2), %g1
	ld	[%g1], %f8
	fmuls	%f9, %f8, %f8
	sethi	%hi(y), %g1
	or	%g1, %lo(y), %g2
	sll	%g3, 2, %g1
	st	%f8, [%g2+%g1]
	ld	[%fp-12], %g1
	ld	[%fp-12], %g2
	sethi	%hi(x), %g3
	or	%g3, %lo(x), %g3
	sll	%g2, 2, %g2
	ld	[%g3+%g2], %f9
	ld	[%fp-4], %f8
	fmuls	%f9, %f8, %f9
	ld	[%fp-12], %g2
	sethi	%hi(y), %g3
	or	%g3, %lo(y), %g3
	sll	%g2, 2, %g2
	ld	[%g3+%g2], %f8
	fadds	%f9, %f8, %f8
	sethi	%hi(expected), %g2
	or	%g2, %lo(expected), %g2
	sll	%g1, 2, %g1
	st	%f8, [%g2+%g1]
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL56:
	ld	[%fp-12], %g1
	cmp	%g1, 31
	bleu	.LL57
	 nop
	sethi	%hi(saxpy_kernel_program), %g1
	or	%g1, %lo(saxpy_kernel_program), %o0
	mov	97, %o1
	call	apara_load_program, 0
	 nop
	sethi	%hi(x), %g1
	or	%g1, %lo(x), %g1
	mov	0, %o0
	mov	0, %o1
	mov	%g1, %o2
	mov	128, %o3
	call	apara_dma_load, 0
	 nop
	sethi	%hi(y), %g1
	or	%g1, %lo(y), %g1
	mov	1, %o0
	mov	128, %o1
	mov	%g1, %o2
	mov	128, %o3
	call	apara_dma_load, 0
	 nop
	ld	[%fp-4], %f8
	st	%f8, [%fp-20]
	ld	[%fp-20], %g1
	mov	256, %o0
	mov	%g1, %o1
	call	apara_dmem_write_word, 0
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
	bne	.LL58
	 nop
	ld	[%fp-16], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-16]
.LL58:
	st	%g0, [%fp-12]
	b	.LL59
	 nop
.LL60:
	ld	[%fp-12], %g1
	sethi	%hi(expected), %g2
	or	%g2, %lo(expected), %g2
	sll	%g1, 2, %g1
	ld	[%g2+%g1], %f8
	st	%f8, [%fp-20]
	ld	[%fp-12], %g1
	add	%g1, 32, %g1
	sll	%g1, 2, %g1
	mov	%g1, %o0
	call	apara_dmem_read_word, 0
	 nop
	mov	%o0, %g2
	ld	[%fp-20], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	ld	[%fp-8], %g2
	and	%g2, %g1, %g1
	st	%g1, [%fp-8]
	ld	[%fp-12], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-12]
.LL59:
	ld	[%fp-12], %g1
	cmp	%g1, 31
	bleu	.LL60
	 nop
	ld	[%fp-8], %g1
	cmp	%g1, 0
	be	.LL61
	 nop
	ld	[%fp-16], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-16]
.LL61:
	ld	[%fp-16], %o0
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
