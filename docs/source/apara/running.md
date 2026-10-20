# Writing and Running APARA Programs

The `apara` configuration is one APARA engine on its own, with no SPARC
core around it. It is the place to write, run, and debug engine
programs, and to study the engine's timing, before using the engine
from a SPARC program (see [The Engine in a System](system.md)).

A run works like this: the simulator places the program in the
engine's IMEM, the initial data in its DMEM, and the initial register
values in its registers, starts one or more threads, and runs until
every thread it started has stopped. It then reports how each thread
stopped, and, if given the expected final state, checks it.

Like every configuration, `apara` comes as a fast functional model
(cpp_model) and a cycle-level timing model (sitar_model), with the same
command line.

---

## Building

From the repo root:

```bash
model/system_models/apara/cpp_model/build.sh      # executable/apara_sim_cpp
model/system_models/apara/sitar_model/build.sh    # executable/apara_sim_sitar (needs the sitar CLI)
```

---

## Running a program

Assemble the program (see [APARA Assembly Language and
Tools](assembly_and_tools.md)), then run the object file:

```bash
python3 compiler/apara/apara_as.py prog.mcode
model/system_models/apara/cpp_model/executable/apara_sim_cpp \
        -p 0x0 -i prog.obj -d data.map -a registers.txt -r results.txt
```

The options:

| Option | Meaning |
|---|---|
| `-p <pc>` | Start a thread at `<pc>` (hexadecimal, an IMEM word index). Repeat it to start threads 1, 2, and 3 too. Without `-p`, one thread starts at 0. |
| `-i <file>` | The object file. |
| `-d <file>` | DMEM's initial contents (a data file). |
| `-a <file>` | Initial register values. |
| `-r <file>` | The expected final state. The run prints `PASS`, or the mismatches and `FAIL`. |
| `--dump-results <file>` | Write the final state as a results file (`-` for the screen). |
| `--stats` | Print statistics: per-thread counts (cpp_model), or the pipeline's counters (sitar_model, see [APARA Timing Model](timing_model.md#knobs)). |
| `--trace` | Print every bundle executed (cpp_model). |
| `--max-bundles <n>` / `--max-cycles <n>` | Stop a run that does not end on its own (cpp_model / sitar_model). |
| `--latency-file <file>` | Change instruction latencies (sitar_model, see [APARA Timing Model](timing_model.md#timing-rules)). |

The file formats are described in [File
formats](assembly_and_tools.md#file-formats).

The exit status is 0 for `PASS`, or, without `-r`, when every thread
stopped with `$halt`. It is 1 otherwise (a mismatch, an exception, or a
thread still running at the limit), and 2 for an error in the command
line or the files. That makes the simulators easy to use from scripts.

### Watching a program run

`--trace` prints one line per bundle executed: its thread and address,
its instructions (without the `$null`s), and, if it did not continue to
the next bundle, where it went. For example, the end of a loop, from
`validation/apara/isa/control/control.mcode`:

```text
t0 0x0:  ? ($i64) $r1 > --1 $goto pc+0;  + $r2 ($i64) $r2 $r1;  -> 0x0
t0 0x0:  ? ($i64) $r1 > --1 $goto pc+0;  + $r2 ($i64) $r2 $r1;
t0 0x8:  ? ($f32) $r3 < $goto pc+16;  -> 0x18
t0 0x18:  ? ($i16) $r4 < $goto pc+16;  + $r5 ($i64) $r0 1;  -> 0x28
t0 0x28:  $call pc+32;  + $r10 ($i64) $r0 16;  -> 0x48
```

The bundle at 0x0 branches back to itself while `$r1` is above 0,
counting `$r1` down each time. On its last pass the branch is not
taken, and the thread falls through to 0x8.

A thread that stops on an exception is reported with the slot and the
cause:

```text
thread 1: stopped at 0x8 by an exception: slot 4 unaligned memory address;
```

---

## Tests

The engine's own test suites are in `validation/apara/`, with their own
runner. [APARA Validation Suite](validation.md) describes what the
suites contain, the format of a test, how to run the suites on both
models, and how to add a test. The following command runs every suite
on the C++ model:

```sh
cd $SPARC_HOME
python3 validation/apara/run_tests.py
```

---

## Hazards

A **hazard** is a bundle reading a register before an older bundle of
the same thread has written its new value. The engine's pipeline
resolves every such read-after-write dependence in hardware: DECODE
tells REGFILE which registers a bundle reads and writes, and REGFILE
holds a bundle until every register it reads or writes has been written
back by the older bundles (see [Register locks and
tokens](timing_model.md#register-locks-and-tokens)). A program, or a
compiler, never needs to insert waits.

The other orderings are safe too:

- **Write after write**: the same locks hold a bundle that writes a
  register an older bundle has yet to write, so the newer value always
  lands last.
- **Write after read**: a bundle reads its registers when it is issued,
  in order, so a later bundle's write can never reach it.
- **Memory**: a thread's loads and stores reach DMEM in program order.
- **Other threads**: each thread has its own registers.

What the hardware does not resolve is within a single bundle: two
instructions writing the same register (directly, or through a
multi-register load, a cast's second register, or an increment). Every
instruction of a bundle reads the registers as they were before the
bundle, so a value written in a bundle cannot be read in the same
bundle. The assembler rejects a register written twice (the
`asm_errors/` tests).

The timing model checks the interlock on every run, in two ways, and
`--stats` reports both:

- **The lock masks.** The registers each bundle actually reads and
  writes when it executes must be among those DECODE locked for it.
  Otherwise the model prints an internal error, since the interlock
  would have missed a dependence, and counts a lock-mask violation
  (`lock-mask violations 0` otherwise). The test runner fails a test
  with any.
- **A hazard count**, kept apart from the locks: a bundle issued while a
  register it reads still has an older write outstanding. With the
  interlock it must be 0 (`RAW hazards 0`).

The `hazards/` tests check that the interlock is needed where it acts.
Built with the knob `engine.regfile.interlock = false` (in
`model/system_models/apara/sitar_model/src/Top.sitar`, see
[Knobs](timing_model.md#knobs)), REGFILE ignores its locks, and each
`hazards/` test must report exactly its `HAZARDS_UNLOCKED` count: the
reads that would get a stale value without the interlock. The tests of
independent bundles, write-after-write, and memory order must report
none. Run them that way with `--sitar`: the runner then checks only the
hazard counts, since the timing is no longer the engine's. Set the knob
back to `true`, and rebuild, afterwards.
