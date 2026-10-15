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
formats](assembly_and_tools.md#file-formats). The options are those of
the APARA reference simulator, `mcode_run`, plus this project's own, so
the same files run on both.

The exit status is 0 for `PASS`, or, without `-r`, when every thread
stopped with `$halt`. It is 1 otherwise (a mismatch, an exception, or a
thread still running at the limit), and 2 for an error in the command
line or the files. That makes the simulators easy to use from scripts.

### Watching a program run

`--trace` prints one line per bundle executed: its thread and address,
its instructions (without the `$null`s), and, if it did not continue to
the next bundle, where it went. For example, the end of a loop, from
`validation/apara/tests/control.mcode`:

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

`validation/apara/` holds the engine's own test suite, in two folders:

- **`tests/`**  
    Functional tests: one per instruction class, plus multithreading,
    bundle semantics, and the [deviations](deviations.md) from the
    reference model.
- **`timing/`**  
    Microbenchmarks for the timing model, each with a cycle count derived
    by hand from the [timing rules](timing_model.md#timing-rules).

### A test

Each test is a single mcode file. Lines starting with `//@` say how to
run it and what to expect. For example, the timing test
`timing/t3_latency.mcode`:

```mcode
--8<-- "validation/apara/timing/t3_latency.mcode"
```

Its header explains where the expected count comes from. A functional
test instead sets registers and data with `reg:` and `data:` lines, and
lists the expected results with `expect:` lines.

| Line | Meaning |
|---|---|
| `//@ threads: 0x0 0x20` | Start threads at these PCs. Default: one thread at 0x0. |
| `//@ data: 10: 0x...` | An initial DMEM dword, in data-file format. |
| `//@ reg: 0 $r3 0x10` | An initial register value: thread, register, value. |
| `//@ expect: 0 reg $r5 0x7` | An expected result, in results-file format (registers written as `$rN`). |
| `//@ cycles: 12` | The exact cycle count the timing model must take, with the default timing settings. |
| `//@ deviation: <why>` | The test depends on a deviation from the reference model. |

### Running the tests

```bash
python3 validation/apara/run_tests.py                 # every test, on the cpp_model
python3 validation/apara/run_tests.py --sitar         # on the sitar_model, also checking cycle counts
python3 validation/apara/run_tests.py validation/apara/timing --sitar
python3 validation/apara/run_tests.py --reference --mcode-run <path to mcode_run>
```

The runner assembles each test, writes its files into
`validation/apara/build/<test>/`, runs it, and prints `PASS` or `FAIL`
for each, then a summary.

`--reference` also cross-checks the model against the APARA reference
simulator. For every test without a `deviation` line, the model writes
its final state (the PC, every register, and every DMEM word that is or
was non-zero) as a results file, and the reference simulator, given the
same program and inputs, must reach exactly that state. This checks the
model and the test's own expectations at the same time.

### Adding a test

Write a new `.mcode` file in `tests/` (or `timing/`, for a timing
microbenchmark), with its `//@` lines, and run the suite. There is
nothing to register: the runner finds every `.mcode` file in the
folders it is given.
