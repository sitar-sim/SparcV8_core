# Installation

## Prerequisites

In the following table, steps up to 2 are the minimal requirements for
building the C++ model and running it. Everything past that is optional,
needed only for the step listed.

| Step | Tool | Purpose |
|---|---|---|
| 2 | Linux, x86_64 | Development platform |
| 2 | g++ (C++11) | Compiling the C++ model |
| 2 | Python 3 | Build scripts |
| 2 | `libquadmath` | Quad-precision floating point support. Ships with a standard `gcc`/`g++` install on most Linux distributions, so no separate install step is usually needed. |
| 3 | [Sitar](https://sitar-sim.github.io/sitar/) CLI | Building and running the cycle-timed Sitar model |
| 5 | [gdb](https://en.wikipedia.org/wiki/GNU_Debugger) | Examining a running model's state directly, see [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md) |
| 6 | `sparc-elf` cross-toolchain | Writing and compiling your own test programs. A prebuilt release is bundled, only build your own if it doesn't suit your host, see [Cross Compiler](cross_compiler.md). |
| 7 | MkDocs | Editing and rebuilding this documentation |

---

## 1. Clone the repository

```sh
git clone https://github.com/sitar-sim/SparcV8_core.git
cd SparcV8_core
```

---

## 2. Build and run the plain C++ model

No further dependencies are needed. This model has no Sitar dependency at
all.

From the repo root:

```sh
cd model/cpp_model
./build.sh --logging
```

This builds an executable, `sparc_sim_cpp`.

Let's try it. The executable expects the name of a test program compiled
to a memory image (a `.hex` file). A minimal example program,
`test/test_simple_ADD.s`, is present in the same directory in the repo
for a quick test of the model, along with its already-assembled memory
image. It adds two numbers and puts the result in a register, then
halts. View it first:

```sh
cat test/test_simple_ADD.s
```

Then run it:

```sh
./sparc_sim_cpp test/test_simple_ADD.hex
```

The run generates an output:

```
PROCESSOR STATE: ERROR
PSR.impl 0b0000
...
PC  0x1c
nPC 0x20
...
o0 0xc
...
Simulation halted after 9 cycles.
```

This prints every register's final value once the program halts. `o0` is
`0xc` (12), the sum of the two numbers the program added. Here, "9
cycles" just means 9 complete instructions executed. This is a plain
functional model with no timing.

When built with the `--logging` option (the default is without it, for
faster runs), a simulation run also generates a detailed text log of
every event, in `test_simple_ADD.log` (a trace file is always named
after the hex file it ran, see [Logging](logging.md#the-current-scheme)).
Although it's a plain text file, it can be viewed inside a trace viewer
to step through the execution and
watch the processor state evolve. Try it here: **[log viewer, preloaded
with this same example](log_viewer/viewer.html?trace=test_simple_ADD.log)**.
See [Getting Started](getting_started.md) for a full walkthrough,
including what each part of the trace means.

---

## 3. (Optional) Install Sitar, and build the timing model

Only needed if you want the cycle-timed Sitar model, not just the plain
C++ one. Follow Sitar's own
[installation instructions](https://sitar-sim.github.io/sitar/getting_started.html)
first, to build the `sitar` CLI and put it on your `PATH`. Check it's
correctly installed, from any location:

```sh
sitar -h
```

From the repo root:

```sh
cd model/sitar_model
./build.py --logging
```

This builds an executable, `sparc_sim_sitar`, inside `executable/`.

```sh
cd executable/
./sparc_sim_sitar test_simple_ADD.hex
```

The run generates an output, the same shape as step 2 above:

```
PROCESSOR STATE: ERROR
PSR.impl 0b0000
...
PC  0x1c
nPC 0x20
...
o0 0xc
...
Simulation halted after 8 cycles.
```

As in step 2, this also writes `test_simple_ADD.log` (viewable in the
same [log viewer](logging.md#the-log-viewer)), plus a second file,
`sitar.log` (Sitar's own lower-level per-request/response messages).

---

## 4. (Optional) Running validation tests

Only needed if you want to check the model's correctness against the
full validation suite, rather than just the one bundled example above.

From the repo root, rebuild both models without `--logging`, for faster
runs:

```sh
model/cpp_model/build.sh
model/sitar_model/build.py
```

### Running one test directly

The model executables' full command line is `<hex_file> [expected_file]
[max_cycles]`. Passing `expected_file` makes the executable check the
final state and report a pass/fail instead of just printing it.
`max_cycles` caps how long it runs before giving up. Try it on one of the
validation suite's own tests:

```sh
model/cpp_model/sparc_sim_cpp \
    validation/asm/integer_alu/Arithmetic/Add/ADD.hex \
    validation/asm/integer_alu/Arithmetic/Add/ADD.expected \
    1000
```

```
PASS: g1 = 0x80
PASS: o0 = 0x5
PASS: o1 = 0xe0
PASS: o2 = 0xfffffffb
PASS: o3 = 0xe0
PASS: o4 = 0x1
PASS: o5 = 0xe0
PASS: o6 = 0xffffffff
PASS: o7 = 0xe0
PASS: i0 = 0xfffffffe
PASS: i1 = 0xe0
PASS: i2 = 0x2
PASS: i3 = 0xe0
OVERALL: PASS (13 checks)
```

### Running the validation suite

`validation/run_tests.py` drives this same check over every test under a
folder. Point it at a small subfolder first, to keep this quick:

```sh
validation/run_tests.py validation/asm/integer_alu/Arithmetic/Add
```

```
[PASS] validation/asm/integer_alu/Arithmetic/Add/ADD.vprj
[PASS] validation/asm/integer_alu/Arithmetic/Add/ADDX.vprj
[PASS] validation/asm/integer_alu/Arithmetic/Add/ADDXcc.vprj
[PASS] validation/asm/integer_alu/Arithmetic/Add/ADDcc.vprj

4/4 tests passed
```

See [Validation Suite](validation_suite.md) for the full suite, `--sitar`
to run it against the Sitar-timed model instead, and every other option.

---

## 5. (Optional) Install gdb

[gdb](https://en.wikipedia.org/wiki/GNU_Debugger) is the standard GNU
command-line debugger for compiled programs.

Only needed if you want to examine a running model's state directly with
gdb, instead of (or alongside) logging. This is your host's own `gdb`,
attaching directly to the model's own process. No cross-debugger is
needed.

```sh
sudo apt install gdb
```

See [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md)
for how to build with debug symbols and use it.

---

## 6. (Optional) Install the SPARC V8 cross-toolchain

Only needed if you want to write and compile your own test programs,
rather than just running the bundled example and the existing validation
suite. A prebuilt **32-bit x86 (i386)** assembler and linker is bundled,
which will work for most host setups.

From the repo root:

```sh
compiler/install_toolchain.sh          # unzips into compiler/toolchain/
source compiler/toolchain_env.sh       # adds it to PATH, this shell session
```

Add `source /path/to/compiler/toolchain_env.sh` to your shell rc file to
make this permanent.

!!! note "64-bit hosts"
    The bundled binaries are 32-bit (i386). On a 64-bit host you may need
    i386 compatibility libraries. On Debian/Ubuntu, run
    `sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install libc6-i386 zlib1g:i386`.
    They won't run natively on non-x86 hosts, such as Apple Silicon Macs.
    Use a Linux x86_64 VM instead, or see [Cross Compiler](cross_compiler.md)
    for building your own cross-toolchain with Buildroot.

---

## 7. (Optional) Install MkDocs

Only needed if you want to edit and rebuild this documentation. See
`docs/README.md` for the detailed setup and build instructions.

---

Once you've built at least the plain C++ model (step 2), continue to
[Getting Started](getting_started.md).
