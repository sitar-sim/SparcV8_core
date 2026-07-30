# Debug Support Internals

[Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md)
covers *using* gdb with this model. This page covers how that support is
actually built: the four hook points every `sparc-*` breakpoint command
ultimately rests on, why `--debug` stays at `-O3` instead of rebuilding
everything at `-O0`, and how any command can reach a live `SparcCore`/
`MemCore` from any stopped frame. Useful if you're extending
`debug/sparc.gdb` itself, or just curious how it works.

---

## The four hook points

Four named, otherwise-empty functions declared in
`model/cpp_common_code/DebugHooks.h` are called from the same points in
the instruction loop that `CoreLogger` logs from:

- `debug_hook_after_execute(core, op)`: an instruction has fully
  executed (registers/memory/PSR all updated), but before PC/nPC advance
  to the next instruction. Also fires for an instruction that raised a
  trap partway through, matching `CoreLogger`'s own `EXECUTED` event.
- `debug_hook_trap_raised(core)`: a trap has just been detected, before
  `SparcCore::selectTrap()` clears the trap-cause flags or computes
  `TBR`'s `tt` field, so those flags (not `TBR`) are what's actually
  inspectable here.
- `debug_hook_mem_access(core, kind, address, word0, word1)`: a memory
  reference of the given `DebugMemAccessKind` (`IFETCH`/`LOAD`/`STORE`/
  `ATOMIC`/`FLUSH`) has just completed. A sub-event within
  `debug_hook_after_execute`'s instruction, not an alternative to it.
- `debug_hook_annulled(core)`: a delay-slot instruction was skipped by
  an untaken annulling branch, never fetched-for-real or decoded, so
  there is no `Opcode` to pass. Fires before PC/nPC update for the skip.

Not every `CoreLogger` event needs one of these. A native gdb `watch` (a
hardware watchpoint on a memory location or register) or a plain `break
... if COND` already reaches "PC/register/memory reaches a value" just
fine, no hook needed. What's left, and does need a hook, is state-machine
*transitions* that aren't a single value changing, exactly the four
above. Together they cover every way one iteration of the fetch-decode-
execute loop can conclude.

Each function exists purely so gdb has a stable place to break on *by
name*, instead of a source file:line, which drifts every time the driver
code is edited (and doesn't exist at all for the Sitar model, whose
driver is generated C++). Nothing about them is gdb-specific: plain
`-g`/DWARF info plus a `noinline` symbol works under any debugger, gdb is
simply the one this repository documents and ships convenience commands
for.

Only real (and only then declared `noinline`, so the optimizer can't
fold the empty body away and remove the breakpoint target) when built
with `-DSPARC_DEBUG_HOOKS_ENABLED` (`--debug`/`--debug-o0`). Otherwise
each is a plain empty inline function, calls to it compile away to
nothing, the same zero-cost-when-unused principle as `CoreLogger`'s own
logging gate.

---

## Build modes: `--debug` vs. `--debug-o0`

`--debug` adds `-g` but deliberately *stays* at `-O3` otherwise. gdb's
`call`/`print` of a live function is generally unreliable against
optimized code (inlining and register allocation can make an argument or
local unavailable, or the function itself gone entirely), but a handful
of functions the `sparc-*` commands actually rely on calling this way are
individually pinned to `-O0` in their own definitions, via
`__attribute__((optimize("O0")))`:

- `Registers::R_r()`, plus the six special-register accessors
  `R_PC()`/`R_nPC()`/`R_Y()`/`R_PSR()`/`R_WIM()`/`R_TBR()`
- `CoreLogger::print_state()`
- `SparcCore::printTrap()`
- `MemCore::wordPtr()`
- `DebugRegistry::findCoreByID()`/`firstMemCore()`

So the rest of the simulator stays fast, and only these few pay the
`-O0` cost, exactly the functions `sparc-print-regs`, `sparc-print-reg`,
`sparc-print-traps`, `sparc-watch-reg`, and `sparc-print-mem` call into.
Every one of the seven register accessors needs its own pin. They're
equally trivial one-line getters, but the optimizer only keeps a
standalone, callable copy of the ones it has a reason to, and nothing
else in the simulator happens to call some of them directly. Without the
attribute, gdb's inferior call to a fully inlined one fails outright.

If you need to debug something *outside* the four hook points, an
arbitrary breakpoint or single-step deep inside `SparcCore` itself,
where `-O3`'s inlining and register allocation make local variables
unreliable to inspect directly, use `--debug-o0` instead. It rebuilds
the whole binary at `-O0`. It's slower, only worth it for that kind of
deep dive, not everyday use.

---

## `DebugRegistry`

Every `sparc-*` command is reachable from *any* stopped frame, in either
model, without caring who constructed the `SparcCore`/`MemCore` or which
frame it's lexically reachable from. `model/cpp_common_code/DebugRegistry.h`
is what makes that possible: `SparcCore` and `MemCore` register
themselves there, once, in their own constructors. This is why
`coreid=` on the probe/print commands is a **selector** (an index into
this registry). There's no "currently in scope" frame to fall back on,
unlike the breakpoint commands, which read `core` directly out of the
hook they're attached to and use `coreid=` only as a **filter** on top
of that.

---

## Reading a `std::string` back from the debuggee

`print_state()` and `printTrap()` both return a `std::string` by value.
Reading that back from gdb needs care, twice over:

- gdb's own pretty-printer quotes and backslash-escapes embedded
  newlines, and truncates past `print elements` (200 by default), wrong
  for a multi-line dump. `debug/sparc.gdb` reads `.c_str()` directly
  instead (see its `core_string()` helper).
- The returned `std::string` is a temporary living in the *inferior's*
  own memory. A later, unrelated inferior call can reuse or clobber that
  scratch space before a lazily-held `gdb.Value` ever gets read.
  `core_string()` reads it out to a real Python string immediately,
  before that can happen.

See [`debug/sparc.gdb`](https://github.com/sitar-sim/SparcV8_core/blob/main/debug/sparc.gdb)
for the implementation, and its own
[README](https://github.com/sitar-sim/SparcV8_core/blob/main/debug/README.md).
