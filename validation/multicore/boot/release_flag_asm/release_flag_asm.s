! Every core: read its core ID from ASR29, write ID+1 to its own word at
! 0x8000 + 4*ID, put ID+1 in %o0, and halt. Cores 1-3 first wait until
! core 0 has set scratch-pad word 0 to 1 (the release flag).
.global main
main:
	rd %asr29, %l0
	srl %l0, 8, %l0
	and %l0, 0xff, %l0          ! %l0 = core ID
	set 0xFFFF2C00, %l1         ! scratch-pad word 0
	cmp %l0, 0
	bne wait_for_release
	nop
	mov 1, %l2
	sta %l2, [%l1] 0x20         ! core 0: release the others
	ba work
	nop
wait_for_release:
	lda [%l1] 0x20, %l2
	cmp %l2, 1
	bne wait_for_release
	nop
work:
	add %l0, 1, %o0
	set 0x8000, %l3
	sll %l0, 2, %l4
	st %o0, [%l3 + %l4]
	ta 0
	nop
