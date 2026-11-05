	.file	"diff_va_same_set_two_ways.c"
	.local	context_table
	.common	context_table,1024,1024
	.local	l1_tables
	.common	l1_tables,2048,1024
	.local	l2_tables
	.common	l2_tables,512,1024
	.local	l3_tables
	.common	l3_tables,512,1024
	.local	frame
	.common	frame,4096,4096
	.local	other_frame
	.common	other_frame,4096,4096
	.section	".text"
	.align 4
	.type	build_tables, #function
	.proc	020
build_tables:
	save	%sp, -160, %sp
	st	%g0, [%fp-64]
	b	.LL2
	 nop
.LL9:
	ld	[%fp-64], %g1
	ld	[%fp-64], %g2
	sll	%g2, 8, %g3
	sethi	%hi(l3_tables), %g2
	or	%g2, %lo(l3_tables), %g2
	add	%g3, %g2, %g2
	st	%g2, [%fp-60]
	ld	[%fp-60], %g2
	st	%g2, [%fp-56]
	ld	[%fp-56], %g2
	srl	%g2, 6, %g2
	sll	%g2, 2, %g2
	or	%g2, 1, %g2
	mov	%g2, %g3
	sethi	%hi(l2_tables), %g2
	or	%g2, %lo(l2_tables), %g2
	sll	%g1, 8, %g1
	st	%g3, [%g2+%g1]
	sethi	%hi(l1_tables), %g1
	or	%g1, %lo(l1_tables), %g2
	ld	[%fp-64], %g1
	sll	%g1, 10, %g1
	add	%g2, %g1, %g2
	ld	[%fp-64], %g1
	sll	%g1, 8, %g3
	sethi	%hi(l2_tables), %g1
	or	%g1, %lo(l2_tables), %g1
	add	%g3, %g1, %g1
	st	%g1, [%fp-52]
	ld	[%fp-52], %g1
	st	%g1, [%fp-48]
	ld	[%fp-48], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g2, [%fp-40]
	st	%g1, [%fp-44]
	st	%g0, [%fp-36]
	b	.LL3
	 nop
.LL4:
	ld	[%fp-36], %g1
	sll	%g1, 2, %g1
	ld	[%fp-40], %g2
	add	%g2, %g1, %g1
	st	%g0, [%g1]
	ld	[%fp-36], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-36]
.LL3:
	ld	[%fp-36], %g1
	cmp	%g1, 255
	ble	.LL4
	 nop
	st	%g0, [%fp-24]
	mov	3, %g1
	st	%g1, [%fp-28]
	mov	1, %g1
	st	%g1, [%fp-32]
	ld	[%fp-24], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-32], %g1
	cmp	%g1, 0
	be	.LL5
	 nop
	mov	128, %g1
	b	.LL6
	 nop
.LL5:
	mov	0, %g1
.LL6:
	or	%g2, %g1, %g2
	ld	[%fp-28], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g2
	ld	[%fp-40], %g1
	st	%g2, [%g1]
	ld	[%fp-40], %g1
	add	%g1, 60, %g2
	sethi	%hi(251658240), %g1
	st	%g1, [%fp-12]
	mov	3, %g1
	st	%g1, [%fp-16]
	mov	1, %g1
	st	%g1, [%fp-20]
	ld	[%fp-12], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g3
	ld	[%fp-20], %g1
	cmp	%g1, 0
	be	.LL7
	 nop
	mov	128, %g1
	b	.LL8
	 nop
.LL7:
	mov	0, %g1
.LL8:
	or	%g3, %g1, %g3
	ld	[%fp-16], %g1
	sll	%g1, 2, %g1
	or	%g3, %g1, %g1
	or	%g1, 2, %g1
	st	%g1, [%g2]
	ld	[%fp-40], %g1
	add	%g1, 64, %g1
	ld	[%fp-44], %g2
	st	%g2, [%g1]
	ld	[%fp-64], %g1
	ld	[%fp-64], %g2
	sll	%g2, 10, %g3
	sethi	%hi(l1_tables), %g2
	or	%g2, %lo(l1_tables), %g2
	add	%g3, %g2, %g2
	st	%g2, [%fp-8]
	ld	[%fp-8], %g2
	st	%g2, [%fp-4]
	ld	[%fp-4], %g2
	srl	%g2, 6, %g2
	sll	%g2, 2, %g2
	or	%g2, 1, %g2
	mov	%g2, %g3
	sethi	%hi(context_table), %g2
	or	%g2, %lo(context_table), %g2
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	ld	[%fp-64], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-64]
.LL2:
	ld	[%fp-64], %g1
	cmp	%g1, 1
	bleu	.LL9
	 nop
	restore
	jmp	%o7+8
	 nop
	.size	build_tables, .-build_tables
	.align 4
	.type	map_page, #function
	.proc	020
map_page:
	save	%sp, -112, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	st	%i3, [%fp+80]
	ld	[%fp+68], %o5
	ld	[%fp+72], %g1
	srl	%g1, 12, %g1
	and	%g1, 63, %g4
	ld	[%fp+76], %g1
	st	%g1, [%fp-4]
	mov	3, %g1
	st	%g1, [%fp-8]
	ld	[%fp+80], %g1
	st	%g1, [%fp-12]
	ld	[%fp-4], %g1
	srl	%g1, 12, %g1
	sll	%g1, 8, %g2
	ld	[%fp-12], %g1
	cmp	%g1, 0
	be	.LL12
	 nop
	mov	128, %g1
	b	.LL13
	 nop
.LL12:
	mov	0, %g1
.LL13:
	or	%g2, %g1, %g2
	ld	[%fp-8], %g1
	sll	%g1, 2, %g1
	or	%g2, %g1, %g1
	or	%g1, 2, %g1
	mov	%g1, %g3
	sethi	%hi(l3_tables), %g1
	or	%g1, %lo(l3_tables), %g2
	sll	%o5, 6, %g1
	add	%g1, %g4, %g1
	sll	%g1, 2, %g1
	st	%g3, [%g2+%g1]
	restore
	jmp	%o7+8
	 nop
	.size	map_page, .-map_page
	.align 4
	.type	enable_mmu, #function
	.proc	020
enable_mmu:
	save	%sp, -120, %sp
	sethi	%hi(context_table), %g1
	or	%g1, %lo(context_table), %g1
	st	%g1, [%fp-24]
	ld	[%fp-24], %g1
	st	%g1, [%fp-20]
	ld	[%fp-20], %g1
	srl	%g1, 6, %g1
	sll	%g1, 2, %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-12]
	mov	256, %g1
	st	%g1, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	mov	1, %g1
	st	%g1, [%fp-4]
	st	%g0, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	restore
	jmp	%o7+8
	 nop
	.size	enable_mmu, .-enable_mmu
	.align 4
	.type	read_alias, #function
	.proc	016
read_alias:
	save	%sp, -104, %sp
	mov	%i0, %g1
	ld	[%g1+4], %g2
	st	%g2, [%fp-4]
	mov	512, %g2
	st	%g2, [%fp-8]
	ld	[%fp-4], %g2
	ld	[%fp-8], %g3
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g2, [%g3] 0x04
! 0 "" 2
	ld	[%g1], %g1
	ld	[%g1], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	read_alias, .-read_alias
	.align 4
	.type	check_one_direction, #function
	.proc	016
check_one_direction:
	save	%sp, -152, %sp
	mov	%i0, %l1
	mov	%i1, %l0
	st	%i2, [%fp+76]
	st	%g0, [%fp-48]
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	ld	[%l1+4], %g1
	st	%g1, [%fp-36]
	mov	512, %g1
	st	%g1, [%fp-40]
	ld	[%fp-36], %g1
	ld	[%fp-40], %g2
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%l1], %g1
	ld	[%fp+76], %g2
	add	%g2, 1, %g2
	st	%g2, [%g1]
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+76], %g1
	add	%g1, 1, %g1
	cmp	%g2, %g1
	bne	.LL20
	 nop
	ld	[%fp-48], %g1
	or	%g1, 1, %g1
	st	%g1, [%fp-48]
.LL20:
	ld	[%l1], %g1
	st	%g1, [%fp-56]
	ld	[%l1+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	ld	[%l1+4], %g1
	st	%g1, [%fp-28]
	mov	512, %g1
	st	%g1, [%fp-32]
	ld	[%fp-28], %g1
	ld	[%fp-32], %g2
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%l1], %g1
	ld	[%fp+76], %g2
	add	%g2, 2, %g2
	st	%g2, [%g1]
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+76], %g1
	add	%g1, 2, %g1
	cmp	%g2, %g1
	bne	.LL21
	 nop
	ld	[%fp-48], %g1
	or	%g1, 2, %g1
	st	%g1, [%fp-48]
.LL21:
	ld	[%l1+4], %g1
	st	%g1, [%fp-20]
	mov	512, %g1
	st	%g1, [%fp-24]
	ld	[%fp-20], %g1
	ld	[%fp-24], %g2
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%l1], %g1
	mov	-85, %g2
	stb	%g2, [%g1]
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+76], %g1
	add	%g1, 2, %g3
	sethi	%hi(16776192), %g1
	or	%g1, 1023, %g1
	and	%g3, %g1, %g3
	sethi	%hi(-1426063360), %g1
	or	%g3, %g1, %g1
	cmp	%g2, %g1
	bne	.LL22
	 nop
	ld	[%fp-48], %g1
	or	%g1, 4, %g1
	st	%g1, [%fp-48]
.LL22:
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	ld	[%l1+4], %g1
	st	%g1, [%fp-12]
	mov	512, %g1
	st	%g1, [%fp-16]
	ld	[%fp-12], %g1
	ld	[%fp-16], %g2
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%l1], %g1
! 92 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../alias_common.h" 1
	ldstub [%g1], %g1
! 0 "" 2
	st	%g1, [%fp-44]
	ld	[%fp-44], %g1
	cmp	%g1, 171
	bne	.LL23
	 nop
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+76], %g1
	add	%g1, 2, %g3
	sethi	%hi(-16777216), %g1
	or	%g3, %g1, %g1
	cmp	%g2, %g1
	bne	.LL23
	 nop
	ld	[%fp-48], %g1
	or	%g1, 8, %g1
	st	%g1, [%fp-48]
.LL23:
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	ld	[%l1+4], %g1
	st	%g1, [%fp-4]
	mov	512, %g1
	st	%g1, [%fp-8]
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
! 96 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../../../mmu/mmu_common.h" 1
	sta %g1, [%g2] 0x04
! 0 "" 2
	ld	[%fp+76], %g1
	add	%g1, 3, %g1
	st	%g1, [%fp-44]
	ld	[%l1], %g2
	ld	[%fp-44], %g1
! 98 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../alias_common.h" 1
	swap [%g2], %g1
! 0 "" 2
	st	%g1, [%fp-44]
	ld	[%fp+76], %g1
	add	%g1, 2, %g2
	sethi	%hi(-16777216), %g1
	or	%g2, %g1, %g2
	ld	[%fp-44], %g1
	cmp	%g2, %g1
	bne	.LL24
	 nop
	ld	[%l0], %g1
	st	%g1, [%fp-56]
	ld	[%l0+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+76], %g1
	add	%g1, 3, %g1
	cmp	%g2, %g1
	bne	.LL24
	 nop
	ld	[%fp-48], %g1
	or	%g1, 16, %g1
	st	%g1, [%fp-48]
.LL24:
	ld	[%l1], %g1
	st	%g1, [%fp-56]
	ld	[%l1+4], %g1
	st	%g1, [%fp-52]
	add	%fp, -56, %g1
	mov	%g1, %o0
	call	read_alias, 0
	 nop
	mov	%o0, %g2
	ld	[%fp+76], %g1
	add	%g1, 3, %g1
	cmp	%g2, %g1
	bne	.LL25
	 nop
	ld	[%fp-48], %g1
	or	%g1, 32, %g1
	st	%g1, [%fp-48]
.LL25:
	ld	[%fp-48], %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	check_one_direction, .-check_one_direction
	.align 4
	.type	check_alias_pair, #function
	.proc	016
check_alias_pair:
	save	%sp, -112, %sp
	mov	%i0, %l0
	mov	%i1, %l1
	ld	[%l0], %g1
	st	%g1, [%fp-8]
	ld	[%l0+4], %g1
	st	%g1, [%fp-4]
	ld	[%l1], %g1
	st	%g1, [%fp-16]
	ld	[%l1+4], %g1
	st	%g1, [%fp-12]
	add	%fp, -8, %g2
	add	%fp, -16, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	sethi	%hi(4096), %o2
	call	check_one_direction, 0
	 nop
	mov	%o0, %l2
	ld	[%l1], %g1
	st	%g1, [%fp-16]
	ld	[%l1+4], %g1
	st	%g1, [%fp-12]
	ld	[%l0], %g1
	st	%g1, [%fp-8]
	ld	[%l0+4], %g1
	st	%g1, [%fp-4]
	add	%fp, -16, %g2
	add	%fp, -8, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	sethi	%hi(8192), %o2
	call	check_one_direction, 0
	 nop
	mov	%o0, %g1
	sll	%g1, 6, %g1
	or	%l2, %g1, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	check_alias_pair, .-check_alias_pair
	.align 4
	.type	report_and_halt, #function
	.proc	020
report_and_halt:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	ld	[%fp+72], %g1
	mov	1, %g2
	sll	%g2, %g1, %g1
	add	%g1, -1, %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %g2
	ld	[%fp-8], %g1
	xor	%g2, %g1, %g1
	subcc	%g0, %g1, %g0
	subx	%g0, -1, %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	ld	[%fp+68], %g2
! 115 "validation/C/caches/synonyms/diff_va_same_set_two_ways/../alias_common.h" 1
	mov %g1, %o0
	mov %g2, %o1
	ta 0
! 0 "" 2
.LL30:
	b	.LL30
	 nop
	.size	report_and_halt, .-report_and_halt
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -128, %sp
	sethi	%hi(268500992), %g1
	st	%g1, [%fp-8]
	st	%g0, [%fp-4]
	sethi	%hi(268517376), %g1
	st	%g1, [%fp-16]
	st	%g0, [%fp-12]
	call	build_tables, 0
	 nop
	mov	0, %o0
	sethi	%hi(268500992), %o1
	sethi	%hi(frame), %g1
	or	%g1, %lo(frame), %o2
	mov	1, %o3
	call	map_page, 0
	 nop
	mov	0, %o0
	sethi	%hi(268517376), %o1
	sethi	%hi(frame), %g1
	or	%g1, %lo(frame), %o2
	mov	1, %o3
	call	map_page, 0
	 nop
	call	enable_mmu, 0
	 nop
	ldd	[%fp-8], %g2
	std	%g2, [%fp-24]
	ldd	[%fp-16], %g2
	std	%g2, [%fp-32]
	add	%fp, -24, %g2
	add	%fp, -32, %g1
	mov	%g2, %o0
	mov	%g1, %o1
	call	check_alias_pair, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %o0
	mov	12, %o1
	call	report_and_halt, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.3"
