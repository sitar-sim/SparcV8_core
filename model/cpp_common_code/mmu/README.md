# cpp_common_code/mmu/

The SPARC Reference MMU (Ref Appendix H in the SPARC V8 manual), ported
from AJIT's `mmu/src/Mmu.c` (branch `marshal`) and rewritten as a C++
class. See `Plan_MMU_integration.md` for the porting plan and
`docs/compliance/README.md`'s Issue 4 for the one deliberate functional
deviation from AJIT (atomic load-store permission checking).

## What's what

- **`Mmu.h` / `.cpp`** -- the main class: register map, page-table walk,
  fault-type/permission logic, PTE/PPN encoding, FSR/FAR/OW/R/M
  semantics. Implements `VirtualMemoryInterface` (see
  `../MemoryInterfaces.h`), so it plugs in wherever `SparcStateMachine`
  expects one, and drives whatever's downstream (`MainMemory` today)
  through `PhysicalMemoryInterface` instead -- see that file's own
  comment for the AJIT-bus citation and `Mmu.cpp`'s half-select
  adaptation between the two.
- **`Tlb.h` / `.cpp`** -- the Page Descriptor Cache (PDC): a 4-level
  cache (one level per page-table depth) of already-resolved leaf PTEs,
  purpose-built for this port rather than a port of AJIT's own generic
  associative-memory library.
- **`Addresses.h`** -- MMU-specific constants: register-select decode,
  Control/Fault-Status Register bit layouts, PTE bit fields, Access
  Type/Fault Type enumerations. General SPARC ASI values live in
  `../AsiValues.h` instead, since the (not yet built) caches block needs
  those too.
- **`MmuStats.h` / `.cpp`** -- functional/architectural counters (TLB
  hits/misses per level, walk terminations, faults by type, R/M
  write-backs, register/flush/probe counts, ...), dumped via
  `toString()`. Deliberately excludes anything timing-related.
- **`MmuConfig.h`** -- every compile-time structural/sizing parameter
  (TLB size and associativity per level, the always-cacheable
  Control-Register bit position), in one place, each with a comment
  explaining what it means and where its value came from. See
  "Configuration" below.

## Configuration

### TLB size and associativity: hardwired, not parameters

Every sizing value in `MmuConfig.h` is a compile-time `static const int`,
not a constructor argument, build flag, or config file read at runtime --
`Tlb.h` just declares short local aliases (`LEVEL0_ENTRIES`, ...) pointing
at it, so this is genuinely the one place to look, even though it isn't
runtime-configurable:

- Level 0 (context-table-direct leaves): 2 entries, fully associative.
- Level 1: 4 entries, fully associative.
- Level 2: 16 entries, fully associative.
- Level 3 (ordinary 4KB pages, the common case): 256 entries, 8-way
  set-associative (32 sets x 8 ways).

These follow AJIT's own design doc (`docs/processor/ajit_processor_description.pdf`
in the ajit-toolchain repo, section 4.3) rather than the
`C_multi_core_multi_thread` C model's actual `TlbNew.h` source, which
gives smaller numbers (2/8/16/64) -- see `MmuConfig.h`'s own comment for
the discrepancy; the doc is treated as authoritative here.

Verified these are genuine parameters, not just numbers that happen to
work today: rebuilt and ran the full `validation/C/mmu/` suite (12
tests) with each of `MMU_TLB_LEVEL0/1/2_ENTRIES`, `MMU_TLB_LEVEL3_WAYS`,
and `MMU_TLB_LEVEL3_SETS` changed to a different value in turn (12/12
passing every time, with one expected, documented exception --
`MMU_TLB_LEVEL1_ENTRIES` reduced to 2 makes `selective_flush` fail, not
because of a bug but because that specific test needs at least 4
concurrently-resident level-1 entries to observe staleness at all --
see that test's own file comment; the other 11 tests still pass
unchanged at that size), confirmed a non-power-of-two
`MMU_TLB_LEVEL3_SETS` fails the build via `Tlb.h`'s `static_assert`s,
then reverted to the values above.

The number of hardware threads per core (`NUM_THREADS_PER_CORE`, sizing
`Mmu.h`'s own `MAX_THREADS` register-array alias) lives one level up, in
`../MultiThreadingConfig.h`, since it isn't MMU-specific -- the core's
own register file and a future L1 cache's per-thread state will need the
same number.

If per-testbench-configurable TLB geometry becomes useful later (e.g.
for `6/small_TLB.c`-style eviction/refill tests from AJIT's own suite --
see the MMU validation summary), the natural place to add it is
constructor parameters on `Tlb`, defaulted to `MmuConfig.h`'s values so
every existing caller keeps working unchanged.

### TLB present (compile-time) vs. TLB enabled (runtime)

Two separate knobs, deliberately not one:

- **`MmuConfig.h`'s `MMU_TLB_PRESENT`** (compile-time): does this build
  include TLB hardware at all. The sizing constants above are only
  meaningful when this is true.
- **`Mmu::tlbEnabled`** (runtime, public field, defaults to
  `MMU_TLB_PRESENT`): should the TLB actually be used for this
  particular run. `false` means the TLB is never looked at, updated, or
  flushed -- every access re-walks the page tables directly, and
  `MmuStats`' TLB hit/miss counters stay at zero. Setting it `true` while
  `MMU_TLB_PRESENT` is `false` fails an assertion in `Mmu::tlbActive()`
  (the single choke point every `tlb_` touch goes through) the first
  time the MMU would actually need the TLB, rather than being silently
  ignored.

This is a real, observable part of the model, not just a host-simulation-
speed detail -- disabling the TLB changes `MmuStats`' hit/miss/walk
counters (see the worked example below), even though translation results
themselves are unaffected either way.

Verified: ran all 12 `validation/C/mmu/` tests with `Mmu::tlbEnabled`
forced off (via the `MMU_TLB_ENABLED=0` environment variable `core_mmu`'s
`sparc_sim.cpp` checks purely for this kind of manual testing -- not part
of the documented CLI, and invisible to `run_tests.py`'s normal
invocation) -- 11/12 pass (the exception is `selective_flush`, which is
specifically a TLB-caching test and has nothing to observe with the TLB
off -- not a bug), and `MmuStats` confirms zero TLB hits and misses in
every case, e.g. `access_fault_matrix`:

| | TLB hits (level 1) | TLB misses | Walks (level 1) |
|---|---|---|---|
| Enabled (default) | 829 | 21 | 21 |
| Disabled | 0 | 0 | 850 |

Also verified the assert itself fires: built a `--debug` binary with
`MMU_TLB_PRESENT` temporarily set `false` and `MMU_TLB_ENABLED=1` forcing
`tlbEnabled` true, confirmed it aborts with the expected assertion
message, then reverted.

Note this env-var hook only exists for ad hoc verification during this
round of testing -- there's no permanent, automated regression test that
exercises `tlbEnabled=false` or the present/enabled mismatch assert
(`run_tests.py`'s pass/fail convention only checks guest-visible register/
memory state, not stderr-printed `MmuStats` content or process-abort
behavior). Worth deciding whether that's worth building out properly
later.

## Test coverage

`validation/C/mmu/` (12 tests) covers translation (all four
walk-termination levels), register read/write, the full
access-permission fault matrix, all five probe types, the atomic
load-store compliance deviation, selective flush by type, R/M-bit
write-back, FSR OW-bit / fault-class overwrite priority, context
switching, and the MMU-disabled bypass path -- see that folder's own
tests for exactly what each one checks.

Two real issues were found and resolved while writing this last batch of
tests (both already fixed/decided by the time the tests above were
written, so they're reflected in current behavior, not open items):

- `Mmu::noFaultSuppressesTrap()` checked the wrong ASI (`Supervisor
  Data`, 0x0B, instead of `Supervisor Instruction`, 0x09) against
  Appendix H.3's NF description -- a porting bug, not present in the
  model this was ported from. Fixed.
- `translate()`'s disabled-MMU branch can report `cacheable=true` (via
  the always-cacheable control bit) even though Appendix H.3 says a
  disabled MMU implies all VAs are non-cacheable. This one *is* present
  in the model this was ported from, so it's being kept as-is rather
  than fixed -- see `Plan_MMU_integration.md`'s "Deviations from spec"
  item 6. Currently has no observable effect either way, since no cache
  exists yet to consume `cacheable`.

One instruction-access-fault case (`fsr_iaccess_priority`) needed a
small, deliberate piece of test infrastructure to observe at all: an
ordinary supervisor-mode instruction-fetch fault always traps the
processor (Appendix H.3 excludes ASI 9 from NF suppression), so the only
way to inspect FSR *after* such a fault, before the program halts, is
from inside the trap handler -- the test patches one slot of the
existing boot-time trap table with a 4-instruction handler that reads
FSR and halts. See that test's own file comment for the full reasoning.
