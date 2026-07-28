# Writing and Running Assembly Programs

This page covers writing a SPARC assembly test program from scratch,
building and running it directly against the model, and checking its
final state against a hand-written expected-results file. To then run it
alongside the rest of the suite automatically instead of by hand, see
[Validation Suite](validation_suite.md).

---

## Writing a test program

Every test is a pair of files: `<name>.s` (the assembly source) and,
once you're ready to automate it, `<name>.vprj` (see "Adding it to the
validation suite" below). A `.s` file is fully self-contained and always
has the same shape:

```sparc
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
```

### The pass-fail convention

Every test always halts the same way: a `ta 0` taken with traps disabled
(`ET=0`, cleared automatically on trap entry) forces the processor into
`error_mode` per the manual (Appendix C, Section C.8). This is what
`PROCESSOR STATE: ERROR` in `sparc_sim_cpp`'s output means, and it's
expected, not a bug.

`%g1` distinguishes a clean run from an unexpected trap:

- If the test's own final `ta 0` (step 5 above) is what triggers this,
  its trap-table slot (`SW_trap_0x80`) sets `%g1 = 0x80`. **This is
  success: nothing unexpected happened.**
- If *any other* trap occurs first (a bug, a mistake in the test, or a
  trap you're deliberately testing for), it's caught by *that* trap's own
  table slot, which records the trap number into `%g1` before re-trapping
  the same way. So `%g1`'s final value tells you exactly what happened,
  whether the test passed or not.

### The trap table

The 256-entry trap table is always the same boilerplate (each slot is a
fixed 4 instructions: `mov <tt>, %g1; restore; ta 0; nop`). Copy it
verbatim from any existing test rather than retyping it. To make a test
verify a *specific* trap actually fires (rather than just detecting an
unexpected one), replace that one slot with custom code. For example,
`validation/asm/floating_point/fp_exceptions/overflow.s` replaces its
`HW_trap_0x08` slot with `inc %g2; rett %r18; nop; nop`, which increments
a counter and *resumes* execution right after the trapping instruction
(via `rett`), instead of halting. This lets the test both confirm the
trap fired (`%g2`) and continue on to a normal exit (`%g1 = 0x80`).

---

## Building and running it

Assemble the `.s` file into a memory image:

```sh
compiler/assemble.sh your_test.s
```

This produces `your_test.hex` (the memory image) and `your_test.objdump`
(its disassembly plus full symbol table, useful for finding an address
to give gdb, see [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md#finding-addresses)).
Requires the `sparc-elf` toolchain on `PATH`, see [Cross Compiler](cross_compiler.md).

Run it directly against the model:

```sh
model/cpp_model/sparc_sim_cpp your_test.hex
```

This prints the final register state once the program halts, see
[Getting Started](getting_started.md#running-the-simulator) for the full
walkthrough (including the Sitar-timed model, which takes the identical
CLI).

---

## Writing an expected-results file

Instead of reading the final register dump by hand, pass the executable
a second argument, an expected-results file, and it checks the final
state against it directly:

```sh
model/cpp_model/sparc_sim_cpp your_test.hex your_test.expected
```

`your_test.expected` is a plain text file, one check per line:

```
REG o2 0x0000000c
MEM 0x2000 0xdeadbeef
```

- `REG <name> <hex value> [mask]` checks a register (mnemonics `g1`-`g7`,
  `o0`-`o7`, `l0`-`l7`, `i0`-`i7`, `f0`-`f31`, `psr`, `fpsr`, `y`, `wim`,
  `tbr`, `pc`, `npc`, `asr0`-`asr31`).
- `MEM <hex addr> <hex value> [mask]` checks a word-aligned 32-bit
  memory read.
- Either kind accepts an optional trailing mask, to check only specific
  bits.

---

## Adding it to the validation suite

Hand-writing a `.expected` file and running it yourself works for one
test at a time. To run your test alongside the rest of the suite
automatically instead, and have it re-checked every time the model
changes, wrap it as a `.vprj` file (the same `REG`/`MEM` checks, in a
slightly different format that also names the paired `.s` source). See
[Validation Suite](validation_suite.md) for the `.vprj` format, the
two-phase build/run pipeline, and where a new test's category folder
goes.

---

See `validation/asm/README.md` for the AJIT-adaptation attribution and
`docs/compliance/README.md` for documented, specific divergences from AJIT's
own reference results (kept separate from the maintained suite since they
represent understood implementation differences, not bugs).
