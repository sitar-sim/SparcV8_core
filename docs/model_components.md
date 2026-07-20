# Model Components

An overview of what's in `model/`, and how the pieces relate. See each
subdirectory's own `README.md` for full detail -- this page is the map.

```
model/
  cpp_common_code/   SparcCore -- the core itself. Timing-agnostic.
  cpp_model/          SparcStateMachine -- 0-delay driver, no Sitar.
  sitar_model/        Top/Core/SparcThread/MemoryInterface/MainMemory --
                       Sitar-timed driver, cycle-level (non-pipelined).
```

---

## `cpp_common_code/`: the core itself

`SparcCore` is a pure C++ class implementing SPARC V8 instruction
semantics -- decode dispatch, ALU/FPU operations, trap logic
(`checkExternalTraps()`, `checkInstructionException()`, `executeTraps()`,
following Appendix C's reference algorithms closely, with section
citations throughout the source), and the register file (`Registers.h`,
including windowed integer registers, `f0`-`f31`, and all state
registers). **It has no notion of cycles, timing, or a driving loop of its
own** -- a driver calls its methods in the right order and supplies memory
access itself. This is deliberate: it's the one place ISA semantics live,
shared unmodified by both models below, so a bug fix or new instruction
benefits both.

Also here: `Decoder` (instruction word -> `Opcode`), `MemCore` (flat,
byte-addressed functional memory, used directly by `cpp_model` and wrapped
with timing by `sitar_model`'s `MainMemory`), and
`FloatingPointFunctions.h` (IEEE-754 single/double/quad-precision
arithmetic, quad via `libquadmath`).

---

## `cpp_model/`: the 0-delay functional driver

`SparcStateMachine` drives `SparcCore` through an ordinary
fetch-decode-execute-trap loop, with **zero modeled latency** -- every
instruction "completes" in the same iteration it starts. No Sitar
dependency at all. This is the fast, simple reference to check ISA-level
correctness against; it's what `validation/run_tests.py` uses by default.

---

## `sitar_model/`: the cycle-timed driver

The same `SparcCore`, driven through Sitar with a **simple, non-pipelined
cycle-level timing model**. Structurally:

```sitar
behavior
    [
        run sparcThread;
        $
        log<<endl<<"Core halted.";
        log<<endl<<sparcThread.printInfo();
        $;
        stop simulation;
    ||
        run mainMemory;
    ]
end behavior
```

This is `Core.sitar`'s top-level behavior: `sparcThread` (the state
machine, which owns `SparcCore` plus five memory-interface threads for
ifetch/read/write/atomic/flush) and `mainMemory` (a persistent procedure
owning the actual `MemCore` storage) run as two branches of one **parallel
block**, communicating through a shared request/response struct. Because
they're procedures on branches of the same parallel block -- not modules
connected by ports/nets -- their handshake can complete within a single
phase, i.e. with zero added cycles, before either side's own configured
latency is even applied.

Three independent, additive latency knobs, all ordinary `int >= 0` values
with no special-casing at zero (see
[Performance Modeling](performance_modeling.md) for where to set them and
how to observe the effect):

1. **Opcode latency** -- charged by `SparcThread` for every instruction.
2. **`MemoryInterface.delay`** -- per memory-access channel, on the
   requester side (models interconnect/cache latency).
3. **`MainMemory.delay`** -- the memory's own service time, shared by all
   requesters.

---

## Connecting other components

!!! note "Stub"
    This section is a placeholder. This project models the core only (see
    [What this project offers](index.md#what-this-project-offers)); a
    worked example of connecting an external component to it -- a cache,
    sitting between `SparcThread`'s memory-interface threads and
    `MainMemory` -- is planned for this page, demonstrating the general
    pattern for building a larger Sitar model around this core. Until
    then, the shape of the pattern is already visible in how
    `MemoryInterface` and `MainMemory` connect today (a shared
    `MemAccessInterface` struct plus a request/response valid-bit
    handshake -- see `model/sitar_model/src/cpp_code/MemAccessInterface.h`'s
    header comment for the exact protocol): an interposed cache would be
    another `MainMemory`-like persistent procedure, itself acting as a
    requester to a further `MemoryInterface`/`MainMemory` pair behind it.
