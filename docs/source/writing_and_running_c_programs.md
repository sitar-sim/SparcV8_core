# Writing and Running C Programs

!!! note "Status"
    `validation/C/` (bare-metal C test programs, e.g. matrix multiply,
    compound data types -- sequences of operations rather than one opcode
    at a time) is planned but not yet populated. This page documents the
    intended approach and current toolchain status, so it's usable as a
    guide once those tests are written, and as a starting point for
    writing your own C program against the model in the meantime.

---

## No standard library, by design

This model has **no MMU, no cache, no peripheral/device model, and no
operating system** (see [What this project offers](index.md#what-this-project-offers))
-- there is nothing for a C standard library to call into. `printf` has no
console to write to; `malloc` has no OS to request pages from. C programs
for this model must be **freestanding**: no `#!c #include <stdio.h>`, no
libc at all, just the C language itself plus whatever you implement by
hand against the flat memory space `MemCore` provides.

This is the same reason `model/cpp_model/main.cpp`'s driver doesn't try to
model a console -- there's genuinely nothing on the other end of one yet.

---

## Toolchain status

The bundled `sparc-elf` toolchain (see [Installation](installation.md))
only contains an assembler, linker, and `readelf` -- **no C compiler**.
Building one is a one-time setup step, using
[Buildroot](http://buildroot.uclibc.org/download.html):

```sh
# download and extract Buildroot, then:
make qemu_sparc_ss10_defconfig && make menuconfig
# under "Toolchain", enable "Build cross gdb for the host" if you want gdb too
make      # downloads and builds everything -- takes a while
```

The resulting tools (`sparc-linux-gcc`, `sparc-linux-as`, ...) end up in
`<buildroot>/output/host/usr/bin` -- add that to your `PATH`. See
`compiler/README.md` for the full note, including a link to the original
writeup this is based on.

---

## Compiling freestanding

Compile with the flags that tell `gcc` there's no OS or libc underneath:

```sh
sparc-linux-gcc -Av8 -ffreestanding -nostdlib -nostartfiles \
    -O2 -c your_program.c -o your_program.o
```

Link against the same `compiler/sparc.ld` script the assembly tests use,
which places `.text` at address `0x0` (matching the SPARC V8 reset
convention, PC=0 after reset) and sets the entry point to `main`:

```sh
sparc-linux-ld -T compiler/sparc.ld your_program.o -o your_program.elf
```

Then dump to a `.hex` memory image the same way `compiler/assemble.sh`
does for assembly tests (`readelf --hex-dump` piped through
`compiler/hexdump_to_memimage.py`) -- see that script for the exact
invocation, or adapt it directly since it's a small, generic pipeline
independent of whether the input was assembled from `.s` or compiled from
`.c`.

---

## Structuring a test program

Since `sparc.ld` sets `ENTRY(main)` directly (no C runtime startup code,
no `argc`/`argv`, nothing to return into), your C `main()` *is* the
program's entry point, and it must never return. The simplest way to end
a test cleanly is the same mechanism the assembly tests use: execute a
trap while traps are disabled (`ET=0`, the state every program starts in
after reset), which the model recognizes as a deliberate halt (see
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#the-pass-fail-convention)).
From C, that's a single line of inline assembly at the end of `main`:

```c
void main(void)
{
    /* ... your test's actual computation ... */

    __asm__ volatile ("ta 0");   /* deliberate halt -- see link above */
    while (1) {}                 /* never reached; satisfies -Wreturn-type */
}
```

Unlike the assembly tests, a C test generally doesn't need the full
256-entry trap table boilerplate at all -- it isn't exercising trap
behavior, just a sequence of ordinary instructions, so leaving traps
disabled for the whole run (the reset default) and using the single `ta 0`
above to signal completion is enough.

Checking results works the same way as the assembly tests: write results
to fixed, known memory addresses or registers, and check them via a
`.vprj` file the same [`REG`/`MEM` format](writing_and_running_assembly_programs.md#the-vprj-expected-results-file)
already used throughout `validation/asm/`.
