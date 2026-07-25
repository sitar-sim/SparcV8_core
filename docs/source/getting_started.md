# Getting Started

This page assumes you've completed [Installation](installation.md). It
walks through the whole toolchain hands-on, in the order you'd actually
use it: what SPARC V8 is and where to read more about it, building and
running a first program on the plain C++ model while watching it execute
in the trace viewer, the same again on the Sitar-timed model (and what it
adds), the full validation suite, and where to find more example
programs to learn from.

---

## What is SPARC V8?

SPARC (Scalable Processor ARChitecture) is a RISC instruction set
architecture, notable for its **register window** file: a procedure call
can get a fresh set of registers without spilling to memory, simply by
advancing a circular window into a larger physical register file. SPARC
V8 is the 32-bit revision of the architecture this project models.

The authoritative specification is *The SPARC Architecture Manual,
Version 8*, bundled in this repository at
[`docs/source/sparcv8_Architecture_reference_Manual.pdf`](sparcv8_Architecture_reference_Manual.pdf).
It's long (295 pages, most of it appendices for implementers). For
learning the processor itself, four chapters cover everything this
project's own documentation assumes you know:

| Chapter | Topic | Pages |
|---|---|---|
| 2 | Overview -- the architecture end to end, briefly: registers, instruction categories, traps, memory | ~9-16 |
| 4 | Registers -- the register file and windowing mechanism in full detail, PSR/WIM/TBR | ~23-42 |
| 5 | Instructions -- the instruction set itself: formats, addressing, every opcode | ~43-58 |
| 7 | Traps -- trap handling, directly relevant to how every test program in this repository halts (see below) | ~69-80 |

The rest (appendices A-N) is reference material for implementers --
suggested assembly syntax, ABI conventions, an MMU specification, and
similar -- worth knowing exists, not worth reading up front.

---

## A first program, on the plain C++ model

`model/cpp_model/test/test_simple_ADD.s` is the simplest possible test
program: it adds two numbers and halts.

```asm
! test_simple_ADD.s
!
! The simplest possible SPARC V8 test program: add two numbers and put
! the result in a register, then halt.

.global main
main:
_start:
	! Disable traps. %g0 always reads as 0, so this writes 0 into
	! every bit of %psr, including ET (trap-enable). A write to %psr
	! takes a couple of cycles to take effect, hence the nops after it.
	wr %g0, %psr
	nop
	nop
	nop

	! The actual computation: %o0 = 5 + 7
	mov 5, %l0
	mov 7, %l1
	add %l0, %l1, %o0	! %o0 = 0xc (12)

	! Halt. Traps are disabled (ET=0, set above), so this `ta 0`
	! is not taken as a trap: it forces the processor straight into
	! error_mode instead, which every model in this repo recognizes as
	! a deliberate, successful stop (not a bug).
	ta 0
	nop
	nop
```

Build the plain C++ model with logging enabled, and run it:

```sh
model/cpp_model/build.sh --logging
model/cpp_model/sparc_cpp_sim model/cpp_model/test/test_simple_ADD.hex
```

This writes `sparc_trace.log`, a full instruction/state trace, into the
current directory. Open `log_viewer/viewer.html` in a browser, click
**Load trace** and pick `sparc_trace.log`, then **Load objdump** and pick
`model/cpp_model/test/test_simple_ADD.objdump` (the matching disassembly,
committed alongside the test). See [log_viewer/README.md](https://github.com/sitar-sim/SparcV8_core/blob/main/log_viewer/README.md)
for the full walkthrough.

Step through the trace row by row (arrow keys) and watch the processor
evolve:

- **`RESET` then `TRAP_ENTER`**, at the very start -- every run begins
  this way. The model always boots by taking an implicit reset trap into
  the first instruction; you didn't write this, it's automatic.
- **`FETCH` rows**, one per instruction, each showing the entire
  current-window register state at that point, with whatever changed
  since the previous row highlighted. Watch `%l0`/`%l1`/`%o0` fill in as
  the `mov`/`mov`/`add` sequence runs.
- **`TRAP_RAISED` then `HALT`**, at the end. The final `ta 0` is executed
  with traps already disabled (that's what the `wr %g0, %psr` at the top
  did), so it has no handler to jump to -- the processor forces itself
  into `error_mode` instead. This is this project's halt convention, used
  by every test program in the repository: it's what `sparc_cpp_sim`'s
  `"Simulation halted (error_mode)"` message means, and it's expected,
  not a bug. (This particular program has no trap table at all, so any
  `ta 0` halts it -- programs with a full trap table refine this into an
  actual pass/fail signal; see
  [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#the-pass-fail-convention).)

For automated pass/fail checking instead of watching a trace by hand, use
`check_test` with the test's paired expected-results file -- see
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md).

---

## The Sitar-timed model

The plain C++ model above has no notion of cycles at all -- every
instruction "completes" instantly. `model/sitar_model/` drives the exact
same core through [Sitar](https://sitar-sim.github.io/sitar/) instead,
adding a simple, non-pipelined **cycle-level timing model**: a
configurable per-opcode delay, plus separate interconnect and memory
latencies. See [Model Components](model_components.md#sitar_model-the-cycle-timed-driver)
for how it's structured, and [Performance Modeling](performance_modeling.md)
for the three latency knobs and how to change them.

It produces the same kind of trace, the same way:

```sh
model/sitar_model/build.py --logging
model/sitar_model/executable/sitar_check_test \
    model/sitar_model/executable/test_simple_ADD.hex \
    model/sitar_model/executable/test_simple_ADD.expected
```

This also writes `sparc_trace.log` -- open it in `log_viewer/viewer.html`
exactly as above (same format; the trace viewer doesn't know or care
which model produced it). A second file, `sitar.log`, also appears:
everything else Sitar itself logs (memory-interface/main-memory activity,
useful when working on the timing model itself, not part of the
architectural trace) -- see `model/sitar_model/README.md`.

---

## Building without logging, and running the validation suite

Logging is off by default -- it's slower and, for anything bigger than
one instruction, noisier than you want. Rebuild without `--logging` (or
just omit the flag) for everyday use:

```sh
model/cpp_model/build.sh
model/sitar_model/build.py
```

Run the full instruction-level validation suite against either model:

```sh
validation/run_tests.py validation
```

```
[PASS] validation/asm/misc/save_restore/SAVE.vprj
[PASS] validation/asm/misc/stbar_unimp_nop_sethi/STBAR_UNIMP_NOP_SETHI.vprj

240/240 tests passed
```

Add `--sitar` to run the identical suite against the Sitar-timed model,
`-v` to see every check (not just failures), or point at a subfolder
(e.g. `validation/asm` for only the hand-written assembly tests, or
`validation/C` for only the C mini-benchmarks below) to run a subset. See
`validation/README.md` for the full pipeline, including how to add a new
test.

---

## What's next

- `validation/C/` has ten small, self-validating C mini-benchmarks
  (array sum, matrix multiply, FFT, sorting, and more) worth reading as
  worked examples -- see [Writing and Running C Programs](writing_and_running_c_programs.md).
- Write your own test: [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
  or [Writing and Running C Programs](writing_and_running_c_programs.md).
- Understand how the pieces fit together: [Model Components](model_components.md).
