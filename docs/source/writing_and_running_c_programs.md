# Writing and Running C Programs

`validation/C/` holds bare-metal C test programs. These exercise a
sequence of C-level operations together (loops, arrays, structs, global
variables), rather than one instruction at a time the way `validation/asm/`
does. This page describes the format, how it gets built and run, and how
to write your own.

---

## No standard library, by design

This model has **no MMU, no cache, no peripheral/device model, and no
operating system** (see [Models](index.md#models)).
There is nothing for a C standard library to call into. `printf` has no
console to write to. `malloc` has no OS to request pages from. C programs
for this model must be **freestanding**: no `#!c #include <stdio.h>`, no
libc at all, just the C language itself plus whatever you implement by
hand against the flat memory space `MemCore` provides.

This is the same reason `model/cpp_model/main.cpp`'s driver doesn't try to
model a console. There's genuinely nothing on the other end of one yet.

---

## Toolchain

A minimal, freestanding C compiler (GCC 4.4.3) is bundled alongside the
existing `sparc-elf` assembler, linker, `readelf`, and `objdump` (see
[Installation](installation.md)). It exists for one narrow purpose:
building this project's own `validation/C/` tests, with no setup beyond
installing the bundled toolchain.

```sh
compiler/compile_c.sh your_program.c
```

This produces `your_program.hex`, the same kind of memory image
`compiler/assemble.sh` produces for assembly tests, loadable the same way
by `MemCore::initializeMemory()`. It also produces `your_program.objdump`,
a readable disassembly of the linked program, useful for seeing what the
compiler actually generated (unlike a hand-written `.s` file, this isn't
something you wrote directly).

See `compiler/README.md` for exactly what's bundled and why. If you want
to write more serious C programs of your own, rather than just work with
this project's own test suite, build a proper, modern, actively-supported
cross-compiler instead, with [Buildroot](http://buildroot.uclibc.org/download.html):

```sh
# download and extract Buildroot, then:
make qemu_sparc_ss10_defconfig && make menuconfig
# under "Toolchain", enable "Build cross gdb for the host" if you want gdb too
make      # downloads and builds everything, takes a while
```

The resulting tools (`sparc-linux-gcc`, `sparc-linux-as`, ...) end up in
`<buildroot>/output/host/usr/bin`. Add that to your `PATH`. See
`compiler/README.md` for the full note, including a link to the original
writeup this is based on.

---

## Structuring a test program

Write an ordinary, freestanding C `main()`:

```c
int result;

int main(void)
{
    // ... your test's actual computation ...
    result = 42;

    // Halt: traps are enabled (crt0.s), so this ta 0 is caught by its
    // trap-table slot, which re-traps with traps now disabled, forcing
    // the model into error_mode. See "The pass-fail convention" below.
    __asm__ volatile ("ta 0");

    // Never reached: ta 0 above always halts the simulation first. This
    // just satisfies the compiler, which otherwise warns that a
    // non-void main() falls off the end without returning a value.
    while (1) {}
    return 0;
}
```

`main()` must never return, since there's nothing to return into. The way
to end a test is the same mechanism `validation/asm/` tests use, described
in full in
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#the-pass-fail-convention):
a single line of inline assembly, `__asm__ volatile ("ta 0")`, at the end
of `main()`.

Unlike an assembly test, you don't write any of the surrounding setup by
hand. `compiler/crt0.s` is linked ahead of your compiled `.c` file (by
`compile_c.sh`, entry point overridden to `crt0.s`'s own `_start`) and does
it for you: enables traps, installs the same 256-entry trap table every
`validation/asm/` test installs, initializes `%g1` as the pass/fail
sentinel, sets up a working stack (needed for any C function using a local
variable, which `%sp` starting at `0` does not provide on its own), then
calls your `main()`. See `crt0.s` itself for the full explanation of each
step. The result is that a C test's `ta 0` halts exactly the same way an
assembly test's does, and an unexpected trap during your test is caught
the same way too.

Checking results works the same way as the assembly tests: write results
to fixed, known memory addresses (globals) or registers, and check them
via a `.vprj` file, the same [`REG`/`MEM` format](writing_and_running_assembly_programs.md#the-vprj-expected-results-file)
already used throughout `validation/asm/`. For a memory check, you need
the linked address of a global variable, found via `readelf -s
your_program.elf` (or the generated `.objdump`).

---

## Running the tests

Same two-phase pipeline as `validation/asm/`, see
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#running-it)
and `validation/README.md`. `build_hex.py` picks `compiler/assemble.sh` or
`compiler/compile_c.sh` automatically, based on whether a test's `SOURCES`
line names a `.s` or a `.c` file.
