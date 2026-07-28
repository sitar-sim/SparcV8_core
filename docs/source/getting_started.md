# Getting Started

This page assumes you've completed [Installation](installation.md). It
walks through the whole toolchain hands-on: a simple test program,
building both models, running the simulator against it, observing the
resulting trace in the log viewer, and running the full validation
suite.

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

To run the cpp model along with a specific memory file (hex), 
from the repo root:

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
sparc_sim_cpp <hex_file> [expected_file] [max_cycles]
```

- **A hex file** (required)  
    The memory image to run.
- **An expected-results file** (optional)  
    A file with a specific format containing the expected results (register values) 
    at the end of simulation.  If given, after completion of the simulation, the final processor state  
    is compared against this file and the executable returns a `PASS`/`FAIL` verdict instead of 
    printing the detailed state.

- **A cycle limit** (optional)  
    Caps how long the simulator runs before giving up, in case the
    program never halts (a bug, or a genuine infinite loop). It defaults to 1000000. 
    Pass a smaller number to fail fast on a quick test, or a
    larger one for a program that legitimately needs more cycles than
    that to finish.

For example:

```sh
./sparc_sim_cpp test/test_simple_ADD.hex test/test_simple_ADD.expected 1000
```

---

## Observing the simulation log

When built with `--logging`, a simulation run also produces a `.log` file
into the current directory, containing a detailed simulation trace showing the 
processor state at the end of each instruction cycle.


The log file is a tab-separated text file and can be viewed with a normal editor. 
A visual (html) log viewer is provided to view the trace and processor state in a more intuitive manner.
Try it here: **[log viewer, preloaded with this same
example](log_viewer/viewer.html?trace=test_simple_ADD.log)**.

To view any log file, yuo can also open `log_viewer/viewer.html` in a browser, 
and then click **Load trace** and pick the log file and **Load objdump** to pick the matching disassembly file.

Step through the trace row by row (arrow keys) and watch the processor
evolve:

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

---

## Running a validation suite

Using the same expected-results format, without logging (faster and
quieter), the same executables can be run against a large number of test
program/expected-result pairs at once, as a validation suite. A large
validation suite, several hundred assembly tests plus a handful of C
ones, is available in `validation/`.

From the repo root, rebuild without `--logging`:

```sh
model/cpp_model/build.sh
model/sitar_model/build.py
```

Then run it, by passing a folder containing the tests as an argument. Example:

```sh
validation/run_tests.py validation/asm/misc/
```

```
[PASS] validation/asm/misc/save_restore/SAVE.vprj
[PASS] validation/asm/misc/stbar_unimp_nop_sethi/STBAR_UNIMP_NOP_SETHI.vprj

<passed>/<total> tests passed
```

`validation/run_tests.py` has the following options:

```sh
validation/run_tests.py <folder> [--sitar] [-v]
```

- **`folder`**  
    Navigate this subfolder recursively and run all tests inside it.
- **`--sitar`**  
    Run the identical suite against the Sitar-timed model instead of the
    plain C++ one (the default).
- **`-v`**  
    Show every check's result, not just failures.

---

## What's next

Write your own test program: [Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
or [Writing and Running C Programs](writing_and_running_c_programs.md).
