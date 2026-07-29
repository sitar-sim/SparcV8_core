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

**Address/PC arguments** (`pc=`, `addr=`) take a single value, one of
three forms (not two separate options, `0x2000/0xfffff000` is one
`addr=` value with a literal `/` in it):

| Form | Meaning |
|---|---|
| `0x2054` | exact match: `addr == 0x2054` |
| `0x2000:0x2100` | half-open range: `addr >= 0x2000 && addr < 0x2100` |
| `0x2000/0xfffff000` | masked match: `(addr & mask) == (base & mask)` |

Every numeric value anywhere in these commands, addresses included,
accepts hex (`0x...`), binary (`0b...`), or plain decimal, the same
`int(x, 0)` base auto-detection Python and C both use. `pc=0x203c`,
`pc=0b10000000000111100`, and `pc=8252` all name the same address.

The third form describes the same *kind* of thing as the second, a
contiguous range, just as a base address plus a bitmask instead of
explicit bounds. `0x2000/0xfffff000` means "every address whose top 20
bits match `0x2000`'s", which is the 4096-byte-aligned block
`0x2000:0x3000`, the same range the `lo:hi` form above would write
directly. The mask must be of the trailing-zero form `0xfff...000`
(the zero bits are what's allowed to vary), so this only ever describes
a power-of-2-sized, power-of-2-aligned range, never an arbitrary one.

Given that `lo:hi` can already express any range, `base/mask` exists for
one specific reason: it's the only form `sparc-watch-mem` can turn into
a single real hardware watchpoint, since a debug register only ever
watches a power-of-2-aligned region, not an arbitrary `lo:hi` span. Use
`lo:hi` for breakpoint filters (a software comparison, any range is
fine), and `base/mask` specifically when you need `sparc-watch-mem` to
watch more than one word at once. For a range that genuinely isn't
contiguous or power-of-2-aligned, use several breakpoints/watchpoints
instead.

## Register-name syntax

**Register-name arguments** accept windowed mnemonics (`g0`-`g7`,
`o0`-`o7`, `l0`-`l7`, `i0`-`i7`), flat SPARC r-numbering (`r0`-`r31`,
where `r1`==`g1`, `r9`==`o1`, the same numbering `Registers::R_r()`
itself uses), or the specials `pc`, `npc`, `y`, `psr`, `wim`, `tbr`.

## `coreid=`

`coreid=` is offered on anything that relates to a specific `SparcCore`
instance, and withheld from anything that relates to `MemCore` instead,
since memory isn't owned per-core in this model at all (there is exactly
one `MemCore` regardless of core count):

- **SparcCore-related, `coreid=` supported**: every breakpoint command
  (`sparc-break`, `sparc-break-nth`, `sparc-break-trap`,
  `sparc-break-mae`, `sparc-break-mem`, `sparc-break-annulled`, since
  each hook still receives the initiating core even for a memory event),
  plus `sparc-print-regs`, `sparc-print-reg`, `sparc-print-traps`, and
  `sparc-watch-reg`, which read a core's own register/PSR/trap state.
- **MemCore-related, no `coreid=`**: `sparc-watch-mem`,
  `sparc-print-mem`.

It means two different things depending on which side it's on. For the
*breakpoint* commands, `coreid=` is a **filter** on the hook's own
`core.coreID`, omit it and any core matches. For the *probe/print* and
`sparc-watch-reg` commands, `coreid=` is a **selector** into the runtime
registry that finds a live `SparcCore` to read from (see
[Debug Support Internals](debug_support_internals.md)), there's no "no
selection" concept there, so it defaults to `0`.

---

## Breakpoints

| Command | Syntax | Stops at |
|---|---|---|
| `sparc-break` | `pc=<addr-expr> [coreid=<n>]` | `debug_hook_after_execute` (an instruction has fully executed, PC/nPC not yet advanced) when PC matches |
| `sparc-break-nth` | `pc=<addr-expr> n=<k> [coreid=<n>]` | same, but only the k-th match actually stops (gdb's own `ignore` under the hood) |
| `sparc-break-trap` | `[type=<name>] [coreid=<n>]` | `debug_hook_trap_raised`, optionally filtered to one cause (see below) |
| `sparc-break-mae` | `[coreid=<n>]` | `debug_hook_mem_access` with `core.MAE` set, any kind, any address |
| `sparc-break-mem` | `[kind=<k>] [addr=<addr-expr>] [data=<hex>] [mae] [coreid=<n>]` (`<k>` is `ifetch`, `load`, `store`, `atomic`, or `flush`) | `debug_hook_mem_access`, filtered by any combination of kind/address/data (`word0`)/fault |
| `sparc-break-annulled` | `[pc=<addr-expr>] [coreid=<n>]` | `debug_hook_annulled` (a delay-slot instruction skipped by an untaken annulling branch), firing before PC/nPC update for the skip, so they're still the annulled instruction's own address and what it advances to |

For `sparc-break-trap`, `type=` is one of the same cause names
`core.printTrap()` itself reports:

`reset_trap` &middot; `data_store_error` &middot; `instruction_access_error` &middot;
`r_register_access_error` &middot; `instruction_access_exception` &middot;
`privileged_instruction` &middot; `illegal_instruction` &middot; `fp_disabled` &middot;
`cp_disabled` &middot; `unimplemented_FLUSH` &middot; `window_overflow` &middot;
`window_underflow` &middot; `mem_address_not_aligned` &middot; `fp_exception` &middot;
`cp_exception` &middot; `data_access_error` &middot; `data_access_exception` &middot;
`tag_overflow` &middot; `division_by_zero` &middot; `trap_instruction` &middot;
`external_interrupt`. Omit `type=` for any cause.

For a rare event, `sparc-break-mae` is the simple, no-thought shortcut.
For anything more specific (a particular kind/address that also faults),
use `sparc-break-mem` with `mae` added.

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
per instruction, at `debug_hook_after_execute`, the stable, retired
value, comparing it against its value at the previous check:

| Arguments given | Fires |
|---|---|
| *(none)* | on any change from the previous check |
| `value=`/`mask=` | once, on the transition *into* a matching value (edge-triggered) |
| `value=`/`mask=` + `persist` | on *every* instruction the value/mask condition holds, not just the transition into it, a corner case, but a real one |

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
| `sparc-print-regs` | `[coreid=<n>]` | full register/PSR dump (`CoreLogger::print_state()`), works from any frame, not just inside a hook |
| `sparc-print-reg` | `<reg> [coreid=<n>]` | one register's value, either naming scheme |
| `sparc-print-traps` | `[coreid=<n>]` | trap cause (`core.printTrap()`), TBR, PC, and the ET/PS/S PSR bits |
| `sparc-print-annulled` | *(none)* | pc/npc/raw instruction word of the annul currently stopped at (`debug_hook_annulled`), not decoded to a mnemonic (annulled instructions are deliberately never decoded by the model itself). Cross-check the pc against an objdump instead |
| `sparc-print-mem-access` | *(none)* | while stopped in `debug_hook_mem_access`: that access's own `kind`, address, word0, word1, MAE, whatever memory reference just completed, even if no register was updated |
| `sparc-print-mem` | `addr=<addr-expr>` | live memory content at `addr`, from anywhere, in hex, however many words the range covers (one, for an exact address) |

`kind` above is printed upper case (`LOAD`/`STORE`/`ATOMIC`/`IFETCH`/
`FLUSH`), the `DebugMemAccessKind` enum's own name, even though it's
typed lower case when used as a `sparc-break-mem` filter.

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
