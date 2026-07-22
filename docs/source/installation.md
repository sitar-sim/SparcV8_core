# Installation

## Prerequisites

| Tool | Purpose | Needed for |
|---|---|---|
| Linux, x86_64 | Development platform | Everything below |
| g++ (C++11) | Compiling the C++ model | Both models |
| `libquadmath` | Quad-precision floating point | Both models |
| `sparc-elf` toolchain (assembler/linker) | Assembling `.s` test programs | Running/writing tests |
| Python 3 | Build/test scripts | Everything below |
| [Sitar](https://sitar-sim.github.io/sitar/) CLI | Translating/compiling the timing model | Sitar model only |

`libquadmath` ships with a standard `gcc`/`g++` install on most Linux
distributions. No separate install step is usually needed.

---

## 1. Clone the repository

```sh
git clone https://github.com/sitar-sim/SparcV8_core.git
cd SparcV8_core
```

---

## 2. Install the SPARC V8 cross-toolchain

Needed to assemble `.s` test programs into memory images the model can
load (`compiler/`). A prebuilt **32-bit x86 (i386)** assembler/linker is
bundled:

```sh
compiler/install_toolchain.sh          # unzips into compiler/toolchain/
source compiler/toolchain_env.sh       # adds it to PATH, this shell session
```

Add `source /path/to/compiler/toolchain_env.sh` to your shell rc file to
make this permanent.

!!! note "64-bit hosts"
    The bundled binaries are 32-bit (i386). On a 64-bit host you may need
    i386 compatibility libraries: on Debian/Ubuntu,
    `sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install libc6-i386 zlib1g:i386`.
    They won't run natively on non-x86 hosts (e.g. Apple Silicon). Use a
    Linux x86_64 VM, or see `compiler/README.md` for building your own
    cross-toolchain with Buildroot. That's also what you need if you want
    a `gcc` for compiling C programs. See
    [Writing and Running C Programs](writing_and_running_c_programs.md).

---

## 3. Build the plain C++ model

No further dependencies are needed. This model has no Sitar dependency at all.

```sh
model/cpp_model/build.sh
```

Builds `sparc_cpp_sim` (run a memory image, print final state) and
`check_test` (run a memory image, compare against expected results) inside
`model/cpp_model/`.

---

## 4. (Optional) Install Sitar, and build the timing model

Only needed if you want the cycle-timed Sitar model, not just the plain
C++ one. Follow Sitar's own
[installation instructions](https://sitar-sim.github.io/sitar/getting_started.html)
to build the `sitar` CLI and put it on your `PATH`, then:

```sh
model/sitar_model/build.py
```

Builds `sitar_check_test` inside `model/sitar_model/executable/`.

---

## 5. Verify: run the validation suite

```sh
validation/run_tests.py validation/asm              # against the plain C++ model
validation/run_tests.py validation/asm --sitar       # against the Sitar-timed model (needs step 4)
```

Both should report every test passing. See
[Getting Started](getting_started.md) for a walkthrough of what these
scripts are doing, and how to run a single test by hand.
