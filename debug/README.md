# debug/

`sparc.gdb` -- convenience commands for examining a running
`sparc_sim_cpp`/`sparc_sim_sitar` (built with `--debug`, see
`model/system_models/core_only/cpp_model/build.sh`/`.../sitar_model/build.sh`) under host gdb.

## Why this file exists

The debug hooks themselves (`model/cpp_common_code/DebugHooks.h`,
`DebugRegistry.h`) are what make gdb-based examination possible at all --
see [`docs/source/examining_core_state_with_gdb.md`](../docs/source/examining_core_state_with_gdb.md)
for that motivation (surgical inspection without recompiling/without
logging's per-instruction overhead). This file is a different, narrower
thing: a convenience layer *on top of* that mechanism. Without it, examining
state means remembering the actual C++ symbols and expression syntax by
heart, e.g.:

```
(gdb) break debug_hook_after_execute if core.reg.PC==0x2054 && core.coreID==0
(gdb) print core.reg.R_r(9)
```

`sparc.gdb` gives intuitive, memorable names standing in for exactly that --
`sparc-break pc=0x2054`, `sparc-print-reg o1` -- and, for the handful of
commands that need real logic (register-name translation, the address-range
syntax, a register watch that only fires at instruction boundaries), does it
in Python rather than gdb's own more limited scripting language.

Load it once per gdb session:

```
(gdb) source debug/sparc.gdb
```

or non-interactively:

```
gdb -x debug/sparc.gdb ./sparc_sim_cpp
```

`sparc-list` at any point shows every sparc-\* breakpoint/watchpoint
currently set (gdb's own `info breakpoints` shows the same entries, but only
their raw translated condition string -- this is the readable view);
`sparc-delete <id>` removes one.

## Address/PC syntax

Every command that takes a `pc=`/`addr=` argument accepts one of three
forms:

| Form | Meaning |
|---|---|
| `0x2054` | exact match |
| `0x2000:0x2100` | half-open range: `addr >= lo && addr < hi` |
| `0x2000/0xfffff000` | masked match: `(addr & mask) == (base & mask)` |

The `base/mask` form is intentionally restricted to masks of the form
`0xfff...000` (trailing zero bits) -- a contiguous, power-of-2-aligned
range, same as the `lo:hi` form, just expressed differently (and the only
form `sparc-watch-mem` can turn into a single watched region). For anything
that genuinely isn't contiguous, use several breakpoints/watchpoints.

## Register-name syntax

Every command that takes a register name accepts:

- windowed mnemonics: `g0`-`g7`, `o0`-`o7`, `l0`-`l7`, `i0`-`i7`
- flat SPARC r-numbering: `r0`-`r31` (`r1`==`g1`, `r9`==`o1`, ... -- the
  same numbering `Registers::R_r()` itself uses)
- specials: `pc`, `npc`, `y`, `psr`, `wim`, `tbr`

## Command reference

### Breakpoints

- **`sparc-break pc=<addr-expr> [coreid=<n>]`** -- break at
  `debug_hook_after_execute` (instruction fully executed, PC/nPC not yet
  advanced) when PC matches.
- **`sparc-break-nth pc=<addr-expr> n=<k> [coreid=<n>]`** -- like
  `sparc-break`, but only actually stops on the k-th match.
- **`sparc-break-trap [type=<name>] [coreid=<n>]`** -- break at
  `debug_hook_trap_raised`. `type` is one of the same cause names
  `core.printTrap()` itself reports: `reset_trap`, `data_store_error`,
  `instruction_access_error`, `r_register_access_error`,
  `instruction_access_exception`, `privileged_instruction`,
  `illegal_instruction`, `fp_disabled`, `cp_disabled`,
  `unimplemented_FLUSH`, `window_overflow`, `window_underflow`,
  `mem_address_not_aligned`, `fp_exception`, `cp_exception`,
  `data_access_error`, `data_access_exception`, `tag_overflow`,
  `division_by_zero`, `trap_instruction`, `external_interrupt`. Omit for
  any cause.
- **`sparc-break-mae [coreid=<n>]`** -- break at `debug_hook_mem_access`
  whenever `core.MAE` is set, any kind, any address. The simple, no-thought
  shortcut for a rare event; for anything more specific, use
  `sparc-break-mem` with `mae` added.
- **`sparc-break-mem [kind=<IFETCH|LOAD|STORE|ATOMIC|FLUSH>] [addr=<addr-expr>] [data=<hex>] [mae] [coreid=<n>]`**
  -- break at `debug_hook_mem_access`, filtered by any combination:
  ```
  sparc-break-mem kind=LOAD addr=0x2000:0x2100
  sparc-break-mem kind=LOAD mae
  sparc-break-mem kind=IFETCH addr=0x2054
  ```
- **`sparc-break-annulled [pc=<addr-expr>] [coreid=<n>]`** -- break at
  `debug_hook_annulled`. Fires before PC/nPC are updated for the skip, so
  `core.reg.PC`/`nPC` are the annulled instruction's own address and what
  it advances to. `pc` is optional -- omit to catch every annul, which can
  be very frequent in loop-heavy code; usually worth narrowing to a
  specific `pc`.

### Watchpoints

- **`sparc-watch-mem addr=<addr-expr> [coreid=<n>]`** -- a true hardware
  watchpoint on simulated memory. Fires the instant the value changes,
  wherever/whenever that happens (mid-instruction included). Large ranges
  may silently fall back to a slow software watchpoint if the host has no
  hardware debug register wide enough.
- **`sparc-watch-reg <reg> [value=<hex>] [mask=<hex>] [persist] [coreid=<n>]`**
  -- **not** a hardware watchpoint. A real one fires the instant the
  underlying storage changes, which for a register can be mid-instruction
  (e.g. window shuffling), before the value is architecturally committed.
  This instead checks `<reg>` once per instruction, at
  `debug_hook_after_execute` -- the stable, retired value -- comparing it
  against its value at the previous check:
  - no `value=` given: fires on any change (e.g. "tell me whenever `cwp`
    changes")
  - `value=`/`mask=` given: fires once, on the transition into a matching
    value (edge-triggered) -- e.g. "tell me when `o1` *takes* value
    `0x1xxxxxxx`"
  - add `[persist]` to instead fire on *every* instruction the value/mask
    condition holds, not just the transition into it (a corner case, but a
    real one -- only meaningful together with `value=`)

Both are called "watchpoints" here despite the very different mechanism
underneath -- from the user's side, both mean "tell me when this changes."

### Probe / print

- **`sparc-print-regs [coreid=<n>]`** -- full register/PSR dump
  (`CoreLogger::print_state()`). Works from any frame, not just inside a
  hook.
- **`sparc-print-reg <reg> [coreid=<n>]`** -- one register's value.
- **`sparc-print-traps [coreid=<n>]`** -- trap cause (`core.printTrap()`),
  TBR, PC, and the ET/PS/S PSR bits.
- **`sparc-print-annulled`** -- pc/npc/raw instruction word of the annul
  currently stopped at (`debug_hook_annulled`). Not decoded to a mnemonic
  here (annulled instructions are deliberately never decoded by the model
  itself) -- cross-check the pc against an objdump instead.
- **`sparc-print-mem-access`** -- while stopped in `debug_hook_mem_access`:
  prints that access's own kind/address/word0/word1/MAE directly,
  whatever memory reference just completed, even if no register was
  updated. No `coreid=` here: this reads the current frame's own core,
  there is nothing to select.
- **`sparc-print-mem addr=<addr-expr>`** -- reads and prints live memory
  content at `addr` (exact/`lo:hi`/`base/mask`), from anywhere, in hex --
  however many words the range covers (one, for an exact address). No
  `coreid=` here: memory isn't owned per-core in this model (there is
  exactly one `MemCore` regardless of core count).

`coreid=` is offered on anything that relates to a specific `SparcCore`
instance (every `sparc-break-*` command, since each hook still receives
the initiating core even for a memory event; `sparc-print-regs`/
`sparc-print-reg`/`sparc-print-traps`/`sparc-watch-reg`, which read a
core's own register/PSR/trap state), and withheld from anything that
relates to `MemCore` instead (`sparc-watch-mem`, `sparc-print-mem`),
since memory isn't owned per-core in this model at all. Note it means two
different things depending on which side it's on: for the *break*
commands it's a **filter** (a condition on the hook's own `core`
parameter -- omit it and nothing is filtered, any core matches); for the
*print*/`watch-reg` commands it's a **selector** into `DebugRegistry`
(which live `SparcCore` to read from -- there's no "no selection" concept
there, so it defaults to `0`).

## Design notes (for anyone extending this file)

- `model/cpp_common_code/DebugRegistry.h` is what makes every command here
  reachable from *any* stopped frame, in either model, without caring who
  constructed the `SparcCore`/`MemCore` or which frame it's lexically
  reachable from -- `SparcCore`/`MemCore` register themselves there, once,
  in their own constructors.
- A handful of functions (`Registers::R_r()` and the six special-register
  accessors `R_PC()`/`R_nPC()`/`R_Y()`/`R_PSR()`/`R_WIM()`/`R_TBR()`,
  `CoreLogger::print_state()`, `SparcCore::printTrap()`,
  `MemCore::wordPtr()`, `DebugRegistry::findCoreByID()`/`firstMemCore()`)
  are individually pinned to `-O0` via `__attribute__((optimize("O0")))`,
  so a `--debug` build can stay at `-O3` overall. gdb's `call`/`print` of
  a live function is generally unreliable against optimized code, but only these few are ever
  actually called this way.
- Reading a `std::string` returned by value (`print_state()`, `printTrap()`)
  needs care, twice over: gdb's own pretty-printer quotes and
  backslash-escapes embedded newlines and truncates past `print elements`
  (200 by default) -- wrong for a multi-line dump -- so this file reads
  `.c_str()` directly instead (see `core_string()`). Separately, the
  returned `std::string` is a temporary living in the *inferior's* own
  memory; a later, unrelated inferior call can reuse/clobber that scratch
  space before a lazily-held `gdb.Value` ever gets read -- `core_string()`
  reads it out to a real Python string immediately, before that can happen.
