# Model Components

An overview of what's in `model/`, and how the pieces relate. See each
subdirectory's own `README.md` for full detail. This page is the map.
See [Model Components Reference](model_components_reference.md) for a
complete, per-file table of every Sitar module/procedure. It lists what
each one wraps, what can embed it, and in which configuration(s).

```
model/
  cpp_common_code/          SparcCore and SparcStateMachine. Timing-agnostic.
                              mmu/ holds the MMU's own MmuCore class.
  sitar_component_models/    VirtualMainMemoryInterface/VirtualMainMemory/
                               SparcThread, the reusable Sitar procedures
                               every configuration is built from. Where an
                               MMU is present, also Mmu/
                               PhysicalMainMemoryInterface/PhysicalMainMemory,
                               plus PullAToken/PushAToken, two generic
                               single-token I/O procedures.
  system_models/
    core_only/
      cpp_model/               SparcStateMachine driving MemCore directly,
                                 0-delay, no Sitar.
      sitar_model/              Top/Core wiring the shared Sitar procedures
                                  together, cycle-level (non-pipelined).
    core_mmu/
      cpp_model/               SparcStateMachine driving SparcCore through
                                 an MmuCore instance instead of MemCore.
      sitar_model/              Top/System/Core, with the MMU reaching
                                  physical memory over real Sitar nets.
```

See [Model Configurations](model_configurations.md) for a block diagram
of each configuration listed above.

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
byte-addressed functional memory, used directly by the `core_only`
configuration's `cpp_model` and wrapped with timing by
`VirtualMainMemory.sitar` in `sitar_component_models/`),
`FloatingPointFunctions.h`
(IEEE-754 single/double/quad-precision arithmetic, quad via
`libquadmath`), and `CoreLogger` (`SparcCore::logger`, which formats and,
depending on how a driver configures it, emits this core's state as a
trace of architectural events). Both drivers below produce the identical
trace format, viewable in the [log viewer](logging.md#the-log-viewer).

---

## `cpp_model/`: the 0-delay functional driver

`SparcStateMachine` (`cpp_common_code/`, reused unchanged by every
configuration's `cpp_model`) drives `SparcCore` through an ordinary
fetch-decode-execute-trap loop, with **zero modeled latency**. Every
instruction "completes" in the same iteration it starts, and that
iteration, one complete instruction execution, is counted and reported
as 1 "cycle" by the built executable (see `--max-cycles`/its halt
message). This is purely an iteration count, with no notion of how long a
real instruction or memory access would actually take, unlike the Sitar
model below where a cycle is an actual elapsed clock cycle. No Sitar
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

This is `core_only/sitar_model/src/Core.sitar`'s top-level behavior:
`sparcThread` (the state machine, which owns `SparcCore` plus five
memory-interface threads for ifetch/read/write/atomic/flush) and
`mainMemory` (a persistent procedure owning the actual `MemCore` storage)
run as two branches of one **parallel block**, communicating through a
shared request/response struct, alongside a third branch that watches for
`sparcThread` halting (its own procedure never returns, it loops forever
across `RESET`/`EXECUTE`/`ERROR` by design) and stops the simulation once
it does. `sparcThread` and `mainMemory` are procedures on branches of the
same parallel block, not modules connected by ports/nets. Because of
that, their handshake can complete within a single phase, meaning zero
added cycles, before either side's own configured latency is even
applied. `sparcThread` and `mainMemory` themselves are reusable
components, from `sitar_component_models/`; `Top.sitar`/`Core.sitar`
(this composition) are the part that's specific to the `core_only`
configuration and would look different in another configuration.

Three independent, additive latency knobs, all ordinary `int >= 0` values
with no special-casing at zero (see
[Performance Modeling](performance_modeling.md) for where to set them and
how to observe the effect):

1. **Opcode latency**. Charged by `SparcThread` for every instruction.
2. **`VirtualMainMemoryInterface.delay`**. Per memory-access channel, on the
   requester side (models interconnect/cache latency).
3. **`VirtualMainMemory.delay`**. The memory's own service time, shared by all
   requesters.

---

## The MMU (`core_mmu` only)

`Mmu` (`sitar_component_models/Mmu.sitar`) wraps `MmuCore`
(`cpp_common_code/mmu/MmuCore.h`/`.cpp`), the SPARC Reference MMU: the
register map, the page-table walk, TLB lookup and fill, fault and
permission checking, and probe and flush handling. `SparcThread` talks to
it exactly the way it talks to `VirtualMainMemory` in `core_only`, over
the same procedure handshake. Below the MMU, `PhysicalMainMemory` is a
module, not a procedure, reached over two nets. See [Model
Configurations](model_configurations.md) for the block diagram, and
`core_mmu/sitar_model/src/System.sitar`'s own header comment for the
full design and the latency this net crossing adds.

---

## Connecting other components

!!! note "Stub"
    This section is a placeholder. A worked example of connecting an
    external component to the core, a cache sitting between
    `SparcThread`'s memory-interface procedures and `VirtualMainMemory`, is
    planned for this page. It will demonstrate the general pattern for
    building a larger Sitar model around this core. Until then, the
    shape of the pattern is already visible in how `VirtualMainMemoryInterface`
    and `VirtualMainMemory` connect today. They share a request/response
    struct pair (`VirtualMemoryRequest`/`VirtualMemoryResponse`, see
    `model/cpp_common_code/MemoryInterfaces.h`) plus a valid-bit
    handshake. See that file's header comment for the exact protocol.
    An interposed cache would be another `VirtualMainMemory`-like
    persistent procedure, itself acting as a requester to a further
    `VirtualMainMemoryInterface`/`VirtualMainMemory` pair behind it. A
    component reached over real nets instead, like `core_mmu`'s own
    `PhysicalMainMemory`, follows a different pattern. See [The
    MMU](#the-mmu-core_mmu-only) above and
    `core_mmu/sitar_model/src/System.sitar`'s own header comment.
