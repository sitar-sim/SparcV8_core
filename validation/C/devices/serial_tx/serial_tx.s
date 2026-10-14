	.file	"serial_tx.c"
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
	.type	__ajit_store_ubyte_mmu_bypass__, #function
	.proc	020
__ajit_store_ubyte_mmu_bypass__:
	save	%sp, -96, %sp
	mov	%i0, %g1
	st	%i1, [%fp+72]
	stb	%g1, [%fp+68]
	ldub	[%fp+68], %g1
	ld	[%fp+72], %g2
! 48 "/media/nehak/work/1_Research/SparcV8_model.git/compiler/include/ajit_access_routines.h" 1
	stba %g1, [%g2] 32
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_store_ubyte_mmu_bypass__, .-__ajit_store_ubyte_mmu_bypass__
	.align 4
	.type	__ajit_write_serial_control_register_via_bypass__, #function
	.proc	020
__ajit_write_serial_control_register_via_bypass__:
	save	%sp, -96, %sp
	st	%i0, [%fp+68]
	ld	[%fp+68], %o0
	sethi	%hi(-53248), %g1
	or	%g1, 512, %o1
	call	__ajit_store_word_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_write_serial_control_register_via_bypass__, .-__ajit_write_serial_control_register_via_bypass__
	.align 4
	.type	__ajit_read_serial_control_register_via_bypass__, #function
	.proc	016
__ajit_read_serial_control_register_via_bypass__:
	save	%sp, -96, %sp
	sethi	%hi(-53248), %g1
	or	%g1, 512, %o0
	call	__ajit_load_word_mmu_bypass__, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_read_serial_control_register_via_bypass__, .-__ajit_read_serial_control_register_via_bypass__
	.align 4
	.type	__ajit_write_serial_tx_register_via_bypass__, #function
	.proc	020
__ajit_write_serial_tx_register_via_bypass__:
	save	%sp, -96, %sp
	mov	%i0, %g1
	stb	%g1, [%fp+68]
	ldub	[%fp+68], %g1
	and	%g1, 0xff, %g1
	mov	%g1, %o0
	sethi	%hi(-53248), %g1
	or	%g1, 516, %o1
	call	__ajit_store_ubyte_mmu_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_write_serial_tx_register_via_bypass__, .-__ajit_write_serial_tx_register_via_bypass__
	.align 4
	.type	__ajit_serial_configure_via_bypass__, #function
	.proc	020
__ajit_serial_configure_via_bypass__:
	save	%sp, -104, %sp
	mov	%i0, %g3
	mov	%i1, %g2
	mov	%i2, %g1
	stb	%g3, [%fp+68]
	stb	%g2, [%fp+72]
	stb	%g1, [%fp+76]
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ldub	[%fp+68], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL14
	 nop
	ld	[%fp-4], %g1
	or	%g1, 1, %g1
	b	.LL15
	 nop
.LL14:
	ld	[%fp-4], %g1
	and	%g1, -2, %g1
.LL15:
	st	%g1, [%fp-4]
	ldub	[%fp+72], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL16
	 nop
	ld	[%fp-4], %g1
	or	%g1, 2, %g1
	b	.LL17
	 nop
.LL16:
	ld	[%fp-4], %g1
	and	%g1, -3, %g1
.LL17:
	st	%g1, [%fp-4]
	ldub	[%fp+76], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL18
	 nop
	ld	[%fp-4], %g1
	or	%g1, 4, %g1
	b	.LL19
	 nop
.LL18:
	ld	[%fp-4], %g1
	and	%g1, -5, %g1
.LL19:
	st	%g1, [%fp-4]
	ld	[%fp-4], %o0
	call	__ajit_write_serial_control_register_via_bypass__, 0
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_serial_configure_via_bypass__, .-__ajit_serial_configure_via_bypass__
	.align 4
	.type	__ajit_serial_putchar_via_bypass__, #function
	.proc	04
__ajit_serial_putchar_via_bypass__:
	save	%sp, -104, %sp
	mov	%i0, %g1
	stb	%g1, [%fp+68]
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	and	%g1, 1, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL22
	 nop
	ld	[%fp-4], %g1
	and	%g1, 8, %g1
	cmp	%g1, 0
	bne	.LL22
	 nop
	ldub	[%fp+68], %g1
	and	%g1, 0xff, %g1
	mov	%g1, %o0
	call	__ajit_write_serial_tx_register_via_bypass__, 0
	 nop
	mov	1, %g1
	b	.LL23
	 nop
.LL22:
	mov	0, %g1
.LL23:
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_serial_putchar_via_bypass__, .-__ajit_serial_putchar_via_bypass__
	.align 4
	.type	__ajit_serial_puts_via_bypass__, #function
	.proc	020
__ajit_serial_puts_via_bypass__:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%g0, [%fp-4]
	b	.LL26
	 nop
.LL27:
	ld	[%fp+68], %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	ldub	[%g1], %g1
	sll	%g1, 24, %g1
	sra	%g1, 24, %g1
	mov	%g1, %o0
	call	__ajit_serial_putchar_via_bypass__, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	be	.LL27
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL26:
	ld	[%fp-4], %g2
	ld	[%fp+72], %g1
	cmp	%g2, %g1
	bgeu	.LL29
	 nop
	ld	[%fp+68], %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	ldub	[%g1], %g1
	sll	%g1, 24, %g1
	sra	%g1, 24, %g1
	cmp	%g1, 0
	bne	.LL27
	 nop
.LL29:
	restore
	jmp	%o7+8
	 nop
	.size	__ajit_serial_puts_via_bypass__, .-__ajit_serial_puts_via_bypass__
	.align 4
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	cmp	%g1, 31
	bgu	.LL31
	 nop
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	b	.LL32
	 nop
.LL31:
	mov	-1, %g1
.LL32:
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 29 "validation/C/devices/serial_tx/../devices_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL33:
	b	.LL33
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -120, %sp
	st	%g0, [%fp-8]
	mov	88, %o0
	call	__ajit_serial_putchar_via_bypass__, 0
	 nop
	mov	%o0, %g1
	cmp	%g1, 0
	bne	.LL36
	 nop
	ld	[%fp-8], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-8]
.LL36:
	mov	1, %o0
	mov	0, %o1
	mov	0, %o2
	call	__ajit_serial_configure_via_bypass__, 0
	 nop
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	and	%g1, 1, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL37
	 nop
	ld	[%fp-8], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-8]
.LL37:
	sethi	%hi(1214606336), %g2
	or	%g2, 108, %g2
	sethi	%hi(1865162752), %g3
	or	%g3, 115, %g3
	std	%g2, [%fp-24]
	sethi	%hi(1701996544), %g2
	or	%g2, 353, %g2
	sethi	%hi(1814104064), %g3
	or	%g3, 512, %g3
	std	%g2, [%fp-16]
	add	%fp, -24, %g1
	mov	%g1, %o0
	mov	15, %o1
	call	__ajit_serial_puts_via_bypass__, 0
	 nop
	st	%g0, [%fp-4]
	b	.LL38
	 nop
.LL40:
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL38:
	call	__ajit_read_serial_control_register_via_bypass__, 0
	 nop
	mov	%o0, %g1
	and	%g1, 8, %g1
	cmp	%g1, 0
	be	.LL39
	 nop
	ld	[%fp-4], %g2
	sethi	%hi(99328), %g1
	or	%g1, 671, %g1
	cmp	%g2, %g1
	ble	.LL40
	 nop
.LL39:
	ld	[%fp-8], %o0
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
