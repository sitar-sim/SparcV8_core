# compiler/

Prebuilt SPARC v8 cross-tools used to turn assembly (and, later, C) test
programs into a memory image loadable by the model (see `model/MemCore`).

## What's here

`sparc-elf-toolchain-i386.zip` contains three binaries, built for the
bare-metal `sparc-elf` target:

- `sparc-elf-as`      — assembler (supports `-Av8` for SPARC V8)
- `sparc-elf-ld`      — linker
- `sparc-elf-readelf` — used to dump a linked ELF's sections as hex, in the
  `<address> <word> <word> <word> <word>` format `MemCore::initializeMemory()`
  expects

These are **GNU Binutils 2.20.1** (`GNU assembler (GNU Binutils) 2.20.1.20100303`),
stripped of debug symbols to keep the archive small (~850KB zipped). No
compiler (`gcc`/`cc1`) is bundled — only what's needed to assemble, link, and
read back a memory image. Binutils is licensed under the GPL; source for this
exact version is available from
<https://ftp.gnu.org/gnu/binutils/binutils-2.20.1.tar.gz> (or any GNU mirror).

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

If the bundled binaries don't work on your platform, a full SPARC V8
cross-compiler (including `gcc`, needed later for C-level tests) can be built
with Buildroot:

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
