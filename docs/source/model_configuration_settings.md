---
hide:
  - toc
---

# Model Configuration Settings

The C++ only models (`cpp_model/`) offer pure functionality modeling.
An instruction "completes" the moment it starts, with no notion of how
long it would actually take on real hardware. The Sitar models
(`sitar_model/`) additionally offer component-wise latency modeling:
independent, configurable delay values for opcode execution, each
memory-access channel, and, where present, the MMU and its interconnect
to physical memory.

Some of the settings below are **structural**: they change what the
model *does*, e.g. how many TLB entries exist. Others are **timing**:
they change how long something takes, with no effect on the functional
result. Some can only be changed at **compile time** (edit a header,
rebuild). Others are ordinary runtime fields, given an initial value in
a configuration's own `init` block, but otherwise no different from any
other piece of simulation state, settable at any later point too, e.g.
with a debugger (see [Examining Core State at Runtime Using
GDB](examining_core_state_with_gdb.md)) or from scripted Sitar behavior
code.

---

## Where to set

Most of the timing knobs below are consolidated in one place per
configuration, alongside the wiring that connects the pieces they
belong to: `Core.sitar`'s own `init` block for `core_only`, or
`System.sitar`'s for `core_mmu` and any later configuration assembled
the same way. Structural knobs each live in their own compile-time
header instead, listed individually below.

---

**The timing parameters below apply only to the Sitar-timed models
(`sitar_model/`).** The C++ only models (`cpp_model/`) have no notion
of cycles at all, so timing knobs have no effect on them. Structural
parameters apply to both.

## Core

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **Opcode latency**<br>(`DEFAULT_PER_OPCODE_DELAY`, `OPCODE_LATENCY_OVERRIDES`) | [`OpcodeLatencies.h`](../../model/sitar_component_models/cpp_code/OpcodeLatencies.h) (shared by every configuration) | Timing | Compile time | Cycles charged per instruction, on top of any separate memory-access latency. Every opcode not listed in `OPCODE_LATENCY_OVERRIDES` gets the default.<br>**Range:** non-negative int. |
| **Memory-interface delay**<br>(`ifetchProcedure.delay`, `memReadProcedure.delay`, `memWriteProcedure.delay`, `atomicLoadStoreProcedure.delay`, `flushProcedure.delay`) | core_only: [`Core.sitar`](../../model/system_models/core_only/sitar_model/src/Core.sitar)<br>core_mmu: [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | One independent delay per access type (ifetch, load, store, atomic, flush), charged on the requester side, after the response is available. Models core-side interconnect/cache latency between `SparcThread` and whatever it talks to next (`VirtualMainMemory` in `core_only`, the MMU in `core_mmu`).<br>**Range:** non-negative int, per field. |
| **`NUM_THREADS_PER_CORE`** | [`MultiThreadingConfig.h`](../../model/cpp_common_code/MultiThreadingConfig.h) | Structural | Compile time | Hardware threads (SMT) per core. **Not yet implemented.** The current model has no hyperthreading, 1 thread per core. |

## MMU (`core_mmu` only)

These settings apply only to configurations that include an MMU,
currently `core_mmu` (and, once built, `core_mmu_devices`).

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **`MMU_TLB_PRESENT`** | [`MmuConfig.h`](../../model/cpp_common_code/mmu/MmuConfig.h) | Structural | Compile time | Whether this build includes TLB hardware at all. With a TLB present, translations are cached. Without one, every access re-walks the page tables. The sizing constants below only matter when this is true. |
| **TLB sizing**<br>(`MMU_TLB_LEVEL0_ENTRIES`, `MMU_TLB_LEVEL1_ENTRIES`, `MMU_TLB_LEVEL2_ENTRIES`, `MMU_TLB_LEVEL3_WAYS`, `MMU_TLB_LEVEL3_SETS`) | [`MmuConfig.h`](../../model/cpp_common_code/mmu/MmuConfig.h) | Structural | Compile time | Number of entries at TLB levels 0-2 (each fully associative), and the sets x ways split for level 3 (ordinary 4KB pages).<br>**Range:** `LEVEL0`/`1`/`2_ENTRIES`, `LEVEL3_WAYS`: positive int. `LEVEL3_SETS`: power of two, 1 to 2^19. |
| **`MMU_CONTROL_ALWAYS_CACHEABLE_BIT`** | [`MmuConfig.h`](../../model/cpp_common_code/mmu/MmuConfig.h) | Structural | Compile time | Which bit of the MMU Control Register's implementation-defined SC field means "always cacheable, regardless of the PTE's own C bit" (Appendix H.3).<br>**Range:** 8-23. |
| **`MmuCore::tlbEnabled`** | cpp_model: [`sparc_sim.cpp`](../../model/system_models/core_mmu/cpp_model/src/sparc_sim.cpp) (`MMU_TLB_ENABLED` environment variable) or directly<br>sitar_model: [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) (`core.mmu.mmu.tlbEnabled`) | Structural | Runtime | Whether the (compiled-in) TLB is actually used for a specific run. With it false, every access re-walks the page tables regardless of what's compiled in.<br>**Range:** true/false (false if `MMU_TLB_PRESENT` is false). |
| **`core.mmu.tlbLookupDelay`** | [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | TLB tag-compare cost, charged whether the lookup hits or misses.<br>**Range:** non-negative int. |
| **`core.mmu.pageTableWalkStepDelay`** | [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | Page-table walker control overhead, charged once per level visited on a walk.<br>**Range:** non-negative int. |
| **`core.mmu.tlbFillDelay`** | [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | Cost of inserting a resolved entry into the TLB, on a fresh miss only.<br>**Range:** non-negative int. |
| **`core.mmu.registerAccessDelay`** | [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | An MMU control/context/FSR/FAR register read or write (ASI 4).<br>**Range:** non-negative int. |
| **`core.mmu.flushDelay`** | [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | A TLB invalidate (ASI 3 write). No memory access, since the TLB is write-through.<br>**Range:** non-negative int. |
| **MMU-to-memory interconnect delay**<br>(`core.mmu.phyMemReadProcedure.delay`, `core.mmu.phyMemWriteProcedure.delay`) | [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | The interface/interconnect delay between the MMU and main memory. The actual delay is 1 plus the value set here: Sitar always adds a compulsory 1 cycle for communication over a net, on top of whatever additional delay this field specifies.<br>**Range:** non-negative int, per field. |

## Memory

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **`mainMemory.delay`** | core_only: [`Core.sitar`](../../model/system_models/core_only/sitar_model/src/Core.sitar)<br>core_mmu: [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | The memory's own service time, shared by every requester. `VirtualMainMemory.delay` in `core_only`, `PhysicalMainMemory.delay` in `core_mmu`.<br>**Range:** non-negative int. |

See [Performance Modeling](performance_modeling.md) for how to confirm a
change to any of the timing knobs above actually took effect, and for
the model's own reported performance measures.
