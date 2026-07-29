.global main
main:
_start:
    ! 1. Enable traps: PSR ET=1, PS=1, S=1
    mov 0xE0, %l0
    wr %l0, %psr
    nop
    nop
    nop

    ! 2. Point TBR at this file's own trap table
    set trap_table_base, %l0
    wr %l0, 0x0, %tbr
    nop
    nop
    nop

    ! 3. Sentinel: overwritten by the trap number if anything unexpected traps
    mov 0xBAD, %g1

    !======================================
    ! 4. The instruction(s) under test go here
    add %o0, %o1, %o2
    !======================================

    ta 0            ! 5. normal exit
    nop
    nop

not_reached:
    set 0xDEAD, %g1 ! control should never reach here
    ta 0
    nop
    nop

    .align 4096     ! TBR only captures bits 31:12, so the trap table
                     ! must start on a 4096-byte boundary
trap_table_base:
    ! 256 four-instruction slots, one per trap type (0x00-0xff):
    !   mov <trap number>, %g1 ; restore ; ta 0 ; nop
    ! ... (copy this verbatim from any existing test, see below)
