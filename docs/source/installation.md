# Installation

## Prerequisites

This is all you need to build both models and run the bundled example
program (see step 2 below).

| Tool | Purpose |
|---|---|
| Linux, x86_64 | Development platform |
| g++ (C++11) | Compiling the C++ model |
| Python 3 | Build scripts |

`libquadmath`, needed for quad-precision floating point, is not listed
separately. It ships with a standard `gcc`/`g++` install on most Linux
distributions, so no separate install step is usually needed.

Three more tools are needed, but only for optional later steps: the
[Sitar](https://sitar-sim.github.io/sitar/) CLI (step 3, for the
cycle-timed model), the `sparc-elf` cross-toolchain (step 4, for writing
and compiling your own test programs), and MkDocs (step 5, for editing
this documentation).

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

```sh
model/cpp_model/build.sh
```

This builds `sparc_cpp_sim` (run a memory image, print final state) and
`check_test` (run a memory image, compare against expected results), both
inside `model/cpp_model/`.

A minimal example program, `test/test_simple_ADD.s`, is committed alongside
them, along with its already-assembled memory image. It adds two numbers
and puts the result in a register, then halts. View it first:

```sh
cat model/cpp_model/test/test_simple_ADD.s
```

Then run it:

```sh
model/cpp_model/sparc_cpp_sim model/cpp_model/test/test_simple_ADD.hex
```

```
PROCESSOR STATE: ERROR
...
 Out:
 o0 c
 ...
Simulation halted (error_mode) after 9 cycles.
```

This prints every register's final value once the program halts. `o0` is
`0xc` (12), the sum of the two numbers the program added. `sparc_cpp_sim`
always prints this final state. It has no separate logging mode. For an
instruction-by-instruction trace instead, see the Sitar-timed model below.

---

## 3. (Optional) Install Sitar, and build the timing model

Only needed if you want the cycle-timed Sitar model, not just the plain
C++ one. Follow Sitar's own
[installation instructions](https://sitar-sim.github.io/sitar/getting_started.html)
first, to build the `sitar` CLI and put it on your `PATH`.

Build with logging enabled, so a first, simple log is produced:

```sh
model/sitar_model/build.py --logging
```

This builds `sitar_check_test` inside `model/sitar_model/executable/`.
Run the same example program as above:

```sh
model/sitar_model/executable/sitar_check_test \
    model/sitar_model/executable/test_simple_ADD.hex \
    model/sitar_model/executable/test_simple_ADD.expected
```

```
(0,0)TOP.core.sparcThread:[t=(0,0)] Fetched Instruction: WRPSR; Instruction word: 0x81880000
(1,0)TOP.core.sparcThread:[t=(1,0)] Fetched Instruction: NOP; Instruction word: 0x1000000
...
PASS: o0 = 0xc
OVERALL: PASS (1 checks)
```

Each `Fetched Instruction` line is one instruction being executed, with the
memory reference and state update it causes logged around it, so you can
follow the program's execution one instruction at a time.

### Running larger programs

Full per-cycle logging like this gets noisy and slow for anything bigger
than the tiny example above. Build without `--logging` (the default) for
everyday use:

```sh
model/sitar_model/build.py
```

If you still need to look inside a specific part of a longer run, two
options:

- Enable Sitar's logging surgically, for a specific time window or
  condition instead of the whole run, using `log.turnOFF()`/`log.turnON()`
  in the model source. See Sitar's own
  [Logging](https://sitar-sim.github.io/sitar/3_language_and_examples/logging.html)
  documentation for the full mechanism.
- Run the simulation under host `gdb` instead, setting breakpoints and
  examining the simulated core's registers and memory directly. See
  [Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md).

---

## 4. (Optional) Install the SPARC V8 cross-toolchain

Only needed if you want to write and compile your own test programs,
rather than just running the bundled example and the existing validation
suite. A prebuilt **32-bit x86 (i386)** assembler and linker is bundled:

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
    Use a Linux x86_64 VM instead, or see `compiler/README.md` for building
    your own cross-toolchain with Buildroot. That's also what you need if
    you want a `gcc` for compiling C programs. See
    [Writing and Running C Programs](writing_and_running_c_programs.md).

---

## 5. (Optional) Install MkDocs

Only needed if you want to edit and rebuild this documentation. See
`docs/README.md` for the detailed setup and build instructions.

---

Once you've built at least the plain C++ model (step 2), continue to
[Getting Started](getting_started.md).
