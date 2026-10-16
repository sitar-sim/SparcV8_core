# APARA: Deviations and Findings

This project's APARA model is its own implementation of the engine,
written from the engine's documents and checked against APARA's
reference model. Its sources, in order of authority:

1. **The microarchitecture document** (*APARA Engine: Microarchitecture
   and Timing*, `engine_isp/docs/microarch` in the APARA repository), for
   the engine's structure and timing. Its latency table gives the timing
   model's default latencies. The timing model has been checked against
   this document, but not yet against the hardware's own (Aa_model)
   simulation traces.
2. **The ISA document** (`engine_isp/isa/isa.txt` in the APARA
   repository), for what each instruction does.
3. **The reference model**, McodeMachine, with its tools (`mcode_align`,
   `mcode_assemble`, `mcode_run`). The narrow-float conversion rules
   (see [Instruction Set](isa.md)) are exactly its rules. Its alignment
   (`mcode_align`) and assembly (`mcode_assemble`) steps are one step in
   this project's assembler, which uses the same file formats, so files
   move freely between the two sets of tools; the simulators accept
   `mcode_run`'s options.

For every program the reference tools handle correctly, the model gives
the same results: the assembler writes the same object file, and a run
reaches the same final state (PC, registers, DMEM). This was checked on
every valid program of the APARA repository, and on this project's own
tests (see [Writing and Running Programs](running.md#running-the-tests)).

This page lists where the model deliberately differs from the reference
model, and why, followed by the open questions in the sources, which
are to be reviewed with APARA's designers. Every test that depends on a
deviation has a `DEVIATION` line in its `.vprj`, and the tests of the
deviations themselves are collected in `validation/apara/deviations/`.

---

## Deviations from the reference model

Each row gives what the reference model does, what this model does
instead, and why. Most are fixes of defects in the reference model,
where it contradicts the ISA document or its own intent.

### Semantics

| # | Reference model | This model | Why |
|---|---|---|---|
| 1 | `$return` reads the top of the RAS but never pops it: only one level of calls returns correctly | `$return` pops | a stack; nested calls (`dev_control.mcode`) |
| 2 | a 4-byte load picks the word's half by address bit 1 (its store uses bit 2) | bit 2 for both | a load at offset 4 read the wrong half (`dev_arith.mcode`) |
| 3 | `$vreduce` starts every reduction at 0, so `*` and `&` always give 0 | each starts at its operation's identity (1 for `*`, all ones for `&` and `~^`) | correct reductions |
| 4 | `$vreduce` sign-extends unsigned elements | zero-extends them | `$vu8` 255+1 gave 0 |
| 5 | `$cmov` writes `$rs2` back with its sign-extended test value plus the increment, even without an increment; the 2-bit increment is not sign-extended (`--1` adds 3) | `$rs2` written only with an increment, as `$rs2 + increment`, signed | an `($i8)` test clobbered a 64-bit `$rs2` |
| 6 | an unsigned test (branch, `$cmov`) compares as a signed 64-bit value; a float test compares the sign-extended bit pattern | unsigned compares unsigned; floats compare by value, NaN satisfies only `!=` | `($u64) 2^63 > 0` was false |
| 7 | a float `$dot $accumulate` ignores the accumulator | starts from `$rd`'s f32 value | the instruction's meaning |
| 8 | no `$fsqrt` (an error, result 0) | implemented for f32 and f64 (as `pow(x, 0.5)`, as the reference's helpers would) | isa.txt |
| 9 | no float casts (an error) | implemented: integer to float converts the full source value; float to integer truncates toward zero and saturates; NaN gives 0 | isa.txt lists them |
| 10 | a scalar integer cast from a 64-bit source is not truncated to the destination width (narrower sources are) | always truncated | consistency |
| 11 | no float divide for f4, f8, f16 (assert) | every float width divides | |
| 12 | a load/store's negative increment is added as an unsigned 32-bit value (`bytes * increment` is evaluated as `unsigned`): `--1` on an 8-byte load adds 0xFFFFFFF8 | a signed 64-bit add | a C++ promotion bug |
| 13 | float ALU operations other than `+ - * /`, and vector ones other than `+ - *`, assert | illegal instruction (the assembler rejects them) | |
| 14 | the branch decoder reads `rs2` as 6 bits [5:0], including the offset's low bit | bits [4:0] | an odd offset selected a register 32 higher |
| 31 | every element-wise `$v` operation on 4-bit elements (`$vi4`, `$vu4`) gives 0 | computed, each element wrapping at 4 bits (`dev_vector4.mcode`) | the ISA lists the 4-bit vector types; the reference's own `$dot ($vi4)` works |
| 32 | a non-negative operand of a narrow signed type keeps the bits above the type's width (`($i8)` 0x105 + 0 = 0x105), in the ALU, branches and `$cmov` | only the type's width is read (5) (`dev_narrow_signed.mcode`) | "r1 and r2 are i8"; negative values were already sign-extended |

### Errors and limits

| # | Reference model | This model | Why |
|---|---|---|---|
| 15 | errors (divide by zero, unaligned address, ...) print a message and the thread goes on | the thread halts with the hardware's ERROR codes; the faulting bundle changes nothing | the hardware's behavior (microarch doc) |
| 16 | a push into a full RAS asserts; a return with an empty one asserts | the thread halts, ERROR bit 26 | the microarch doc |
| 17 | 32-byte transfers are checked for 2-byte alignment only | 32-byte alignment | |
| 18 | when the thread picked to run has no bundle at its PC, the whole run ends | that thread halts (exception 7, slot 0); the others go on | a thread's fault should not stop the others |
| 19 | no check of the slot rules | a branch outside slot 0, a divide outside slot 1, a load/store outside slots 4-7 raise exception 7 | the hardware's `instruction_alignment_error` |
| 20 | IMEM is 2048 words (8 KB) | 4096 words (16 KB) | the microarch doc and `imem.aa` |

### Tools

| # | Reference tools | Ours | Why |
|---|---|---|---|
| 21 | the assembler silently truncates out-of-range registers (`$r40`), immediates and increments, and leaves an unknown label's offset 0 | errors | |
| 22 | the assembler rejects `$vreduce` with <code>&#124; &amp; ^ ~^</code>, and `*` on elements other than 32 bits | accepts them (element width below 64) | isa.txt permits all six |
| 23 | `$vreduce ~^` is assembled as `^` | as `~^` (XNOR, opcode 0x0D) | |
| 24 | a blank line in an object file writes IMEM[0] = 0 | blank lines are ignored | |
| 25 | `mcode_run`'s results check always exits 0 | exit status 1 on a mismatch | scripts can use it |

### The engine in a system (sparc_apara)

From the hardware's Aa sources (`cpu/ccu/ccu.aa`, `dma/control.aa`,
`data_mem/*.aa`), which the reference model does not cover:

| # | Source | This model | Why |
|---|---|---|---|
| 26 | `dma/control.aa` uses control-word bit 3 as interrupt enable, as the error flag on completion, and (written) to clear the interrupt; a command with it set never starts | flags [0] scheduled, [1] started, [2] completed, [3] interrupt enable, [4] error | one meaning per bit |
| 27 | CCU.TXT calls command 7 "wait-on-complete"; `ccu.aa` polls (non-blocking), so its interrupt fires only if a poll finds the thread already stopped | without interrupt enable, a poll; with it, the command waits for the stop, then interrupts | an interrupt a program can wait for |
| 28 | command 8 (step) executes the instruction in R2 at PC R1 | one bundle from IMEM at R1, with local data only; R7 := the next PC | debugging use |
| 29 | command 9 returns the RAS's 52-bit internal state | R6 := depth, R7 := top | |
| 30 | (reset leaves registers to the hardware's reset) | reset keeps the registers, clears PC, RAS and ERROR | registers set before a run survive a reset |

Which addresses are local also follows the hardware: in a system, only
the engine's own DMEM window is local, and every other address goes out
to the system. The reference model aliases every address into DMEM, and
the standalone `apara` configuration keeps that behavior.

The system's physical addresses (see [The Engine in a
System](system.md#address-map)) follow the AJIT_APARA layout, with the
addresses APARA's parameter template gives engine 0 of cluster 0.

---

## Cross-checking against the reference simulator

`validation/apara/run_tests.py --reference --mcode-run <path to
mcode_run>` also cross-checks the model against the reference
simulator. For every test without a `DEVIATION` line, the model writes
its final state (the PC, every register, and every DMEM word that is or
was non-zero) as a results file, and the reference simulator, given the
same program and inputs, must reach exactly that state. This checks the
model and the test's own expectations at the same time.

---

## Open questions in the sources

Where the sources disagree or are silent, the model makes an explicit
choice, listed here. D1 to D7 come from the first review of the
sources, the rest from the findings since.

- **D1, opcode numbering from 0x16.** The Aa_model's `parameters.aa` and
  `OperatorClassification.txt` disagree. The model uses the assembler's
  numbering (`isa/parameters.aa`) and keys its latencies by instruction
  class, not opcode.
- **D2, memory operations per bundle.** The microarch doc says at most two
  (one per DMEM port); the slot rules, `mcode_align` and the reference
  documentation allow four. The model allows four, two ports, same-bank
  accesses one after another.
- **D3, slot rules.** The model enforces the microarch doc's (and the
  assembler produces them).
- **D4, EXEC's structure.** "Holds one bundle until the slowest finishes"
  versus "internally pipelined, full rate". The model is pipelined, results
  in order; `engine.exec.pipelined = false` gives the other.
- **D5, latencies.** DIV and FSQRT 10 cycles (verbal), VREDUCE 2 and CMOV 1
  (assumed): not in `OperatorClassification.txt`.
- **D6, the parameter template.** Its comments and values disagree on the
  DMEM and configuration base addresses; the model follows the values (they
  agree with the AFB demultiplexer's decode).
- **D7, a push into a full RAS.** Halts the thread (microarch doc) versus
  "blocks the engine" (ISA text): the model halts the thread.
- **Same-bank order.** The microarch doc serializes same-bank accesses in
  slot order; the Aa_model does not fix an order. The model uses slot
  order.
- **Exception code 4**, "integer square root of a negative number", is in
  the hardware's exception table, but isa.txt says there is no integer
  square root. The model has none (the code is unused).
- **The BTB is shared by the four threads**; two threads' branches that
  alias to one entry evict each other. Modeled as described.
- **REGFILE and WRITEBACK.** The microarch doc's channel table shows lock
  releases going from WRITEBACK to REGFILE, its text (from the Aa_model)
  has REGFILE reading EXEC's results and forwarding them to the retire
  daemon. The model follows the text; with two tokens it is the version
  that sustains one bundle per cycle.

---

## Findings of the validation suites

The validation suites (`validation/apara/`, `validation/sparc_apara/`)
also turned up places where the engine's ISA and microarchitecture
documents are contradictory, ambiguous, or describe a design property
worth a decision: for example, whether `$set` inserts or replaces, the
limits of `$pack` and `$dot`, the branch predictor training only on
mispredicts, returns being predicted by the BTB alone, the throughput
limit of two REGFILE tokens, and the lack of an atomic read-modify-write.
They are listed, each with the test that shows it, in
`docs/compliance/apara_specification_findings.md`.
