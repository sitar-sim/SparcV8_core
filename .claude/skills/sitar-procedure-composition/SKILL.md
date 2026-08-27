---
name: sitar-procedure-composition
description: Design pattern for building or extending a Sitar timing model in this repo by composing nested run/wait procedure calls, instead of computing timing arithmetically after an instant functional call. Use whenever inserting a new component into an existing Sitar chain, or making an existing procedure's internal multi-step operation (a multi-transaction read-modify-write, a multi-level walk, anything that needs to issue more than one downstream access) take genuine simulated time.
---

# Sitar procedure composition

This is a general Sitar (the sibling hardware-modeling-DSL repo) design
pattern, not specific to any one component in this codebase. It captures
how to give a multi-step operation genuine, composable simulated-time
behavior, and the pitfalls that come up doing it in a codebase that also
has an instant (0-delay) C++ functional model of the same logic.

## The core idea

A Sitar procedure is a generator, not a function: on hitting `wait`, it
suspends and hands control back to the simulation engine; on resume, it
re-enters exactly where it left off. `run someProcedure;` suspends the
*caller* until `someProcedure` itself terminates (or, for a persistent
procedure, until some external condition ends the caller's wait on it).
Nesting these is not a workaround, it's the mechanism: if a multi-step
operation's steps are individually expressed as `run` calls to procedures
that themselves `wait`, the total elapsed time comes out of the
composition automatically. Nothing sums or accounts for latency after the
fact.

**Reject the alternative up front.** A tempting-looking shortcut is: run
the existing instant functional code as one atomic call, then manually
`wait()` some number of cycles computed from counters/stats the call
produced (e.g. "it did 3 page-table-walk steps, so wait 3 * stepDelay").
This works numerically but is the wrong design in a framework built
around genuine `run`/`wait` composition -- it's arithmetic bookkeeping
standing in for structure, doesn't compose with anything downstream that
also has its own real timing, and produces a component that lies about
being a timing model. If the framework supports composing real waits,
compose real waits.

## Two procedure shapes, and when each applies

- **Persistent procedures**: entered once via `run` as a branch of a
  parallel block, and never return -- they service a request/response/
  `valid` handshake in an internal loop for the rest of the simulation.
  Use this for anything that needs to be independently, continuously
  scheduled so something else can reach it via a pointer at any time
  (a memory, a shared resource, anything sitting "on a bus").
- **Function-style procedures**: invoked via `run`, run once, terminate,
  and get re-activated fresh on the next `run` (no auto-reset of instance
  state between calls -- see the field-completeness pitfall below). Use
  this for a single transaction/transition that a caller wants to block
  on synchronously, the same way a plain function call would look if it
  didn't need to consume simulated time.

A single-transaction downstream link (the shape most components need) is
naturally a function-style procedure whose own body does: assemble a
request onto a shared/pointed-at object, set its `valid` bit, `wait until`
the far side's response `valid` bit, consume it, clear both `valid` bits,
then (optionally) `wait(delay, 0)` for its own added latency before
returning. This one shape is reusable for both directions of a request/
response interface (e.g. a "read" instance and a separate "write"
instance sharing the same downstream target) just by fixing which
request field selects the operation at `init` time, rather than writing
two near-duplicate procedure types.

## Composing a multi-step operation

When an existing instant/functional implementation of some multi-step
operation already exists as a plain method (a loop that issues several
reads/writes internally, e.g. a multi-level walk or a multi-transaction
read-modify-write), don't discard it or duplicate its *decision* logic --
restructure it into small, atomic (no downstream access of their own)
step-primitives plus explicit per-transaction primitives, keeping the
original method as a thin driver that calls the atomic steps and the
transaction primitives in a loop, unchanged in behavior. The timed Sitar
procedure then independently walks the *same* step sequence, substituting
a real `run <procedure>;` for each transaction primitive the functional
driver calls directly. Both sides end up calling the same atomic-step
methods; only who performs the actual access, and whether it takes time,
differs.

**Any state that needs to survive a step boundary** (a loop index, a
partially-computed result, anything a step primitive needs on its next
call within the same operation) must be promoted from a function-local
variable to state that survives across a `run` -- either a field on the
embedded class instance being driven, or a procedure-instance-level field
if it's purely about this procedure's own sequencing rather than
intrinsic to the underlying algorithm. A plain C++ local variable does
not survive a `wait`.

## Pitfalls (all found the hard way; check for these when something
compiles strangely or times don't come out right)

**Naming collisions between a Sitar procedure and a C++ class it embeds
or references.** Sitar generates a real C++ class per procedure. Giving
a procedure the same name as a plain C++ class it embeds as a member, or
even just names in an unqualified way, can go wrong in more than one
distinct way:
- *Injected-class-name shadowing*: a member whose declared type equals
  the enclosing class's own name resolves to the enclosing (generated)
  type instead of the real one -- "incomplete type" errors on a field
  that looks perfectly declared.
- *Header-guard collision*: if the C++ class's own header guard macro
  happens to match (or the procedure name maps to an identical guard by
  whatever convention generates one), the real header's contents get
  silently skipped as "already included" the moment the procedure's own
  generated header defines the same guard first.
- *Quote-include self-resolution*: `#include"X.h"` is a quote include, so
  it searches the including file's own directory first. If the Sitar
  translator's own generated output directory contains a same-named file
  (because the procedure is itself named `X`), the include silently
  resolves to that generated stub instead of the real header, and the
  real class is never defined.

The reliable fix for all three is the same: don't name a Sitar procedure
identically to any C++ class, interface, or header it embeds or
interacts with -- pick a name that makes clear it's the *timed wrapper
around* that class, not the class itself.

**No `elsif`.** Sitar's `if` has only `if/then/else/end if`, with `else`
able to contain a nested `if`. A flat multi-way dispatch has to be
written as a nested if/else/end-if chain; miscounting the resulting
`end if`s produces a confusing parse error far away from the actual
mistake (often at the next unrelated control-flow keyword in the file).

**A wrapped class's own "done" side effect can leak through a deliberate
wait.** If a plain C++ class's synchronous method sets some shared "this
is done" flag as its own first action (correct for its original,
non-timed caller), and a Sitar procedure wraps that method's call inside
`response` state that some *other* procedure is polling via that same
flag, the flag can go true before the wrapping procedure's own
`wait(delay, 0)` ever runs -- publishing the response early and letting
whatever's polling consume it and reset the handshake while the wrapper
still thinks it's mid-transaction. If the wrapped call sets a `valid`-
style flag as a side effect, explicitly reset that flag immediately after
calling in, and only set it again for real after the intended wait
completes.

**Function-style procedure state does not reset between `run` calls.**
Since a function-style procedure is "re-activated" rather than
reconstructed, any field the caller doesn't explicitly set before a given
`run` silently carries over whatever the *previous*, possibly unrelated,
invocation left there. The safe convention: the caller sets every field
relevant to the interface at every call site, not just the fields the
current access type happens to need — treat the shared request struct as
fully write-before-use each time, never partially-write-and-trust-the-
rest.

## Latency-knob convention

Declare and default every latency knob (`0`, runtime field, never a
compile-time constant) once, in its owning procedure's own decl/init.
Separately, give the top-level composing module one consolidated,
commented block (in its own `init`, since Sitar's child-then-parent init
order makes the parent's assignment the one that actually sticks) that
lists and sets *every* knob in that configuration in one place — a single
control panel for tuning the whole model, even though each value is also
independently defaulted where it's declared. Note compile-time-only
latency sources there too (as a comment), so the block is a complete
survey of the model's timing surface, not just its runtime-tunable
subset.

## Verifying knob placement, not just knob presence

A latency knob placed on the wrong branch, or charged with the wrong
condition, is invisible in ordinary regression testing as long as the
knob defaults to `0` — zero cycles of delay looks the same everywhere no
matter how many times it's (wrongly) inserted. Passing tests at the
default is necessary but not sufficient evidence a knob's *placement* is
correct. To actually verify placement: read the reference (functional)
implementation's real conditional logic for exactly when the
corresponding real step happens, confirm the `wait` sits on the identical
condition (not just "somewhere near the right operation"), and where
there's ambiguity, do a quantitative A/B check — set the knob to a large,
distinct value, run a test whose exact call pattern you know (e.g. "N
calls of type A, M of type B"), and confirm the cycle-count delta between
the pre- and post-fix versions matches the knob value times the exact
count of calls that should (or shouldn't) be charged. An exact match is
strong evidence the fix removes precisely the intended charge and nothing
else; a mismatch means either the fix or your model of the reference
logic is wrong.

## Worked example in this repo

See `model/sitar_component_models/MmuUnit.sitar` (the timing model) next
to `model/cpp_common_code/mmu/Mmu.{h,cpp}` (the functional model it
restructures into step-primitives) and `Plan_MMU_integration.md`'s "Sitar
timing model" section (the design writeup) for a full, concrete
application of every pattern and pitfall above.
