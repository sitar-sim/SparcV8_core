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

This is the same reason `model/cpp_model/sparc_sim.cpp`'s driver doesn't
try to model a console. There's genuinely nothing on the other end of
one yet.

---

## Toolchain

A minimal, freestanding C compiler (GCC 4.4.3) is bundled alongside the
existing `sparc-elf` assembler, linker, `readelf`, and `objdump`. See
[Cross Compiler](cross_compiler.md) for what's bundled and why, and for
building your own, more modern cross-toolchain instead.

```sh
compiler/compile_c.sh your_program.c
```

This produces `your_program.hex`, the same kind of memory image
`compiler/assemble.sh` produces for assembly tests, loadable the same way
by `MemCore::initializeMemory()`. It also produces `your_program.objdump`:
a readable disassembly of the linked program (useful for seeing what the
compiler actually generated, unlike a hand-written `.s` file, this isn't
something you wrote directly), followed by the full symbol table,
function and global-variable addresses included. See
[Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md#finding-addresses).

Run it directly against the model the same way as an assembly test, see
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#building-and-running-it):

```sh
model/cpp_model/sparc_sim_cpp your_program.hex
```

---

## Structuring a test program

Write an ordinary, freestanding C `main()`. Every test in
`validation/C/` follows the same self-validating shape: compute
something, compare it against a golden value computed once on the host
machine and hardcoded right there in the source, and report pass(1)/
fail(0) in `%o0`:

```c
int main(void)
{
    int computed;
    int expected;
    int pass;

    // ... your test's actual computation, into `computed` ...

    expected = 42; // computed on the host, see the comment near it
    pass = (computed == expected) ? 1 : 0;

    // Report pass(1)/fail(0) in %o0.
    __asm__ volatile ("mov %0, %%o0" : : "r" (pass));

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

Checking the result is then a single line. The `.vprj` only ever has to
check that `%o0` is `1`:

```
SOURCES = your_test.c

RESULTS =
o0=1
```

The alternative, writing a raw computed value to a global and checking it
directly via a `.vprj` `MEM` line (the address found in
`your_program.objdump`'s symbol table, or `readelf -s your_program.elf`
directly), still works. It's the same [`REG`/`MEM`
format](validation_suite.md#the-vprj-expected-results-format)
`validation/asm/` uses, but means the golden value is embedded in two
places (the `.vprj` and, if the test computes its own pass/fail, the
source) instead of one. Doing the comparison in C and reporting a single
pass/fail flag avoids that, and doubles as a self-contained mini-benchmark
that also happens to check itself. See `array_sum/array_sum.c` and the
rest of `validation/C/` for worked examples across several small
algorithms.

---

## Running the tests

Same two-phase pipeline as `validation/asm/`, see
[Validation Suite](validation_suite.md#the-validation-script). `build_hex.py`
picks `compiler/assemble.sh` or `compiler/compile_c.sh` automatically,
based on whether a test's `SOURCES` line names a `.s` or a `.c` file.
