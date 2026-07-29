# Getting Started

This page assumes you've completed [Installation](installation.md). It
walks through the whole toolchain hands-on: a simple test program,
building both models, running the simulator against it, observing the
resulting trace in the log viewer, running the full validation suite,
and debugging with gdb.

## SPARC V8

SPARC V8 is the 32-bit RISC instruction set architecture this project
models, standardized as ANSI/IEEE Std 1754-1994. See [SPARC V8
Architecture](sparcv8_architecture.md) for what makes it distinctive and
a page-indexed guide to the authoritative manual, bundled in this
repository.

---

## A simple program

Let's consider a simple assembly-level program: put two numbers in
registers, and add them. It's already present at
`model/cpp_model/test/test_simple_ADD.s`:

```sparc
--8<-- "validation/test_simple_ADD/test_simple_ADD.s"
```

The first step after writing a program like this is to convert it into
machine code and load it into the simulated processor's memory. A memory
image is already present too, at `test/test_simple_ADD.hex`, along with
its disassembly at `test/test_simple_ADD.objdump` (both paths relative
to `model/cpp_model/`). We'll point the simulator straight at the `.hex`
file.

Later, to modify this test or write your own, you'll need to compile it
into a memory image (`.hex`) yourself. See
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
or [Writing and Running C Programs](writing_and_running_c_programs.md).

---

## Building the SPARC models

From the repo root, build the plain C++ model:

```sh
cd model/cpp_model
./build.sh --logging
```

And the Sitar-timed model, the same way. From the repo root:

```sh
cd model/sitar_model
./build.py --logging
```

We're building with `--logging` here (off by default), so this run also
produces an instruction trace. In comparison to the C++ model, the Sitar
model drives the exact same core through
[Sitar](https://sitar-sim.github.io/sitar/) instead of the plain
functional loop, adding real per-opcode, interconnect, and memory timing.

Both build scripts take the same options:

- **`--logging` / `--no-logging`** (default: off)  
    Whether the model writes an instruction trace when run, see
    "Observing the simulation log" below.
- **`--debug` / `--debug-o0` / `--no-debug`** (default: off)  
    Whether to build with debug symbols, for examining a running model
    with gdb, see [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md).

---

## Running the simulator

To run the C++ model against a memory image, from the repo root:

```sh
cd model/cpp_model
./sparc_sim_cpp test/test_simple_ADD.hex
```

Similarly, for the Sitar-timed model, from the repo root:

```sh
cd model/sitar_model/executable
./sparc_sim_sitar test_simple_ADD.hex
```

The simulation executable expects the following arguments:

```
sparc_sim_cpp <hex_file> [expected_results_file] [max_cycles]
```

- **A hex file** (required)  
    The memory image to run.
- **An expected-results file** (optional)  
    A file listing the expected final register values, see
    [Format for the expected-results file](writing_and_running_assembly_programs.md#format-for-the-expected-results-file)
    for its format. If given, once the program halts, the final
    processor state is checked against it and the executable prints a
    PASS/FAIL verdict per check plus an OVERALL result, instead of the
    detailed state.
- **A cycle limit** (optional)  
    Caps how long the simulator runs before giving up, in case the
    program never halts (a bug, or a genuine infinite loop). Defaults to
    1000000. Pass a smaller number to fail fast on a quick test, or a
    larger one for a program that legitimately needs more cycles than
    that to finish.

For example, checking the same run against its expected-results file,
back in `model/cpp_model`:

```sh
./sparc_sim_cpp test/test_simple_ADD.hex test/test_simple_ADD.expected 1000
```

```
PASS: o0 = 0xc
PASS: l0 = 0x5
PASS: l1 = 0x7
OVERALL: PASS (3 checks)
```

---

## Observing the simulation log

When built with `--logging`, a simulation run also produces a `.log`
file in the current directory, containing a detailed simulation trace
showing the processor state at the end of each instruction cycle.

The generated log file has the same name as the `.hex` file, but with a
`.log` extension. Although it's a plain text file in tab-separated value
(tsv) format, and can be viewed in any editor, this project provides a
graphical trace visualizer to step through the execution and watch the
processor state evolve.

### Try the trace viewer here

**[log viewer, preloaded with the trace for the test_simple_ADD example](log_viewer/viewer.html?trace=test_simple_ADD.log)**.

<p align="center">
  <a href="log_viewer/viewer.html?trace=test_simple_ADD.log">
    <img src="images/trace_viewer.png" alt="Screenshot of the trace viewer" title="Screenshot of the trace viewer" width="700">
  </a>
</p>

The viewer allows the user to simultaneously view:

- the simulation event trace (`.log`)
- the assembly code being run (`.objdump`)
- and the processor state at the end of each traced event, showing the register values.

#### Using the viewer

- Clicking on a line in the trace automatically highlights the
  corresponding line in the disassembly and shows the processor state
  for that event. The `up` and `down` arrow keys can be used to step
  forwards and backwards through the execution trace.
- Register values that change at each step are highlighted.
- A search bar at the top lets you search for a specific PC or register
  value in the event trace and jump to it. The `Next` and `Prev` buttons
  step through multiple matches.

Each row in the generated log records a sequence number, time, PC, event
type, an event-specific detail, and the full processor state. The event
types are:

- **`RESET` then `TRAP_ENTER`**  
    At the very start of every run. The model always boots by taking an
    implicit reset trap into the first instruction. You didn't write
    this, it's automatic.
- **`FETCH` then `EXECUTED`, one pair per instruction**  
    `FETCH` shows the opcode about to run, with the current-window
    register state still as it was *before* this instruction. `EXECUTED`
    (the very next row, same PC) shows that state *after*, with whatever
    changed highlighted. Watch `%l0`/`%l1`/`%o0` fill in, on the
    `EXECUTED` row of each `mov`/`mov`/`add` pair, as the sequence runs.
- **`TRAP_RAISED` then `HALT`**  
    At the end. The final `ta 0` is executed with traps already disabled
    (that's what the `wr %g0, %psr` at the top did), so it has no
    handler to jump to. The processor forces itself into `error_mode`
    instead. This is this project's halt convention, used by every test
    program in the repository. It's what `sparc_sim_cpp`'s
    `PROCESSOR STATE: ERROR` and `Simulation halted after N cycles.`
    output means, and it's expected, not a bug.

To view a different log file, open `log_viewer/viewer.html` directly in
a browser, then click **Load trace** to pick the log file and
**Load objdump** to pick its matching disassembly file.

!!! note "Viewing memory state"
    The generated log and viewer don't currently track memory state,
    even though the trace may contain load/store event details.

    For examining or probing memory state during execution, see
    [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md).

---

## Running a validation suite

This project includes a large, well-curated suite of tests for
functional validation of the models. Each test is a small program
(assembly or C) paired with a description of its expected result. The
tests, and the scripts to run them, are included in `validation/`.

The suite contains:

- **Assembly tests**  
    The `asm/` folder contains several hundred assembly tests, organized
    into instruction-type clusters, each targeting one instruction (or a
    small family of closely related ones).
- **C tests**  
    The `C/` folder contains self-checking C programs, each computing
    some integer or floating-point operation and comparing the result
    against a known value.
- **A test runner**  
    `validation/run_tests.py` runs them all and reports a pass/fail
    summary.

It's worth running whenever you change the model itself, to check
nothing broke. Rebuild both models without `--logging` first. Some
tests run long, and logging isn't needed here:

```sh
model/cpp_model/build.sh
model/sitar_model/build.py
```

Then run `validation/run_tests.py`, pointing it at a folder of tests.
Example, a small subset first:

```sh
validation/run_tests.py validation/asm/misc/
```

```
[PASS] validation/asm/misc/save_restore/SAVE.vprj
[PASS] validation/asm/misc/stbar_unimp_nop_sethi/STBAR_UNIMP_NOP_SETHI.vprj

<passed>/<total> tests passed
```

Point it at `validation` itself to run the entire suite instead of one
folder:

```sh
validation/run_tests.py validation
```

The script runs the tests on the C++ model by default. To run it on the
Sitar model instead, pass the `--sitar` option. Add `-v` to show every
check's result, not just failures:

```sh
validation/run_tests.py validation --sitar -v
```

See [Validation Suite](validation_suite.md) for what's in a test and how to add a new test to the suite.

---

## Debugging

Logging suits a small test program well, but a long-running one can
produce a log file too large to comfortably read through. Even with
logging selectively turned on and off, the exact condition or bug you're
chasing can be hard to pin down or trace this way. This is where a
debugger becomes useful: it lets you surgically track a specific change,
or inspect state at a specific point or condition at runtime, without
printing large volumes of log output.

GNU's `gdb`, the standard debugger, is enough for this. Both models are,
underneath everything else, plain host C++ programs, so `gdb` attaches
to them directly, no cross-debugger or special protocol needed. Using it
well does still need some familiarity with the model's own source, to
know which variables hold the simulated architectural state.

Build with `--debug` first:

```sh
model/cpp_model/build.sh --debug
model/sitar_model/build.py --debug
```

To make this convenient, `debug/sparc.gdb` provides a large set of
shortcut commands. For example, setting a breakpoint at a specific PC, a
watchpoint on a memory location, or printing one register:

```
(gdb) sparc-break pc=0x203c
(gdb) sparc-watch-mem addr=0xfffffe0
(gdb) sparc-print-reg o0
```

See [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md)
for the full command reference and a complete walkthrough.

---

## What's next

Write your own test program: [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
or [Writing and Running C Programs](writing_and_running_c_programs.md).
