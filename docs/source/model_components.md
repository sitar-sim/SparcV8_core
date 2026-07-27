# Model Components

An overview of what's in `model/`, and how the pieces relate. See each
subdirectory's own `README.md` for full detail. This page is the map.

```
model/
  cpp_common_code/   SparcCore, the core itself. Timing-agnostic.
  cpp_model/          SparcStateMachine, 0-delay driver, no Sitar.
  sitar_model/        Top/Core/SparcThread/MemoryInterface/MainMemory,
                       Sitar-timed driver, cycle-level (non-pipelined).
```

---

## `cpp_common_code/`: the core itself

`SparcCore` is a pure C++ class implementing SPARC V8 instruction
semantics. This includes decode dispatch, ALU/FPU operations, trap logic
(`checkExternalTraps()`, `checkInstructionException()`, `executeTraps()`,
following Appendix C's reference algorithms closely, with section
citations throughout the source), and the register file (`Registers.h`,
including windowed integer registers, `f0`-`f31`, and all state
registers). **It has no notion of cycles, timing, or a driving loop of its
own.** A driver calls its methods in the right order and supplies memory
access itself. This is deliberate: it's the one place ISA semantics live,
shared unmodified by both models below, so a bug fix or new instruction
benefits both.

Also here: `Decoder` (instruction word -> `Opcode`), `MemCore` (flat,
byte-addressed functional memory, used directly by `cpp_model` and wrapped
with timing by `sitar_model`'s `MainMemory`), `FloatingPointFunctions.h`
(IEEE-754 single/double/quad-precision arithmetic, quad via
`libquadmath`), and `CoreLogger` (`SparcCore::logger`, which formats and,
depending on how a driver configures it, emits this core's state as a
trace of architectural events). Both drivers below produce the identical
trace format, viewable in the [log viewer](logging.md#the-log-viewer).

---

## `cpp_model/`: the 0-delay functional driver

`SparcStateMachine` drives `SparcCore` through an ordinary
fetch-decode-execute-trap loop, with **zero modeled latency**. Every
instruction "completes" in the same iteration it starts. No Sitar
dependency at all. This is the fast, simple reference to check ISA-level
correctness against. It's what `validation/run_tests.py` uses by default.

---

## `sitar_model/`: the cycle-timed driver

The same `SparcCore`, driven through Sitar with a **simple, non-pipelined
cycle-level timing model**. Structurally:

```sitar
behavior
    [
        run sparcThread;
    ||
        run mainMemory;
    ||
        wait until (sparcThread.HALT.VALUE);
        wait until (this_phase==1);
        $
        log<<endl<<"Core halted.";
        log<<endl<<sparcThread.printInfo();
        $;
        stop simulation;
    ]
end behavior
```

This is `Core.sitar`'s top-level behavior: `sparcThread` (the state
machine, which owns `SparcCore` plus five memory-interface threads for
ifetch/read/write/atomic/flush) and `mainMemory` (a persistent procedure
owning the actual `MemCore` storage) run as two branches of one **parallel
block**, communicating through a shared request/response struct, alongside
a third branch that watches for `sparcThread` halting (its own procedure
never returns, it loops forever across `RESET`/`EXECUTE`/`ERROR` by
design) and stops the simulation once it does. `sparcThread` and
`mainMemory` are procedures on branches of the same parallel block, not
modules connected by ports/nets. Because of that, their handshake can
complete within a single phase, meaning zero added cycles, before either
side's own configured latency is even applied.

Three independent, additive latency knobs, all ordinary `int >= 0` values
with no special-casing at zero (see
[Performance Modeling](performance_modeling.md) for where to set them and
how to observe the effect):

1. **Opcode latency**. Charged by `SparcThread` for every instruction.
2. **`MemoryInterface.delay`**. Per memory-access channel, on the
   requester side (models interconnect/cache latency).
3. **`MainMemory.delay`**. The memory's own service time, shared by all
   requesters.

---

## Connecting other components

!!! note "Stub"
    This section is a placeholder. This project models the core only (see
    [Models](index.md#models)). A
    worked example of connecting an external component to it, a cache
    sitting between `SparcThread`'s memory-interface threads and
    `MainMemory`, is planned for this page. It will demonstrate the
    general pattern for building a larger Sitar model around this core.
    Until then, the shape of the pattern is already visible in how
    `MemoryInterface` and `MainMemory` connect today. They share a
    `MemAccessInterface` struct plus a request/response valid-bit
    handshake (see `model/sitar_model/src/cpp_code/MemAccessInterface.h`'s
    header comment for the exact protocol). An interposed cache would be
    another `MainMemory`-like persistent procedure, itself acting as a
    requester to a further `MemoryInterface`/`MainMemory` pair behind it.
