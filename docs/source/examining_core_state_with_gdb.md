# Examining Core State at Runtime Using GDB

Both models are, underneath everything else, plain host C++ programs
(`sparc_sim_cpp`, `sparc_sim_sitar`). That means the host's
own `gdb` can attach to them directly. No cross-debugger and no special
protocol are needed. It can step through simulated SPARC execution one
instruction at a time, break on a specific PC/register/memory condition,
and inspect the entire architectural state, all without touching the
model's own source.

This page is a beginner-facing introduction and walkthrough. See
[GDB Command Reference](gdb_command_reference.md) for the exhaustive,
descriptive list of every `sparc-*` breakpoint/watchpoint/probe command,
and [Debug Support Internals](debug_support_internals.md) for how this
support is actually built.

---

## Why use gdb instead of logging

[Logging](logging.md) is the right tool when you want to *watch a
program run*: a full instruction-by-instruction trace, loaded into the
[log viewer](logging.md#the-log-viewer). It has a real cost, though.
Formatting the entire current-window state (~50 fields) on every single
instruction is non-negligible work, and a long-running program produces
a trace too large to comfortably load or scroll through.

GDB is the better tool for the opposite situation. You already know
*roughly* what you're looking for, a specific PC, a specific trap, a
memory location or register reaching a specific value, and want to stop
exactly there without generating a full trace at all. Selective logging
(`log.turnOFF()`/`turnON()`, see [Logging](logging.md)) can narrow a
trace down by time/PC range, but the condition has to be decided *in
advance* and built into `Core.sitar`. Checking a genuinely dynamic
condition (a register reaching a value that depends on the program's own
data) means adding that check into the model's source and recompiling
instead. A gdb conditional breakpoint is the same check, attached at the
debugger prompt, changeable between runs with no recompile.

---

## Installing gdb

```sh
sudo apt install gdb
```

---

## Building with `--debug`

By default, neither model is built with debug symbols. Rebuild with
`--debug`:

```sh
model/system_models/core_only/cpp_model/build.sh --debug
model/system_models/core_only/sitar_model/build.sh --debug
```

This adds debug symbols and a handful of stable, named hook points gdb
can break on by name, at exactly the points an instruction can finish
(executed, trapped, or annulled) or a memory reference completes, see
[Debug Support Internals](debug_support_internals.md) for where these
are and why. `--logging` combines with `--debug` freely (all four
combinations are valid), but for a gdb session you normally don't want
it. Avoiding logging's per-instruction cost is the whole point.

For an arbitrary breakpoint or single-step deep inside `SparcCore`
itself, beyond those hook points, use `--debug-o0` instead, see
[Debug Support Internals](debug_support_internals.md#build-modes-debug-vs-debug-o0)
for when and why.

---

## A first walkthrough

This uses a small, frozen copy of the `array_sum` test committed
alongside this page (`docs/source/examples/array_sum/`), rather than
`validation/C/array_sum/` directly. It was built once with the toolchain
this repository vendors, so the addresses below stay correct regardless
of which cross-compiler version you have installed. The source:

```c
--8<-- "docs/source/examples/array_sum/array_sum.c"
```

It sums `{1,2,3,4,5}` in a loop and reports pass/fail in `%o0`. Build the
cpp model with `--debug` (the sitar model works identically, see the note
at the end of this section) and load the convenience commands from
[`debug/sparc.gdb`](https://github.com/sitar-sim/SparcV8_core/blob/main/debug/sparc.gdb)
(this walkthrough only uses a few, see
[GDB Command Reference](gdb_command_reference.md) for every one):

```sh
model/system_models/core_only/cpp_model/build.sh --debug
gdb model/system_models/core_only/cpp_model/executable/sparc_sim_cpp_core_only_debug
```

```
(gdb) source debug/sparc.gdb
(gdb) sparc-break pc=0x203c
(gdb) run docs/source/examples/array_sum/array_sum.hex
```

`0x203c` is the loop body's own address (`ld [%fp+-12],%g1`, see "Finding
addresses" below for where that number comes from). This stops once per
loop iteration, right after that iteration's instruction has fully
executed:

```
Breakpoint 1, debug_hook_after_execute (core=..., op=LD) at .../DebugHooks.cpp:13
```

From here:

```
(gdb) sparc-print-regs
```
prints the entire current-window register/PSR state. For just one
register:
```
(gdb) sparc-print-reg l0
l0 = 0xe0 (224)
```
`continue` re-hits the same breakpoint at the next loop iteration. This
is effectively "single-step one SPARC instruction," for free, since it's
the same condition matching the next occurrence:
```
(gdb) continue
Breakpoint 1, debug_hook_after_execute (core=..., op=LD) at ...
```

Delete it before moving on, an active `pc=0x203c` breakpoint would keep
firing on every loop iteration for the rest of this walkthrough
otherwise, getting in the way of everything below:
```
(gdb) sparc-delete 1
```

To watch the running sum itself change, you first need its address.
`array_sum.c` never spells it out, `sum` is a local, stack-resident
variable (see "Finding addresses" below for why that's the one thing an
objdump can't give you directly). Discover it live instead, by breaking
on every store and looking at where each one goes. `run` again first,
restarting the program from the very beginning (the `pc=0x203c`
breakpoint would otherwise have already skipped past the stores we want
to see):
```
(gdb) sparc-break-mem kind=STORE
(gdb) run
(gdb) sparc-print-mem-access
kind=STORE address=0xfffffc8 word0=0x0 word1=0x1 MAE=0
(gdb) continue
(gdb) sparc-print-mem-access
kind=STORE address=0xfffffd0 word0=0x2 word1=0x1 MAE=0
(gdb) continue
(gdb) continue
(gdb) continue
(gdb) continue
(gdb) sparc-print-mem-access
kind=STORE address=0xfffffe0 word0=0x0 word1=0x5 MAE=0
```

The first several hits are the array literal `{1,2,3,4,5}` itself being
written into `values[]` (`fp-36` through `fp-20`), `0xfffffc8` above is
actually earlier still, `crt0.s`'s own setup, before `main` even starts.
A few addresses repeat once each along the way too, that's just two
adjacent 4-byte array elements sharing one 8-byte-aligned doubleword,
the granularity this hook reports at, not a loop yet. Keep
`continue`-ing (six times total gets you to `0xfffffe0` above) and past
the array initialization, one address starts repeating on *every* loop
iteration instead: that's `sum`. Delete the now-done store breakpoint
first, it would otherwise keep firing on every store from here on,
including the ones the watchpoint below is about to catch, then set the
watchpoint on it:
```
(gdb) sparc-delete 2
(gdb) sparc-watch-mem addr=0xfffffe0
(gdb) continue
Hardware watchpoint 3: *(unsigned int*)...

Old value = 0
New value = 1
```

That's the first loop iteration adding `values[0]` (`1`) to `sum`
(starting at `0`). Delete this watchpoint too before the next step, for
the same reason, then catch the final pass/fail write into `%o0`
directly:
```
(gdb) sparc-delete 3
(gdb) sparc-watch-reg o0
(gdb) continue
Breakpoint N, debug_hook_after_execute (core=..., op=OR) at ...
(gdb) sparc-print-reg o0
o0 = 0x1 (1)
```

**Sitar model**: everything above works identically against
`model/system_models/core_only/sitar_model/executable/sparc_sim_sitar_core_only_debug`
(built with
`model/system_models/core_only/sitar_model/build.sh --debug`), same
commands, same addresses, same CLI. Both models drive the same
`SparcCore`, and the debug hooks live in the shared `cpp_common_code/`,
not in either driver.
```sh
gdb model/system_models/core_only/sitar_model/executable/sparc_sim_sitar_core_only_debug
(gdb) source debug/sparc.gdb
(gdb) sparc-break pc=0x203c
(gdb) run docs/source/examples/array_sum/array_sum.hex docs/source/examples/array_sum/array_sum.expected
```

---

## Finding addresses

Every `.objdump` (produced by `compiler/compile_c.sh`/`assemble.sh`
alongside a test's `.hex`) now includes the full symbol table after the
disassembly (`sparc-elf-readelf -s`), not just the incidental branch/call
target annotations disassembly alone provides. For `array_sum`,
`docs/source/examples/array_sum/array_sum.objdump` shows:
```
--8<-- "docs/source/examples/array_sum/array_sum.objdump:main-symtab"
```
and `main`'s own disassembly gives the loop body's address used above:
```
--8<-- "docs/source/examples/array_sum/array_sum.objdump:main-disasm"
```

One real limitation, accepted rather than worked around: this gives you
function and global-variable addresses, but *not* addresses for local C
variables (`sum`, `i`, `values` in `array_sum.c`). Those are
stack-resident at `-O0` and never appear in the ELF symbol table at all
(that would need DWARF debug info compiled into the *target* SPARC
binary, a separate, heavier thing this repository doesn't do). Reading
the disassembly's `%fp`-relative offsets directly, as the walkthrough's
`0xfffffe0` address for `sum` did, is the way around this. Once you have
one such address from a live run, it stays valid for that test.
