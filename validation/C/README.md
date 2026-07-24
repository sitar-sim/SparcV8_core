# validation/C/

Bare-metal C tests (`<TEST>.c` + `<TEST>.vprj` pairs, same `.vprj` format as
`asm/`). These exercise a sequence of C-level operations together (loops,
arrays, structs, global variables), rather than one instruction at a time.

Write an ordinary, freestanding `main()` (no libc, see
`docs/writing_and_running_c_programs.md`), and end it with
`__asm__ volatile ("ta 0")`, since `main()` must never return. See
`array_sum/array_sum.c` for a working example.

Each test's compiler-generated `<TEST>.s` (assembly) and `<TEST>.objdump`
(disassembly of the linked binary, addresses and symbols included) are
committed alongside it, unlike the `.o`/`.elf` build byproducts. Unlike a
hand-written `asm/` test, a C test's actual instruction sequence isn't
something its author wrote directly, so both are kept readable and
available for stepping through, without needing the toolchain installed.

## `crt0.s`

A hand-written `.c` file only contains `main()`. It has no trap table, and
nothing initializes the stack. `../../compiler/crt0.s` supplies both,
linked ahead of every C test's own compiled object by
`../../compiler/compile_c.sh` (with the linker's entry point overridden to
`crt0.s`'s own `_start`, instead of `sparc.ld`'s default `ENTRY(main)`).
Before calling `main()`, it:

1. Enables traps and installs the same 256-entry trap table every `asm/`
   test installs by hand, and initializes `%g1` as the pass/fail sentinel
   -- see `asm/README.md` for what this convention means and why. This is
   what makes a C test's `ta 0` halt exactly the same way an `asm/` test's
   does, and lets an unexpected trap during the test get caught the same
   way too.
2. Sets up a working stack. Every register, including `%sp`, is `0` after
   reset, and any C function using a local variable (even one, even at
   `-O0`) executes `save %sp, -N, %sp` as its first instruction, which
   needs a real `%sp` already in place. `asm/` tests never need this step,
   since none of them call a function.

Step 2 happens *after* step 1, not before. PSR's low 5 bits are CWP (the
current register window), and enabling traps writes PSR with a CWP field
of `0`. That switches the active register window, silently hiding any
register value (including `%sp`) set in the window active beforehand. See
the comments in `crt0.s` itself for the full detail.

The overall compile/assemble/link/hex-dump/objdump sequence in
`compile_c.sh`, and the bundled compiler itself (GCC 4.4.3), both come
from the AJIT project -- see `AUTHORS` in the repo root.

See `../README.md` for the scripts that build and run these tests.
