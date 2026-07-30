# GDB Command Reference

The exhaustive reference for every `sparc-*` command
[`debug/sparc.gdb`](https://github.com/sitar-sim/SparcV8_core/blob/main/debug/sparc.gdb)
adds: syntax, behavior, and examples. For a beginner-facing introduction
and a walkthrough instead, see
[Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md).

Loading `debug/sparc.gdb` (`source debug/sparc.gdb`) adds every command
below, organized into three groups.

- **Breakpoints** stop execution at one of the four `debug_hook_*()`
  points (see [Debug Support Internals](debug_support_internals.md)).
- **Watchpoints** stop when a value changes.
- **Probe/print** commands read state without stopping anything, usable
  once you're already stopped somewhere.

---

## Address/PC syntax

Every `pc=`/`addr=` argument takes a single value, one of three forms:

| Form | Meaning |
|---|---|
| `0x2054` | exact match: `addr == 0x2054` |
| `0x2000:0x2100` | half-open range: `addr >= 0x2000 && addr < 0x2100` |
| `0x2000/0xfffff000` | masked match: `(addr & mask) == (base & mask)` |

In plain terms, specifying an address or a range of addresses works one
of three ways:

- **A single address**: `pc=0x2054` matches only that address.
- **A range, `lo:hi`**: `addr=0x2000:0x2100` matches any address from
  `0x2000` up to (not including) `0x2100`.
- **A base and mask, `base/mask`**: `addr=0x2000/0xfffff000` matches any
  address whose top 20 bits match `0x2000`'s, i.e. the aligned block
  `0x2000:0x3000`. This is one single value (the `/` is part of it, not
  a second option). The mask must be trailing zeros only (`0xfff...000`),
  so it can only describe a power-of-2-sized, power-of-2-aligned block,
  use `lo:hi` instead for anything else. Reach for this form specifically
  when you need `sparc-watch-mem` to watch more than one word at once, a
  real hardware watchpoint can only watch a power-of-2-aligned region, a
  plain `lo:hi` range can't become one.

Numbers can be written in whichever base is convenient, these all name
the same address:

- **Hex**: `pc=0x203c`
- **Binary**: `pc=0b10000000111100`
- **Decimal**: `pc=8252`

## Register-name syntax

For convenience, register names can be specified in multiple ways, in
line with SPARC assembly syntax itself:

| Name | Same as |
|---|---|
| `g0`-`g7` | `r0`-`r7` |
| `o0`-`o7` | `r8`-`r15` |
| `l0`-`l7` | `r16`-`r23` |
| `i0`-`i7` | `r24`-`r31` |
| `pc` | *(none)* |
| `npc` | *(none)* |
| `y` | *(none)* |
| `psr` | *(none)* |
| `wim` | *(none)* |
| `tbr` | *(none)* |

## Common options

### `coreid=`

Selects a specific core, for a model built with more than one. Defaults
to core `0` when not given.

Only relevant to commands that relate to a specific core's own state:
setting a breakpoint, or reading or watching its registers. Commands
that relate to memory instead, such as `sparc-print-mem addr=...`, don't
take it. This model has one shared memory, not one per core, so there is
nothing to select.

On a breakpoint, omitting `coreid=` means any core can trigger it. On the
register/probe commands, there's no "any core" option, one specific core
must always be read from, so it defaults to `0` rather than leaving the
question open.

### `kind=`

Used by `sparc-break-mem` to filter which kind of memory reference to
stop on. Always upper case, both when typed and when printed back (e.g.
by `sparc-print-mem-access`):

| Kind | Memory reference |
|---|---|
| `IFETCH` | fetching an instruction |
| `LOAD` | a plain load |
| `STORE` | a plain store |
| `ATOMIC` | an atomic load-store (`swap`, `ldstub`, ...) |
| `FLUSH` | an instruction-cache flush |

### `type=`

Used by `sparc-break-trap` to filter which trap cause to stop on. Omit
it to stop on any cause:

| Cause |
|---|
| `reset_trap` |
| `data_store_error` |
| `instruction_access_error` |
| `r_register_access_error` |
| `instruction_access_exception` |
| `privileged_instruction` |
| `illegal_instruction` |
| `fp_disabled` |
| `cp_disabled` |
| `unimplemented_FLUSH` |
| `window_overflow` |
| `window_underflow` |
| `mem_address_not_aligned` |
| `fp_exception` |
| `cp_exception` |
| `data_access_error` |
| `data_access_exception` |
| `tag_overflow` |
| `division_by_zero` |
| `trap_instruction` |
| `external_interrupt` |

---

## Breakpoints

| Command | Syntax | Stops at |
|---|---|---|
| `sparc-break` | `pc=<addr-expr> [coreid=<n>]` | `debug_hook_after_execute` (an instruction has fully executed, PC/nPC not yet advanced) when PC matches |
| `sparc-break-nth` | `pc=<addr-expr> n=<k> [coreid=<n>]` | same, but only the k-th match actually stops (gdb's own `ignore` under the hood) |
| `sparc-break-trap` | `[type=<name>] [coreid=<n>]` | `debug_hook_trap_raised`, optionally filtered to one cause (see "Common options" above) |
| `sparc-break-mae` | `[coreid=<n>]` | `debug_hook_mem_access` with `MAE` set (the access faulted), any kind, any address |
| `sparc-break-mem` | `[kind=<k>] [addr=<addr-expr>] [data=<hex>] [mae] [coreid=<n>]` (`<k>` is one of the kinds in "Common options" above) | `debug_hook_mem_access`, filtered by any combination of kind/address/data (`word0`)/fault |
| `sparc-break-annulled` | `[pc=<addr-expr>] [coreid=<n>]` | `debug_hook_annulled` (a delay-slot instruction skipped by an untaken annulling branch), firing before PC/nPC update for the skip, so they're still the annulled instruction's own address and what it advances to |

For a rare event, `sparc-break-mae` is the simple, no-thought shortcut.
For anything more specific (a particular kind/address that also faults),
use `sparc-break-mem` with `mae` added.

Omitting `type=` on `sparc-break-trap` stops at whatever cause is raised
first, and that is always the reset trap. This model always asserts a
reset trap at the very start of every run, before any of the program's
own instructions execute, so a bare `sparc-break-trap` reliably catches
that one first rather than whatever cause you actually meant to look
for. Continue once to move past it and reach the next cause the program
itself raises. There is no way yet to break on any cause except one in
particular, filtering that one reset trap out. That kind of negated
condition may be added in the future.

Examples:
```
(gdb) sparc-break pc=0x203c
(gdb) sparc-break-nth pc=0x203c n=10
(gdb) sparc-break-trap type=illegal_instruction
(gdb) sparc-break-mae
(gdb) sparc-break-mem kind=LOAD addr=0x2000:0x2100
(gdb) sparc-break-mem kind=LOAD mae
(gdb) sparc-break-mem kind=IFETCH addr=0x2054
(gdb) sparc-break-mem kind=STORE data=0xdeadbeef
(gdb) sparc-break-annulled pc=0x2038
```

---

## Watchpoints

Both are called "watchpoints" despite very different mechanisms
underneath. From the user's side, both mean "tell me when this changes."

| Command | Syntax | Mechanism |
|---|---|---|
| `sparc-watch-mem` | `addr=<addr-expr> [coreid=<n>]` | true hardware watchpoint, firing the instant the value changes, wherever or whenever that happens (mid-instruction included). Large ranges may silently fall back to a slow software watchpoint if the host has no hardware debug register wide enough |
| `sparc-watch-reg` | `<reg> [value=<hex>] [mask=<hex>] [persist] [coreid=<n>]` | **not** a hardware watchpoint, see below |

This is deliberate: `sparc-watch-reg` is not a real watchpoint. A real
one fires the instant the underlying storage changes, which for a
register can be mid-instruction (e.g. window shuffling), before the
value is architecturally committed. This instead checks `<reg>` once
per instruction, after it has fully completed, the stable, retired
value, comparing it against its value at the previous check:

| Arguments given | Fires |
|---|---|
| *(none)* | on any change from the previous check |
| `value=`/`mask=` | on each transition *into* a matching value (edge-triggered), not on every instruction that merely holds it |
| `value=`/`mask=` + `persist` | on *every* instruction the value/mask condition holds, not just the transition into it, a corner case, but a real one |

Edge-triggered here means "once per transition," not "once for the
whole run." If the value leaves the match and later re-enters it, that
counts as a new transition and fires again. A windowed register (`o0`,
`l3`, and so on) can also appear to re-enter the same value across a
`save`/`restore` even though nothing in the program explicitly wrote it
again, since the physical storage a windowed name refers to rotates with
the register window. Seeing a second stop at what looks like the same
value is expected, not a bug.

Examples:
```
(gdb) sparc-watch-mem addr=0xfffffe0
(gdb) sparc-watch-reg cwp
(gdb) sparc-watch-reg o1 value=0x10000000 mask=0xf0000000
(gdb) sparc-watch-reg o1 value=0x1 persist
```

---

## Probe / print

| Command | Syntax | Shows |
|---|---|---|
| `sparc-print-regs` | `[coreid=<n>]` | full register/PSR dump, works from any frame, not just inside a hook |
| `sparc-print-reg` | `<reg> [coreid=<n>]` | one register's value, either naming scheme |
| `sparc-print-traps` | `[coreid=<n>]` | trap cause, TBR, PC, and the ET/PS/S PSR bits |
| `sparc-print-annulled` | *(none)* | pc/npc/raw instruction word of the annul currently stopped at (`debug_hook_annulled`), not decoded to a mnemonic (annulled instructions are deliberately never decoded by the model itself). Cross-check the pc against an objdump instead |
| `sparc-print-mem-access` | *(none)* | while stopped in `debug_hook_mem_access`: that access's own `kind`, address, word0, word1, MAE, whatever memory reference just completed, even if no register was updated |
| `sparc-print-mem` | `addr=<addr-expr>` | live memory content at `addr`, from anywhere, in hex, however many words the range covers (one, for an exact address) |

Examples:
```
(gdb) sparc-print-regs
(gdb) sparc-print-reg o1
(gdb) sparc-print-reg r9
(gdb) sparc-print-traps
(gdb) sparc-print-annulled
(gdb) sparc-print-mem-access
kind=LOAD address=0xfffffe0 word0=0x1 word1=0x0 MAE=0
(gdb) sparc-print-mem addr=0xfffffe0
(gdb) sparc-print-mem addr=0x2000:0x2020
```

---

## Managing breakpoints/watchpoints

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

---

## GDB itself, briefly

A few native commands worth knowing, independent of anything above:

| Command | Does |
|---|---|
| `break LOCATION if COND` | conditional breakpoint in one line |
| `watch EXPR` | hardware watchpoint, breaks the instant `EXPR`'s value changes |
| `ignore N COUNT` | skip the next `COUNT` hits of breakpoint `N` silently, stopping on hit `COUNT+1`. `ignore N 9` means "stop on the 10th occurrence" (this is exactly what `sparc-break-nth` does internally) |
| `call EXPR` | invoke a real function/method in the debuggee, print its result |
| `continue` / `c` | resume until the next breakpoint/watchpoint |
| `next` / `step` | step one *host* C++ line (steps through driver code, not one simulated SPARC instruction, use a `sparc-break`+`continue` loop for that instead) |
| `bt` | backtrace |
| `delete N` | remove breakpoint/watchpoint `N` |
| `quit` | exit |

Every `sparc-*` command above is built entirely out of these. They're
intuitive names standing in for the underlying condition syntax and
symbol names, not a replacement for knowing them. See
[Debug Support Internals](debug_support_internals.md) for the
implementation.
