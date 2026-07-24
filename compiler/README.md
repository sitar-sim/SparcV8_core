# compiler/

Prebuilt SPARC v8 cross-tools, plus the scripts (`assemble.sh`,
`compile_c.sh`) that drive them, used to turn assembly and C test programs
into a memory image loadable by the model (see `model/MemCore`).

## What's here

`sparc-elf-toolchain-i386.zip` contains, built for the bare-metal
`sparc-elf` target:

- `bin/sparc-elf-as`      — assembler (supports `-Av8` for SPARC V8)
- `bin/sparc-elf-ld`      — linker
- `bin/sparc-elf-readelf` — used to dump a linked ELF's sections as hex, in the
  `<address> <word> <word> <word> <word>` format `MemCore::initializeMemory()`
  expects
- `bin/sparc-elf-objdump` — disassembles a `.o`/`.elf` back to readable
  assembly, useful for checking what an assembler or compiler actually
  generated
- `bin/sparc-elf-gcc`, `libexec/gcc/sparc-elf/4.4.3/cc1`,
  `lib/gcc/sparc-elf/4.4.3/include/` — a minimal, freestanding C compiler
  (GCC 4.4.3, `--with-newlib --without-headers`), just enough to build the
  bare-metal C tests under `validation/C/`. See `compile_c.sh` and
  `crt0.s` below for how it's actually used, and "Building your own
  toolchain" below for a different, better-supported path if you want to
  write more serious C programs of your own.

`sparc-elf-as`/`-ld`/`-readelf`/`-objdump` are **GNU Binutils 2.20.1**
(`GNU assembler (GNU Binutils) 2.20.1.20100303`), stripped of debug symbols
to keep the archive small (~15MB zipped, `cc1` dominates that). Binutils is
licensed under the GPL; source for this exact version is available from
<https://ftp.gnu.org/gnu/binutils/binutils-2.20.1.tar.gz> (or any GNU
mirror). GCC is licensed under the GPL too; source for 4.4.3 is at
<https://ftp.gnu.org/gnu/gcc/gcc-4.4.3/> (or any GNU mirror). See `AUTHORS`
for where this exact prebuilt toolchain comes from.

## `crt0.s` and `compile_c.sh`

`sparc-elf-gcc`'s own internal calls to `as`/`ld` (e.g. for a plain `-c` or
a full link) resolve to the host's native x86 assembler/linker rather than
the bundled `sparc-elf` ones. So `compile_c.sh <input.c>` never lets `gcc`
assemble or link at all: it compiles to assembly text only (`-S`), then
assembles and links with `sparc-elf-as`/`sparc-elf-ld` directly, the same
tools `assemble.sh` uses for `.s` sources. See the comment at the top of
`compile_c.sh` for the full sequence, and `crt0.s` (linked ahead of every C
test's own object, entry point overridden to its `_start`) for how a C
test's `main()` gets a working stack, enabled traps, and the same 256-entry
trap table and pass/fail halt convention every `validation/asm/` test uses
by hand.

## Platform support

These are **32-bit x86 (i386) Linux binaries**. They run fine on a 64-bit
x86_64 Linux host as long as i386 compatibility libraries are installed
(`libc6-i386` and `zlib1g:i386` on Debian/Ubuntu — install with
`sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install libc6-i386 zlib1g:i386`
if `sparc-elf-as --version` fails with a loader/library error).

They will **not** run natively on non-x86 hosts (e.g. Apple Silicon Macs) or
on Windows. Use a Linux x86_64 VM in that case.

If you'd rather build a native cross-compiler for your own platform instead
of using these prebuilt binaries, see "Building your own toolchain" below.

## Install

```
./install_toolchain.sh          # unzip into compiler/toolchain/
source toolchain_env.sh         # add compiler/toolchain/bin to PATH (this shell session)
```

Add `source /path/to/compiler/toolchain_env.sh` to your shell rc file to make
it permanent. `compiler/toolchain/` (the unzipped binaries) is gitignored —
only the zip is tracked.

## Building your own toolchain (optional)

The bundled `sparc-elf-gcc` above exists for one narrow purpose: building
this repo's own `validation/C/` tests, with no setup required. It's old
(GCC 4.4.3, from 2010), 32-bit-x86-only, and freestanding-only (no C
library at all). If you want to write and compile more serious C programs
of your own against this model, rather than just regenerate the bundled
test suite, build a proper, modern, actively-supported cross-compiler
instead, with Buildroot:

1. Download Buildroot from <http://buildroot.uclibc.org/download.html> and extract it.
2. `make qemu_sparc_ss10_defconfig && make menuconfig`
3. In menuconfig, under "Toolchain", enable "Build cross gdb for the host" if you want `gdb` too.
4. `make` (downloads and builds everything — takes a while).
5. Resulting tools (`sparc-linux-gcc`, `sparc-linux-as`, `sparc-linux-gdb`, ...)
   are in `<buildroot>/output/host/usr/bin` — add that to your `PATH`.

(`sudo apt-get install qemu-user` if you also want to run the resulting
SPARC binaries directly under Linux user-mode QEMU, e.g. for cross-checking
against real hardware/QEMU behavior — not required for this project's own
test harness.)

See <https://nehakaranjkar.github.io/SparcQemu.html> for the original writeup
this is based on.
