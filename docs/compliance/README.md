# docs/compliance/

This folder holds **AJIT processor project** tests (unmodified originals,
copied from `tests/verification/ajit32/instruction_tests/` in the
`ajit-toolchain` repository -- see `validation/asm/README.md` for
general AJIT attribution) that we've moved *out* of `validation/` because our
model does not reproduce AJIT's own expected results for them, for specific,
well-understood reasons described below. We believe **our model is the one
that is correct per the SPARC V8 manual** in each case, and AJIT's own
reference diverges from it -- but since these are AJIT's tests and captured
from AJIT's own hardware/reference model, we're keeping them here (rather
than deleting or silently "fixing" them) specifically so this can be shared
with and reviewed by the AJIT project's authors.

Four independent issues are documented here so far:

1. [FSR accrued-inexact (`aexc.nxa`) tracking](#issue-1-fsr-accrued-inexact-aexcnxa-tracking) -- 10 floating-point tests.
2. [PSR `impl`/`ver` fields writable by `WRPSR`](#issue-2-psr-implver-fields-writable-by-wrpsr) -- 2 `RDPSR`/`WRPSR` tests.
3. [Quad-precision (`FADDQ` etc.) is implemented here, unimplemented in AJIT](#issue-3-quad-precision-faddq-etc-is-implemented-here-unimplemented-in-ajit) -- 14 tests.
4. [Atomic load-store (LDSTUB/SWAP) permission-fault checking](#issue-4-atomic-load-store-ldstubswap-permission-fault-checking) -- design-level deviation in the MMU, not yet backed by a side-by-side test pair (see the issue for why).

Unlike `validation/`, this folder's `.hex` files are *not* committed (see
`docs/compliance/.gitignore`) -- these are reference/evidence tests, not the
maintained suite, so run `validation/build_hex.py <path>` (requires the
sparc-elf toolchain) before `validation/run_tests.py <path>` on anything
under here for the first time.

## Issue 1: FSR accrued-inexact (`aexc.nxa`) tracking

**Our own model's accrued-inexact behavior is now also asserted directly
against the manual, independent of this AJIT comparison** -- see
`validation/asm/floating_point/fp_exceptions/accrued_inexact.s`. That test
doesn't compare against AJIT's expected values at all; it exercises a
genuinely inexact op with `NXM=0` and checks `aexc.nxa` accumulates while
`cexc.nxc` (the *current*-op-only field) gets overwritten by a later,
exception-free op -- directly demonstrating the current-vs-accrued
distinction that's the crux of this whole issue. Everything below this
point is the original AJIT-diff writeup and evidence, kept as-is for AJIT's
authors to review.

Every test below fails on exactly **one** check: the final value stored to
memory at `m[0x0004]`, which is the FSR (Floating-point State Register)
snapshotted partway through the test via `st %fsr, [addr]`. Every other
register/memory check in every one of these tests **passes** -- the actual
floating-point *arithmetic results* our model computes are bit-for-bit
identical to AJIT's own expected values in every case. Only the FSR's
accrued-inexact bookkeeping differs.

### What's actually happening

Each test in this set performs at least one FP arithmetic operation whose
result is not exactly representable in the target precision (a completely
ordinary, common occurrence -- most decimal values, and most sums/products of
already-rounded floating-point values, are not exactly representable). Per
IEEE 754, this must set the "inexact" (NX) exception. The SPARC V8 FSR has
two places this shows up:

- `cexc` (current exception, FSR bits 4:0): reflects only the *most recently
  completed* FPop.
- `aexc` (accrued exception, FSR bits 9:5): a **sticky** OR-accumulator that
  is only ever cleared by software (e.g. an explicit `LDFSR`) -- it keeps
  every exception bit set by *any* FPop since it was last cleared, as long as
  that exception's trap-enable bit was off (masked) at the time.

Each test in this set sets `NVM` (invalid-trap-enable, FSR bit 27) so it can
also exercise a genuine invalid-operation trap later on (that part matches
AJIT's expected results exactly, `g2` and `ftt` included). But `NXM`
(inexact-trap-enable) is never set. So when the earlier, genuinely-inexact
arithmetic op executes, per the manual it must silently set `aexc.nxa`
(FSR bit 5) -- accumulating, and staying set -- without trapping (since NXM
is 0). AJIT's own expected FSR value for these tests does **not** have that
bit set; ours does, and that's the entire, sole difference in every one of
these 10 tests.

### Why we believe this makes AJIT's reference non-conformant, not ours

The SPARC V8 manual (Chapter 4, "FSR Conformance") states an implementation
may pick one of exactly two conformance strategies for the `TEM`/`aexc`/`cexc`
fields:

> (1) Implement all three fields conformant to ANSI/IEEE Standard 754-1985.
> (2) Implement the **NXM, nxa, and nxc bits of these fields conformant to
> ANSI/IEEE Standard 754-1985**. Implement each of the remaining bits in the
> three fields either (a) Conformant to the ANSI/IEEE Standard, or (b) As a
> state bit that may be set by software...

Both options require inexact (`NXM`/`nxa`/`nxc`) tracking to be genuinely
IEEE-754 conformant -- there is no variant of the two permitted strategies
under which an implementation may skip or simplify accrued-inexact tracking
specifically. So we don't think this is a matter of "AJIT chose a different
but still valid implementation option" -- as far as we can tell, there isn't
a manual-sanctioned reading under which omitting `aexc.nxa` accumulation is
compliant.

Our own implementation computes this by bracketing each single/double-
precision FP operation with the host CPU's own IEEE-754 exception flags
(`feclearexcept`/`fetestexcept` in `<cfenv>`) rather than reimplementing IEEE
754 rounding/exception rules by hand -- see the file-level comment in
`model/cpp_common_code/FloatingPointFunctions.h` for the full rationale. We
independently double-checked the specific case below directly against the
host FPU outside of our simulator, get the same answer, and it matches
standard IEEE-754 double-precision arithmetic, so we're fairly confident this
isn't a bug on our side.

## Worked example: `add/faddd.s`

The test (PSR: `NVM=1`, all other trap-enables 0) does, among other things:

```asm
set A, %l0              ! A = 4.3 (double)
set B, %l1               ! B = 8.2 (double)
...
faddd %f0, %f2, %f4      ! f4:f5 = 4.3 + 8.2
```

`4.3` and `8.2` are each already-rounded `double` approximations of their
decimal values (neither is exactly representable in binary). Checked directly
against the host FPU (independent of our simulator):

```
4.3 + 8.2 = 12.50000000000000000000   FE_INEXACT raised: yes
```

Even though the *displayed* rounded result looks like a "clean" 12.5, the
addition of the two stored double values is not exact at the bit level (their
individual rounding errors don't exactly cancel), so IEEE 754 -- and
therefore the SPARC V8 FSR, per the conformance requirement above -- must
record this add as inexact. `NXM` is never enabled in this test, so this
should accumulate silently into `aexc.nxa` (FSR bit 5) without trapping.

- **`add/faddd.vprj`** (AJIT's original, unmodified expected results):
  `m[0x0004]=0x00004010` (masked to the low 16 bits: `ftt`=1 + `nvc`=1 from
  the test's later, deliberate invalid-operation case; `nxa` bit **not** set)
- **`add/faddd.our_model.vprj`** (identical file, only the `m[0x0004]` line
  changed to what our model actually produces): `m[0x0004]=0x08004030`
  (adds `NVM` bit 27 -- expected, we set it -- and bit 5, `nxa`, from the
  `4.3+8.2` add above; masked to the same low 16 bits as AJIT's check:
  `0x4030` vs AJIT's `0x4010`, a difference of exactly bit 5)

Run `validation/run_tests.py docs/compliance/instruction_tests` yourself to see
this directly: every `*.vprj` here fails against our model, and every
matching `*.our_model.vprj` (identical file, single differing `m[0x0004]`
line) passes.

## All 10 affected tests

`add/faddd.s`'s `4.3 + 8.2` case above is the one we checked directly against
the host FPU outside of our simulator (see the worked example). The other 9
follow the identical pattern -- same test structure, `NVM=1`/`NXM=0`, an
earlier ordinary FP op, one deliberate invalid-operation case later on -- and
each uses operands that are self-evidently inexact for the operation being
performed, so we're confident in them by inspection even without
individually re-deriving each one by hand outside the simulator:

| Test | Operation, and why it's inexact |
|---|---|
| `add/faddd.s` | `4.3 + 8.2` (double) -- verified directly against the host FPU (see above) |
| `div/fdivd.s` | `4.3 / 8.2` (double) -- quotient of two non-power-of-2 decimals |
| `div/fdivs.s` | `4.3 / 8.2` (single) -- same reasoning, single precision |
| `mul/fmuld.s` | `4.3 * 8.2` (double) -- product of two non-power-of-2 decimals |
| `mul/fmuls.s` | `4.3 * 8.2` (single) -- same reasoning, single precision |
| `sqrt/fsqrtd.s` | `sqrt(5.0)` (double) -- irrational, no finite binary representation |
| `sqrt/fsqrts.s` | `sqrt(5.0)` (single) -- same reasoning, single precision |
| `fp2int/fdtoi.s` | converting `7.6`/`-3.9` (double) to int necessarily discards the fractional part |
| `fp2int/fstoi.s` | same, single precision |
| `fpConverts/fdtos.s` | narrowing a double with more precision than single can hold |

Every one of these follows the exact same pattern as the worked example
above: one ordinary, unavoidably-inexact FP operation earlier in the test,
`NXM` never enabled, and AJIT's expected FSR simply doesn't show `aexc.nxa`
accumulating from it.

## What we'd like from AJIT's authors

We'd appreciate confirmation of whether this is a known simplification in
AJIT's own FPU/reference model (in which case we'd like to understand the
reasoning, since we read the manual's conformance section as not permitting
it), or a genuine gap worth fixing on AJIT's side. Until then, we're treating
our own model's behavior here as correct and are not "fixing" these tests to
match AJIT's values, since doing so would mean deliberately breaking IEEE 754
conformance to match a reference we believe is the one that's actually wrong
-- and, as of `validation/asm/floating_point/fp_exceptions/accrued_inexact.s`,
this is no longer only an informal cross-check against the host FPU (see
"Our own implementation computes this by..." above): it's a maintained,
always-run assertion of the behavior we believe the manual requires.

## Issue 2: PSR `impl`/`ver` fields writable by `WRPSR`

`misc/rd_wr_psr/RDPSR_WRPSR.s` and `RDPSR_WRPSR_2.s` write a value with a
non-zero top byte to the PSR via `WRPSR`, then read it back via `RDPSR` and
expect the top byte to come back unchanged (i.e. that the entire 32-bit value
written is fully writable/readable). Our model does not reproduce this: it
implements the top byte (PSR bits 31:24, the `impl`/`ver` fields) as
hardwired to `0x00`, and `WRPSR` only ever updates bits 23:0. Every other
check in both tests passes -- `g1` (normal exit), the illegal-instruction and
privileged-instruction trap handling (`g2`/`g3`), and `o4`. Only the fields
that read back the (attempted) top byte -- `o0`, `o1`, `o3` -- differ, and
only in that top byte.

### What the manual says

Chapter 4 ("PSR_implementation (impl)" and "PSR_version (ver)"):

> Bits 31 through 28 are hardwired to identify an implementation or class of
> implementations of the architecture. The hardware should not change this
> field in response to a WRPSR instruction.
>
> Bits 27 through 24 are implementation-dependent. The ver field is either
> hardwired to identify one or more particular implementations or is a
> readable and writable state field whose properties are implementation-
> dependent.

So for bits 31:28 (`impl`), the manual is unconditional: `WRPSR` **must not**
change them, full stop -- there's no reading under which a real
implementation could make them behave as ordinary writable storage the way
this test expects. For bits 27:24 (`ver`), the manual explicitly allows
*either* choice (hardwired, or a writable implementation-defined field); our
model picked "hardwired" (the simpler, and arguably more common, choice for
a from-scratch model with no specific real silicon to imitate), while this
particular AJIT test implicitly assumes "writable." That half of the
divergence (`ver`) is a legitimate implementation choice rather than a
manual violation on AJIT's part -- but since both halves of the byte are
tested together as a single 8-bit field in this test (every affected check
is a whole `0xXX......` word, not individual nibbles), we can't route around
just the `impl` portion without changing the test's actual assembly, so both
tests are documented here as a single combined issue.

### Worked example

`RDPSR_WRPSR.s` executes (PSR fields ET=1,PS=1,S=1 initially, i.e. `0xE0`):

```asm
set 0xAAAA00EF, %l0
wr   %l0, 0x0F, %psr     ! psr <- %l0 XOR 0x0F = 0xAAAA00E0
...
rd   %psr, %o0           ! AJIT expects o0 = 0xAAAA00E0
```

Per the manual, bits 31:24 of `0xAAAA00E0` (`0xAA`) must not be written by
`WRPSR` at all. Our model's PSR resets with `impl`/`ver` = `0x00`, so after
this `WRPSR`, only the low 24 bits (`0xAA00E0`) actually change, giving
`o0 = 0x00AA00E0` -- a difference of exactly the top byte, `0xAA` vs `0x00`.
The same reasoning applies to the second `wr`/`rd %psr,%o1` pair
(`0xFFFF00E0` -> our model reads back `0x00FF00E0`), and to `o3` (which
re-reads the same PSR value after a `WRPSR` that traps illegal_instruction
and therefore leaves PSR unchanged from the `o1` write).

- **`rd_wr_psr/RDPSR_WRPSR.vprj`** (AJIT's original, unmodified): `o0=0xAAAA00E0`, `o1=0xFFFF00E0`, `o3=0xFFFF00E0`
- **`rd_wr_psr/RDPSR_WRPSR.our_model.vprj`** (identical file, only `o0`/`o1`/`o3` changed): `o0=0x00AA00E0`, `o1=0x00FF00E0`, `o3=0x00FF00E0`

`RDPSR_WRPSR_2.s` is the same test rewritten to remove the branch-delay-slot
structure around each `wr`/`rd` pair (presumably to additionally exercise
`WRPSR`'s non-branch-adjacent timing); the PSR read/write values and the
divergence are identical, so `RDPSR_WRPSR_2.vprj`/`.our_model.vprj` mirror
the same three fields.

Run `validation/run_tests.py docs/compliance/instruction_tests/misc/rd_wr_psr`
yourself to see this directly: both original `.vprj` files fail against our
model on exactly these three checks, and both matching `.our_model.vprj`
files pass.

### Incidental note: `RDPSR_WRPSR_2.vprj`'s `SOURCES` line

While preparing this writeup we noticed `RDPSR_WRPSR_2.vprj`'s original
`SOURCES` line reads `RDPSR_WRPSR.s`, not `RDPSR_WRPSR_2.s` -- so as
originally captured, this second test doesn't actually exercise its own
`.s` file's branch-delay-slot variant at all, independent of the PSR
divergence above. We've preserved this exactly as-is in the copies here
(this folder holds unmodified originals), but corrected it in
`validation/asm/misc/rd_wr_psr/RDPSR_WRPSR_2.vprj` (which
also carries the `o0`/`o1`/`o3` fix above) so that the maintained copy of
this test actually covers what it's named for.

### What we'd like from AJIT's authors

Confirmation of whether AJIT's own PSR implementation genuinely has a fully
writable `impl` field (in which case it may be worth checking against the
manual's "hardware should not change this field" wording), and/or whether
`ver` being writable is a deliberate implementation choice on AJIT's part
(which the manual does permit) -- in which case this is simply a documented
incompatibility between two valid implementations rather than something
either side needs to "fix."

## Issue 3: Quad-precision (`FADDQ` etc.) is implemented here, unimplemented in AJIT

This one is a deliberate difference in scope, not a bug on either side, but
it's worth documenting the same way since it means a whole set of AJIT's own
tests can't be run against this model unmodified.

AJIT's processor does not implement the SPARC V8 quad-precision (128-bit)
floating-point instructions in hardware. Its own test suite reflects this:
`tests/verification/ajit32/instruction_tests/floating_point/unimplemented/`
holds 14 tests (`faddq`, `fsubq`, `fmulq`, `fdivq`, `fdmulq`, `fsqrtq`,
`fcmpq`, `fcmpeq`, `fitoq`, `fstoq`, `fdtoq`, `fqtoi`, `fqtos`, `fqtod`)
whose entire premise is that executing any of these instructions traps
(`fp_exception` with `FSR.ftt = unimplemented_FPop`) rather than computing a
result.

This project implements quad precision for real (see `model/cpp_common_code/FloatingPointFunctions.h`
and the top-level `README.md`'s Acknowledgments section), so none of these
14 instructions trap in our model -- each one actually executes and produces
a genuine IEEE-754 quad-precision result. Copied here (unmodified) are all
14 of AJIT's own `unimplemented/` tests, alongside a `*.our_model.vprj` for
each showing what our model actually produces.

### The pattern, in every one of the 14 tests

Every test in this set follows the same structure: load fixed bit patterns
into a set of source `%f` registers, execute the instruction under test
twice (both operand orders), store `%fsr` to memory after each, then check
`%g2` (incremented by the `fp_exception` trap handler -- see
`HW_trap_0x08: inc %g2; rett %r18;` in each `.s` file) and the two stored
`%fsr` snapshots. In every case:

- Every check on the **source** registers (`f0`-`f7`, the values loaded
  before the instruction under test runs) passes identically in both models
  -- these are untouched by the divergence.
- Every check that depends on **whether a trap occurred** (`g2`, and the two
  `m[...]` FSR snapshots) fails: AJIT expects `g2=2` (trap handler ran twice)
  and `FSR=0xC000` (`unimplemented_FPop`, twice); our model, having actually
  executed the instruction, never traps, so `g2` stays `0` and both FSR
  snapshots are whatever the real (non-exceptional) computation left in FSR
  (`0x0` in every one of these tests -- none of the specific bit patterns
  used happens to raise an FP exception on the host FPU we bracket the
  computation with).
- The **destination** registers (`f8`-`f15`) are where the real work shows:
  AJIT expects them to stay `0` (never written, since the instruction
  trapped before completing); ours contain the actual quad-precision result.

### Worked example: `fdmulq.s`

Unlike most of the other 13 tests (which load an arbitrary bit pattern like
`0x0000000A` into the source registers purely to check it passes through
untouched), `fdmulq.s` loads real IEEE-754 **double**-precision values --
`4.3` into `f0:f1` and `8.2` into `f2:f3` -- and executes `fdmulq %f0, %f2,
%f8` (multiply two doubles, produce a quad result):

- **AJIT's expected result** (`fdmulq.vprj`): `f8`-`f14 = 0` (never written --
  the instruction was expected to trap before completing).
- **Our model's actual result** (`fdmulq.our_model.vprj`):
  `f8=0x40041a14 f9=0x7ae147ae f10=0x0a51eb85 f11=0x1eb85200 f12=0xc0019ccc f13=0xcccccccc f14=0xc8000000`
  -- the genuine 128-bit product of `4.3 * 8.2 = 35.26` computed at full
  quad precision.

Run `validation/run_tests.py docs/compliance/instruction_tests/floating_point/unimplemented`
yourself to see this directly: all 14 original `.vprj` files fail (on
exactly `g2` + the two FSR snapshots, as described above), and all 14
matching `.our_model.vprj` files pass.

### All 14 affected tests

| Test | Instruction | Notes |
|---|---|---|
| `faddq.s` | `FADDQ` (add) | placeholder bit-pattern operands |
| `fsubq.s` | `FSUBQ` (subtract) | placeholder bit-pattern operands |
| `fmulq.s` | `FMULQ` (multiply) | placeholder bit-pattern operands |
| `fdivq.s` | `FDIVQ` (divide) | placeholder bit-pattern operands |
| `fdmulq.s` | `FDMULQ` (double x double -> quad) | real double operands (`4.3 * 8.2`) -- see worked example |
| `fsqrtq.s` | `FSQRTQ` (square root) | placeholder bit-pattern operand |
| `fcmpq.s` | `FCMPQ` (compare) | placeholder bit-pattern operands; no destination register, only `%fcc` |
| `fcmpeq.s` | `FCMPEQ` (compare, exception on unordered) | same as `fcmpq.s` |
| `fstoq.s` | `FsTOq` (single -> quad) | placeholder bit-pattern operand |
| `fdtoq.s` | `FdTOq` (double -> quad) | placeholder bit-pattern operand |
| `fqtoi.s` | `FqTOi` (quad -> integer) | placeholder bit-pattern operand |
| `fqtos.s` | `FqTOs` (quad -> single) | placeholder bit-pattern operand |
| `fqtod.s` | `FqTOd` (quad -> double) | placeholder bit-pattern operand |
| `fitoq.s` | *(see note below -- doesn't actually test `FITOQ`)* | see note below |

### Incidental note: `fitoq`/`fsubq` don't test what their names say, in AJIT's own original corpus

While preparing this writeup we found two more pre-existing mismatches in
AJIT's original files (independent of the quad-precision divergence itself,
and present exactly as we received them):

- **`fitoq.s`**'s own header comment reads `! instruction = FCMPq`, and its
  body executes `fcmpq %f0, %f4` -- not `fitoq` at all. On top of that,
  **`fitoq.vprj`**'s `SOURCES` line points to `fqtoi.s`, not `fitoq.s`. So as
  originally captured, there is no working AJIT test for `FITOQ`
  (integer-to-quad conversion) at all -- neither the `.s` nor the `.vprj`
  actually exercises it. Our `fitoq.our_model.vprj` here mechanically
  reflects what `fitoq.vprj`'s own `SOURCES` line actually runs (`fqtoi.s`),
  for a direct side-by-side comparison with the original; it does not
  independently exercise `FITOQ` either, since there's no original AJIT
  `FITOQ` test to compare against in the first place.
- **`fsubq.vprj`**'s `SOURCES` line points to `fmulq.s`, not `fsubq.s` (even
  though `fsubq.s` itself is a perfectly correct, independent `FSUBQ` test).
  Same treatment: `fsubq.our_model.vprj` mirrors `fsubq.vprj`'s own
  (mistaken) `SOURCES` for a fair comparison against the original.

We're not correcting these two `SOURCES` mismatches here since, unlike the
`RDPSR_WRPSR_2` case in Issue 2, there's no maintained copy of these
particular tests living on in `validation/` for the fix to matter to --
`validation/`'s own quad-precision tests (see the top-level `README.md`'s
Acknowledgments and `validation/asm/README.md`) are original tests written for
this project, not adaptations of AJIT's `unimplemented/` suite, and already
give real coverage of `FITOQ` and `FSUBQ` on their own. Flagging this purely
in case it's useful to AJIT's own test-suite maintenance.

### What we'd like from AJIT's authors

Nothing to resolve here, really -- this is an intentional scope difference
(AJIT's hardware doesn't implement quad precision; this from-scratch model
does), not a disagreement about correct behavior. Documented mainly so it's
clear *why* these particular 14 AJIT tests can't be adopted into this
project's `validation/` suite unmodified, and so the `fitoq`/`fsubq`
`SOURCES` mismatches noted above are visible somewhere in case they're
useful to fix upstream.

## Issue 4: Atomic load-store (LDSTUB/SWAP) permission-fault checking

Unlike the three issues above, this one isn't evidenced by a side-by-side
`.vprj` pair yet -- it was found while porting the MMU block
(`model/cpp_common_code/mmu/`), before this project's own MMU-specific
validation tests existed to demonstrate it directly. It's recorded here
now, in the same spirit as the others, because it's a genuine, understood
functional divergence from AJIT's own MMU (`mmu/src/Mmu.c`, branch
`marshal`), not because we have a failing/passing test pair to point at
yet. We'll add one (`docs/compliance/instruction_tests/mmu/...` or
similar) once the MMU validation suite exists and can exercise the
specific page-permission setup this needs.

### What AJIT's MMU actually does

Checked directly against AJIT's source: an atomic load-store dispatches
through `ThreadInterface.c`'s `lockAndReadData64()`, which calls into
`cpuDcacheAccess()` / `Mmu()` for the read half, permission-checked as a
**load** (AT = "Load from ... Data Space"). Only afterwards does a
separate, unlocked `writeData()` call perform the write half,
permission-checked as a **store** (AT = "Store to ... Data Space"). These
are two independent calls into the MMU, each with its own permission
check, not one atomic operation as far as the MMU's fault logic is
concerned.

The consequence: on a page whose ACC value permits load access but not
store access, AJIT's atomic load-store lets the read complete -- the
value is fetched and, per `lockAndReadData64()`'s name, the memory
location is locked against other threads -- and only the second, write
half of the operation faults. The read has already happened (and the
lock has already been taken) before the fault is raised.

### What the manual says

Appendix H's Access Type (AT) field (p.257) has exactly 8 values, and no
distinct value for "atomic load-store":

```
AT                        Access Type
 0     Load from User Data Space
 1     Load from Supervisor Data Space
 2     Load/Execute from User Instruction Space
 3     Load/Execute from Supervisor Instruction Space
 4     Store to User Data Space
 5     Store to Supervisor Data Space
 6     Store to User Instruction Space
 7     Store to Supervisor Instruction Space
```

So the manual leaves an implementation to decide how an atomic
load-store's *single* memory reference maps onto this load/store-only
AT space -- but Chapter 6.2 ("Total Store Ordering") is explicit that,
functionally, it is a single reference with two facets, not two separate
ones:

> An atomic load-store (SWAP or LDSTUB) behaves like both a load and a
> store. It is placed in the Store Buffer like a store, and it blocks the
> processor like a load. ... When memory services an atomic load-store,
> it does so atomically: no other operation may intervene between the
> load and store parts of the load-store.

And Chapter 7.2 ("Trap Models"), describing the default trap model every
implementation must support, states that all traps must be precise, with
exactly four named exceptions -- one of which specifically names atomic
load-store:

> (3) An exception caused after the primary access of a multiple-access
> load/store instruction (load/store double, atomic load/store, and
> SWAP) may be interrupting if it is due to a "non-resumable
> machine-check" exception. Thus, a trap due to the second memory access
> can occur after the processor or memory state has been modified by the
> first access.

The carve-out is narrow and explicit: it covers only non-resumable
machine-check exceptions (a hardware error class this model doesn't
implement at all), not ordinary MMU protection/privilege faults. Reading
the two passages together: the manual treats an atomic load-store as one
memory reference that "behaves like both a load and a store," happens
"atomically" with nothing allowed to intervene between its two halves,
and whose default trap model requires an ordinary fault on it to be
precise. AJIT's split-transaction behavior -- a real, unlocked read that
completes and becomes externally visible before the store half's
permission is even checked -- doesn't satisfy that for an ordinary
protection or privilege fault, which isn't one of the four listed
exceptions.

### What this model does instead

`Mmu::translate()` (`model/cpp_common_code/mmu/Mmu.cpp`) checks an atomic
load-store as a single, precise operation: it computes the fault type
for the access's primary AT (store, since LDSTUB/SWAP unconditionally
write memory) and, only if that check passes, additionally checks the
opposite-direction AT (load) against the same PTE before allowing the
access to proceed. If *either* direction would fault, the whole operation
faults before any memory access happens at all -- no read is performed,
no value becomes visible, and the target byte/word is left completely
unmodified. See `Mmu::translate()`'s and `Mmu.h`'s own comments for the
implementation.

### Worked (hypothetical) example

Set up a page whose PTE has `ACC = 2` (Read/Execute for both user and
supervisor, per Appendix H.3's ACC table -- no write access at all. Ref
Appendix H.5's ACC/AT permission matrix: AT 4 and 5, both stores, fault
under ACC 2; AT 0/1, both loads, do not). Execute `LDSTUB` against an
address on that page from user or supervisor data space:

- **AJIT's behavior**: the read half (AT 0 or 1, a load) passes
  permission-checking against `ACC = 2` and completes -- the byte's
  existing value is fetched and the location is locked. Only the write
  half (AT 4 or 5, a store) then fails against `ACC = 2`, and the fault
  is raised at that point. The read has already happened.
- **This model's behavior**: `translate()` checks the store direction
  first (AT 4/5), which already fails against `ACC = 2` -- so the fault
  is raised immediately, before any read is attempted. Nothing is read,
  nothing is locked, memory is untouched.

Both models ultimately raise a `data_access_exception` for this access --
the divergence is entirely in whether the read half is allowed to
complete and have a side effect (the memory read, and the lock) before
the fault is recognized.

### What we'd like from AJIT's authors

Confirmation of whether the two-call, independently-permission-checked
structure of `lockAndReadData64()`/`writeData()` was a deliberate
implementation choice (in which case we'd like to understand how it's
reconciled with Chapter 7.2's precise-trap requirement for ordinary MMU
faults on this instruction class), or simply a natural consequence of the
MMU's calling convention not having a "check both directions before
either memory access" primitive available to the two call sites. Either
way, we believe our own dual-permission-check behavior is the one
required by the manual for this case, and are implementing it that way
rather than mimicking AJIT's split-transaction behavior functionally.
