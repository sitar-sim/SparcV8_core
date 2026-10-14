# Writing and Running APARA Programs

The `apara` configuration is one engine on its own: its program and data
are placed straight into IMEM and DMEM (and its registers set) before the
run, and the run ends when every thread it started has stopped. It comes,
like every configuration, as a fast functional model (cpp_model) and a
cycle-level timing model (sitar_model), with the same command line.

## Building

```bash
model/system_models/apara/cpp_model/build.sh      # executable/apara_sim_cpp
model/system_models/apara/sitar_model/build.sh    # executable/apara_sim_sitar (needs sitar)
```

## Running a program

```bash
python3 compiler/apara/apara_as.py prog.mcode
model/system_models/apara/cpp_model/executable/apara_sim_cpp \
        -p 0x0 -i prog.obj -d data.map -a registers.txt -r results.txt
```

| Option | Meaning |
|---|---|
| `-p <pc>` | start a thread at `<pc>` (hex, a word index); repeat for threads 1, 2, 3 (default: one thread at 0) |
| `-i <file>` | the object file |
| `-d <file>` | initial DMEM contents |
| `-a <file>` | initial register values |
| `-r <file>` | the expected final state: the run prints `PASS` or the mismatches and `FAIL` |
| `--dump-results <file>` | write the final state as a results file (`-` for the screen) |
| `--stats` | per-thread counts (cpp_model); the pipeline's counters (sitar_model) |
| `--trace` | print every bundle executed (cpp_model) |
| `--max-bundles <n>` / `--max-cycles <n>` | stop a run that does not end (cpp_model / sitar_model) |
| `--latency-file <file>` | instruction latencies (sitar_model, Ref [Timing Model](timing_model.md)) |

These are the options of the APARA reference simulator, `mcode_run`, plus
ours, so the same files run on both. The exit status is 0 for `PASS` (or,
without `-r`, when no thread stopped on an exception), 1 otherwise.

`--trace` shows the program as it runs:

```text
t0 0x0:  ? ($i64) $r1 > --1 $goto pc+0;  + $r2 ($i64) $r2 $r1;  -> 0x0
t0 0x0:  ? ($i64) $r1 > --1 $goto pc+0;  + $r2 ($i64) $r2 $r1;
t0 0x8:  ? ($f32) $r3 < $goto pc+16;  -> 0x18
t0 0x18:  ? ($i16) $r4 < $goto pc+16;  + $r5 ($i64) $r0 1;  -> 0x28
t0 0x28:  $call pc+32;  + $r10 ($i64) $r0 16;  -> 0x48
```

(the end of a loop, from `validation/apara/tests/control.mcode`: a line
per bundle, its thread and address, its instructions without the
`$null`s, and where it went if not to the next bundle).

A thread that stops on an exception is reported with its slot and cause:

```text
thread 1: stopped at 0x8 by an exception: slot 4 unaligned memory address;
```

## Tests

`validation/apara/` holds the engine's tests: `tests/` (one per
instruction class, multithreading, bundle semantics, and the
[deviations](deviations.md)) and `timing/` (microbenchmarks with
hand-derived cycle counts). Each test is one mcode file that also says
how to run it and what to expect, in `//@` lines:

```mcode
// $cmov: if $rs2 satisfies the condition, $rd = $rs1.
//@ reg: 0 $r1 5
//@ expect: 0 reg $r4 0x5
//@ cycles: 7
    || $cmov ($i64) $r1 == $r4 $r2 ;
    || $halt ;
```

| Line | Meaning |
|---|---|
| `//@ threads: 0x0 0x20` | start threads at these PCs (default: one at 0x0) |
| `//@ data: 10: 0x...` | an initial DMEM dword |
| `//@ reg: 0 $r3 0x10` | an initial register: thread, register, value |
| `//@ expect: 0 reg $r5 0x7` | an expected result (results-file format, registers as `$rN`) |
| `//@ cycles: 12` | the exact cycle count on the timing model |
| `//@ deviation: <why>` | the test depends on a deviation from the reference model |

```bash
python3 validation/apara/run_tests.py                 # all tests, cpp_model
python3 validation/apara/run_tests.py --sitar         # on the timing model (also checks cycles)
python3 validation/apara/run_tests.py validation/apara/timing --sitar
python3 validation/apara/run_tests.py --reference --mcode-run <path to mcode_run>
```

The runner assembles each test, writes its files into
`validation/apara/build/<test>/`, runs it, and prints `PASS`/`FAIL`.
`--reference` also replays every test without a `deviation` line on the
APARA reference simulator: ours writes its final state (PC, all
registers, all of DMEM that is or was non-zero) as a results file, and
the reference must reach exactly that state. This checks our model and
the test's expectations at once.
