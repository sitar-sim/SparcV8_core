# Cross Compiler

A prebuilt, 32-bit x86 (i386) `sparc-elf` cross-toolchain is bundled as a
release with this repository: an assembler (`sparc-elf-as`), a linker
(`sparc-elf-ld`), a minimal freestanding C compiler (`sparc-elf-gcc`,
GCC 4.4.3), `objdump`, and `readelf`. See
[Installation](installation.md) step 6 to install it.
`compiler/assemble.sh` and `compiler/compile_c.sh` drive it to build
this project's own test programs, see
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
and [Writing and Running C Programs](writing_and_running_c_programs.md).

It exists for one narrow purpose: building this project's own
`validation/asm/` and `validation/C/` tests, with no setup beyond
installing the bundled release. See `compiler/README.md` for exactly
what's bundled and why.

---

## Building your own, instead

If you want to write more serious programs of your own, rather than
just work with this project's own test suite, build a proper, modern,
actively-supported cross-compiler instead, with
[Buildroot](http://buildroot.uclibc.org/download.html):

```sh
# download and extract Buildroot, then:
make qemu_sparc_ss10_defconfig && make menuconfig
# under "Toolchain", enable "Build cross gdb for the host" if you want a
# cross gdb, for debugging a *target* SPARC binary running under, say,
# QEMU. Unrelated to this repo's own gdb support (see "Examining Core
# State at Runtime Using GDB"), which uses the *host's* own gdb directly
# on the host-native simulator process. No cross gdb needed for that.
make      # downloads and builds everything, takes a while
```

The resulting tools (`sparc-linux-gcc`, `sparc-linux-as`, ...) end up in
`<buildroot>/output/host/usr/bin`. Add that to your `PATH`. See
`compiler/README.md` for the full note, including a link to the original
writeup this is based on.
