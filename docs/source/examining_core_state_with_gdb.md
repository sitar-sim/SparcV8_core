# Examining Core State at Runtime Using GDB

Both models are, underneath everything else, plain host C++ programs
(`sparc_cpp_sim`/`check_test`, `sitar_check_test`). That means the host's own
`gdb` can attach to them directly -- no cross-debugger, no special
protocol -- and step through simulated SPARC execution one instruction at a
time, break on a specific PC/register/memory condition, and inspect the
entire architectural state, all without touching the model's own source.

## Why use gdb instead of logging

[Logging](logging.md) is the right tool when you want to *watch a program
run* -- a full instruction-by-instruction trace, loaded into
`log_viewer/`. It has a real cost, though: formatting the entire
current-window state (~50 fields) on every single instruction is
non-negligible work, and a long-running program produces a trace too large
to comfortably load or scroll through.

GDB is the better tool for the opposite situation: you already know
*roughly* what you're looking for -- a specific PC, a specific trap, a
memory location or register reaching a specific value -- and want to stop
exactly there without generating a full trace at all. Selective logging
(`log.turnOFF()`/`turnON()`, see [Logging](logging.md)) can narrow a trace
down by time/PC range, but the condition has to be decided *in advance* and
built into `Core.sitar` -- checking a genuinely dynamic condition (a
register reaching a value that depends on the program's own data) means
adding that check into the model's source and recompiling. A gdb
conditional breakpoint is the same check, attached at the debugger prompt,
changeable between runs with no recompile.

## Installing gdb

```sh
sudo apt install gdb
```

## Building with `--debug`

By default, neither model is built with debug symbols -- there's no reason
to pay for `-g` in an ordinary build. Rebuild with `--debug`:

```sh
model/cpp_model/build.sh --debug
model/sitar_model/build.py --debug
```

This adds `-g` and compiles in a handful of named, otherwise-empty
`debug_hook_*()` functions (see `model/cpp_common_code/DebugHooks.h`) that
exist purely so gdb has a stable place to break on by name, at exactly the
points an instruction can finish (executed, trapped, or annulled) or a
memory reference completes -- covered in the walkthrough below. It
deliberately *stays* at `-O3`: gdb's `call`/`print` of a live function is
generally unreliable against optimized code, but the handful of functions
this actually relies on for that (`Registers::R_r()`,
`CoreLogger::print_state()`, `SparcCore::printTrap()`, `MemCore::wordPtr()`)
are individually pinned to `-O0` in their own definitions, so the rest of
the simulator stays fast. `--logging` combines with `--debug` freely (all
four combinations are valid) but for a gdb session you normally don't want
it -- avoiding logging's per-instruction cost is the whole point.

If you need to debug something *outside* those hook points -- an arbitrary
breakpoint or single-step deep inside `SparcCore` itself, where `-O3`'s
inlining and register allocation make local variables unreliable to
inspect -- use `--debug-o0` instead, which rebuilds the whole binary at
`-O0`. Slower; only worth it for that kind of deep dive.

## A first walkthrough

This uses a small, frozen copy of the `array_sum` test committed alongside
this page (`docs/source/examples/array_sum/`), rather than
`validation/C/array_sum/` directly -- built once with the toolchain this
repository vendors, so the addresses below stay correct regardless of
which cross-compiler version you have installed. The source:

```c
--8<-- "docs/source/examples/array_sum/array_sum.c"
```

It sums `{1,2,3,4,5}` in a loop and reports pass/fail in `%o0`. Build the
cpp model with `--debug` (the sitar model works identically -- see the note
at the end of this section) and load the convenience commands from
[`debug/sparc.gdb`](https://github.com/sitar-sim/SparcV8_core/blob/main/debug/sparc.gdb)
(this walkthrough only uses a few -- see "Command reference" below for
every one):

```sh
model/cpp_model/build.sh --debug
gdb model/cpp_model/sparc_cpp_sim
```

```
(gdb) source debug/sparc.gdb
(gdb) sparc-break pc=0x203c
(gdb) run docs/source/examples/array_sum/array_sum.hex
```

`0x203c` is the loop body's own address (`ld [%fp+-12],%g1` -- see
"Finding addresses" below for where that number comes from). This stops
once per loop iteration, right after that iteration's instruction has
fully executed:

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
`continue` re-hits the same breakpoint at the next loop iteration -- this
is effectively "single-step one SPARC instruction," for free, since it's
the same condition matching the next occurrence:
```
(gdb) continue
Breakpoint 1, debug_hook_after_execute (core=..., op=LD) at ...
```

To watch the running sum itself change, you first need its address --
`array_sum.c` never spells it out, `sum` is a local, stack-resident
variable (see "Finding addresses" below for why that's the one thing an
objdump can't give you directly). Discover it live instead, by breaking on
every store and looking at where each one goes:
```
(gdb) sparc-break-mem kind=store
(gdb) continue
(gdb) sparc-print-mem
kind=STORE address=0xfffffc8 word0=0x0 word1=0x1 MAE=0
(gdb) continue
(gdb) sparc-print-mem
kind=STORE address=0xfffffe0 word0=0x0 word1=0x5 MAE=0
```
The first few hits are the array literal `{1,2,3,4,5}` itself being
written, once each, to increasing addresses. `0xfffffc8` above is actually
earlier still -- `crt0.s`'s own setup, before `main` even starts. Keep
`continue`-ing and one address starts repeating every loop iteration
instead of appearing once: that's `sum`. Set the watchpoint on it:
```
(gdb) sparc-watch-mem addr=0xfffffe0
(gdb) continue
Hardware watchpoint 2: *(unsigned int*)...

Old value = 1
New value = 3
```

To catch the final pass/fail write into `%o0` directly:
```
(gdb) sparc-watch-reg o0
(gdb) continue
Breakpoint N, debug_hook_after_execute (core=..., op=OR) at ...
(gdb) sparc-print-reg o0
o0 = 0x1 (1)
```

**Sitar model**: everything above works identically against
`model/sitar_model/executable/sitar_check_test` (built with
`model/sitar_model/build.py --debug`), same commands, same addresses --
both models drive the same `SparcCore`, and the debug hooks live in the
shared `cpp_common_code/`, not in either driver. The only difference is the
CLI takes an extra expected-results argument:
```sh
gdb model/sitar_model/executable/sitar_check_test
(gdb) source debug/sparc.gdb
(gdb) sparc-break pc=0x203c
(gdb) run docs/source/examples/array_sum/array_sum.hex docs/source/examples/array_sum/array_sum.expected
```

## Command reference

`debug/sparc.gdb` (loaded with `source debug/sparc.gdb`) adds every
command below. Three groups: **breakpoints** stop execution at one of the
four `debug_hook_*()` points (see `model/cpp_common_code/DebugHooks.h`);
**watchpoints** stop when a value changes; **probe/print** commands read
state without stopping anything, usable once you're already stopped
somewhere.

Two syntax conventions apply throughout:

**Address/PC arguments** (`pc=`, `addr=`) accept one of three forms:

| Form | Meaning |
|---|---|
| `0x2054` | exact match |
| `0x2000:0x2100` | half-open range: `addr >= lo && addr < hi` |
| `0x2000/0xfffff000` | masked match: `(addr & mask) == (base & mask)` |

The `base/mask` form is restricted to masks of the form `0xfff...000`
(trailing zero bits) -- a contiguous, power-of-2-aligned range, same as the
`lo:hi` form, just expressed differently, and the only form
`sparc-watch-mem` can turn into a single watched region. For anything that
genuinely isn't contiguous, use several breakpoints/watchpoints.

**Register-name arguments** accept windowed mnemonics (`g0`-`g7`,
`o0`-`o7`, `l0`-`l7`, `i0`-`i7`), flat SPARC r-numbering (`r0`-`r31` --
`r1`==`g1`, `r9`==`o1`, the same numbering `Registers::R_r()` itself uses),
or the specials `pc`, `npc`, `y`, `psr`, `wim`, `tbr`.

One asymmetry to know about: for the *breakpoint* commands, `coreid=` is a
**filter** on the hook's own `core.coreID` -- omit it and any core matches.
For the *probe/print* and `sparc-watch-reg` commands, `coreid=` is a
**selector** into the runtime registry that finds a live `SparcCore` to
read from (see `model/cpp_common_code/DebugRegistry.h`) -- there's no "no
selection" concept there, so it defaults to `0`. `sparc-watch-mem`/
`sparc-print-mem` take no `coreid=` at all: memory isn't owned per-core in
this model (there is exactly one `MemCore` regardless of core count).

### Breakpoints

| Command | Syntax | Stops at |
|---|---|---|
| `sparc-break` | `pc=<addr-expr> [coreid=<n>]` | `debug_hook_after_execute` -- an instruction has fully executed, PC/nPC not yet advanced -- when PC matches |
| `sparc-break-nth` | `pc=<addr-expr> n=<k> [coreid=<n>]` | same, but only the k-th match actually stops (gdb's own `ignore` under the hood) |
| `sparc-break-trap` | `[type=<name>] [coreid=<n>]` | `debug_hook_trap_raised`, optionally filtered to one cause (see below) |
| `sparc-break-mae` | `[coreid=<n>]` | `debug_hook_mem_access` with `core.MAE` set -- any kind, any address |
| `sparc-break-mem` | `[kind=<k>] [addr=<addr-expr>] [data=<hex>] [mae] [coreid=<n>]` (`<k>` is `ifetch`, `load`, `store`, `atomic`, or `flush`) | `debug_hook_mem_access`, filtered by any combination of kind/address/data (`word0`)/fault |
| `sparc-break-annulled` | `[pc=<addr-expr>] [coreid=<n>]` | `debug_hook_annulled` -- a delay-slot instruction skipped by an untaken annulling branch; fires *before* PC/nPC update for the skip, so they're still the annulled instruction's own address and what it advances to |

`sparc-break-trap`'s `type=` is one of the same cause names
`core.printTrap()` itself reports:

`reset_trap` &middot; `data_store_error` &middot; `instruction_access_error` &middot;
`r_register_access_error` &middot; `instruction_access_exception` &middot;
`privileged_instruction` &middot; `illegal_instruction` &middot; `fp_disabled` &middot;
`cp_disabled` &middot; `unimplemented_FLUSH` &middot; `window_overflow` &middot;
`window_underflow` &middot; `mem_address_not_aligned` &middot; `fp_exception` &middot;
`cp_exception` &middot; `data_access_error` &middot; `data_access_exception` &middot;
`tag_overflow` &middot; `division_by_zero` &middot; `trap_instruction` &middot;
`external_interrupt` -- omit `type=` for any cause.

`sparc-break-mae` is the simple, no-thought shortcut for a rare event; for
anything more specific (a particular kind/address that also faults), use
`sparc-break-mem` with `mae` added.

Examples:
```
(gdb) sparc-break pc=0x203c
(gdb) sparc-break-nth pc=0x203c n=10
(gdb) sparc-break-trap type=illegal_instruction
(gdb) sparc-break-mae
(gdb) sparc-break-mem kind=load addr=0x2000:0x2100
(gdb) sparc-break-mem kind=load mae
(gdb) sparc-break-mem kind=ifetch addr=0x2054
(gdb) sparc-break-mem kind=store data=0xdeadbeef
(gdb) sparc-break-annulled pc=0x2038
```

### Watchpoints

Both called "watchpoints" despite very different mechanisms underneath --
from the user's side, both mean "tell me when this changes."

| Command | Syntax | Mechanism |
|---|---|---|
| `sparc-watch-mem` | `addr=<addr-expr> [coreid=<n>]` | true hardware watchpoint -- fires the instant the value changes, wherever/whenever that happens (mid-instruction included). Large ranges may silently fall back to a slow software watchpoint if the host has no hardware debug register wide enough |
| `sparc-watch-reg` | `<reg> [value=<hex>] [mask=<hex>] [persist] [coreid=<n>]` | **not** a hardware watchpoint -- see below |

`sparc-watch-reg` is deliberately not a real watchpoint: a real one fires
the instant the underlying storage changes, which for a register can be
mid-instruction (e.g. window shuffling), before the value is
architecturally committed. This instead checks `<reg>` once per
instruction, at `debug_hook_after_execute` -- the stable, retired value --
comparing it against its value at the previous check:

| Arguments given | Fires |
|---|---|
| *(none)* | on any change from the previous check |
| `value=`/`mask=` | once, on the transition *into* a matching value (edge-triggered) |
| `value=`/`mask=` + `persist` | on *every* instruction the value/mask condition holds, not just the transition into it -- a corner case, but a real one |

Examples:
```
(gdb) sparc-watch-mem addr=0xfffffe0
(gdb) sparc-watch-reg cwp
(gdb) sparc-watch-reg o1 value=0x10000000 mask=0xf0000000
(gdb) sparc-watch-reg o1 value=0x1 persist
```

### Probe / print

| Command | Syntax | Shows |
|---|---|---|
| `sparc-print-regs` | `[coreid=<n>]` | full register/PSR dump (`CoreLogger::print_state()`) -- works from any frame, not just inside a hook |
| `sparc-print-reg` | `<reg> [coreid=<n>]` | one register's value, either naming scheme |
| `sparc-print-traps` | `[coreid=<n>]` | trap cause (`core.printTrap()`), TBR, PC, and the ET/PS/S PSR bits |
| `sparc-print-annulled` | *(none)* | pc/npc/raw instruction word of the annul currently stopped at (`debug_hook_annulled`) -- not decoded to a mnemonic (annulled instructions are deliberately never decoded by the model itself); cross-check the pc against an objdump instead |
| `sparc-print-mem` | `[addr=<addr-expr>] [count=<n>] [format=<f>]` (`<f>` is `hex`, `bin`, `dec`, or `str`) | no `addr=`, while stopped in `debug_hook_mem_access`: that access's own kind/address/word0/word1/MAE. With `addr=`: live memory content there instead, from anywhere -- `count` words (default 1, or however many an `addr=` range covers) |

Examples:
```
(gdb) sparc-print-regs
(gdb) sparc-print-reg o1
(gdb) sparc-print-reg r9
(gdb) sparc-print-traps
(gdb) sparc-print-annulled
(gdb) sparc-print-mem
kind=LOAD address=0xfffffe0 word0=0x1 word1=0x0 MAE=0
(gdb) sparc-print-mem addr=0xfffffe0
(gdb) sparc-print-mem addr=0x2000:0x2020 format=dec
```

### Managing breakpoints/watchpoints

| Command | Syntax | Does |
|---|---|---|
| `sparc-list` | *(none)* | list every sparc-\* breakpoint/watchpoint set so far, with the friendly label each was created with |
| `sparc-delete` | `<id>` | remove one, by the id `sparc-list` shows |

Every command above prints a line when it creates a breakpoint/watchpoint,
e.g. `[sparc #2] break pc=0x203c (gdb breakpoint #1)`. gdb's own `info
breakpoints` shows the same entries, but only their raw translated
condition string, which for these is rarely readable at a glance:
```
(gdb) sparc-list
id   gdb#   kind   hits   description
1    1      break  2      break pc=0x203c
2    2      watch  0      watch-mem addr=0xfffffe0
(gdb) sparc-delete 1
Deleted sparc #1 (break pc=0x203c)
```

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
variables (`sum`, `i`, `values` in `array_sum.c`) -- those are
stack-resident at `-O0` and never appear in the ELF symbol table at all
(that would need DWARF debug info compiled into the *target* SPARC binary,
a separate, heavier thing this repository doesn't do). Reading the
disassembly's `%fp`-relative offsets directly, as the walkthrough's
`0xfffffe0` address for `sum` did, is the way around this -- once you have
one such address from a live run, it stays valid for that test.

## GDB itself, briefly

A few native commands worth knowing, independent of anything above:

| Command | Does |
|---|---|
| `break LOCATION if COND` | conditional breakpoint in one line |
| `watch EXPR` | hardware watchpoint -- breaks the instant `EXPR`'s value changes |
| `ignore N COUNT` | skip the next `COUNT` hits of breakpoint `N` silently, stopping on hit `COUNT+1` -- `ignore N 9` for "stop on the 10th occurrence" (this is exactly what `sparc-break-nth` does internally) |
| `call EXPR` | invoke a real function/method in the debuggee, print its result |
| `continue` / `c` | resume until the next breakpoint/watchpoint |
| `next` / `step` | step one *host* C++ line (steps through driver code, not one simulated SPARC instruction -- use a `sparc-break`+`continue` loop for that instead) |
| `bt` | backtrace |
| `delete N` | remove breakpoint/watchpoint `N` |
| `quit` | exit |

Every `sparc-*` command above is built entirely out of these -- intuitive
names standing in for the underlying condition syntax and symbol names,
not a replacement for knowing them. See
[`debug/sparc.gdb`](https://github.com/sitar-sim/SparcV8_core/blob/main/debug/sparc.gdb)
for the implementation, and its own
[README](https://github.com/sitar-sim/SparcV8_core/blob/main/debug/README.md)
for the design notes behind it (why each function is pinned to `-O0`, how
`DebugRegistry` makes state reachable from any frame, and so on).
