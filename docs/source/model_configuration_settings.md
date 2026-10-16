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
to physical memory, the caches, the devices, and the APARA engine.

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
the same way (and `Top.sitar`'s for `apara`, which has no `System`). Structural knobs each live in their own compile-time
header instead, listed individually below.

---

**The timing parameters below apply only to the Sitar-timed models
(`sitar_model/`).** The C++ only models (`cpp_model/`) have no notion
of cycles at all, so timing knobs have no effect on them. Structural
parameters apply to both.

## Core

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **Opcode latency**<br>(`DEFAULT_PER_OPCODE_DELAY`, `OPCODE_LATENCY_OVERRIDES`) | [`OpcodeLatencies.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/cpp_code/OpcodeLatencies.h) (shared by every configuration) | Timing | Compile time | Cycles charged per instruction, on top of any separate memory-access latency. Every opcode not listed in `OPCODE_LATENCY_OVERRIDES` gets the default.<br>**Range:** non-negative int. |
| **Memory-interface delay**<br>(`ifetchProcedure.delay`, `memReadProcedure.delay`, `memWriteProcedure.delay`, `atomicLoadStoreProcedure.delay`, `flushProcedure.delay`) | core_only: [`Core.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_only/sitar_model/src/Core.sitar)<br>core_mmu and later: that configuration's own `System.sitar`, e.g. [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | One independent delay per access type (ifetch, load, store, atomic, flush), charged on the requester side, after the response is available. Models core-side interconnect/cache latency between `SparcThread` and whatever it talks to next (`VirtualMainMemory` in `core_only`, the MMU in `core_mmu`).<br>**Range:** non-negative int, per field. |
| **`NUM_THREADS_PER_CORE`** | [`MultiThreadingConfig.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/MultiThreadingConfig.h) | Structural | Compile time | Hardware threads (SMT) per core: how many independent threads, each with its own registers, trap state, and MMU registers, every core models. **Only 1 is supported so far**: every configuration models one thread per core. The multithreaded configurations will allow 1, 2, or 4.<br>**Range:** 1. |

## MMU (`core_mmu` and later)

These settings apply only to configurations that include an MMU:
`core_mmu`, `core_mmu_devices`, `core_l1cache_mmu_devices`, and
`sparc_apara`. In each of them, the runtime knobs below live in that
configuration's own `System.sitar` (the links below are to
`core_mmu`'s).

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **`MMU_TLB_PRESENT`** | [`MmuConfig.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuConfig.h) | Structural | Compile time | Whether this build includes TLB hardware at all. With a TLB present, translations are cached. Without one, every access re-walks the page tables. The sizing constants below only matter when this is true. |
| **TLB sizing**<br>(`MMU_TLB_LEVEL0_ENTRIES`, `MMU_TLB_LEVEL1_ENTRIES`, `MMU_TLB_LEVEL2_ENTRIES`, `MMU_TLB_LEVEL3_WAYS`, `MMU_TLB_LEVEL3_SETS`) | [`MmuConfig.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuConfig.h) | Structural | Compile time | Number of entries at TLB levels 0-2 (each fully associative), and the sets x ways split for level 3 (ordinary 4KB pages).<br>**Range:** `LEVEL0`/`1`/`2_ENTRIES`, `LEVEL3_WAYS`: positive int. `LEVEL3_SETS`: power of two, 1 to 2^19. |
| **`MMU_CONTROL_ALWAYS_CACHEABLE_BIT`** | [`MmuConfig.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuConfig.h) | Structural | Compile time | Which bit of the MMU Control Register's implementation-defined SC field means "always cacheable, regardless of the PTE's own C bit" (Appendix H.3).<br>**Range:** 8-23. |
| **`MmuCore::tlbEnabled`** | cpp_model: [`sparc_sim.cpp`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/cpp_model/src/sparc_sim.cpp) (`MMU_TLB_ENABLED` environment variable) or directly<br>sitar_model: [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) (`core.mmu.mmu.tlbEnabled`) | Structural | Runtime | Whether the (compiled-in) TLB is actually used for a specific run. With it false, every access re-walks the page tables regardless of what's compiled in.<br>**Range:** true/false (false if `MMU_TLB_PRESENT` is false). |
| **`core.mmu.tlbLookupDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | TLB tag-compare cost, charged whether the lookup hits or misses.<br>**Range:** non-negative int. |
| **`core.mmu.pageTableWalkStepDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | Page-table walker control overhead, charged once per level visited on a walk.<br>**Range:** non-negative int. |
| **`core.mmu.tlbFillDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | Cost of inserting a resolved entry into the TLB, on a fresh miss only.<br>**Range:** non-negative int. |
| **`core.mmu.registerAccessDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | An MMU control/context/FSR/FAR register read or write (ASI 4).<br>**Range:** non-negative int. |
| **`core.mmu.flushDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | A TLB invalidate (ASI 3 write). No memory access, since the TLB is write-through.<br>**Range:** non-negative int. |
| **MMU-to-memory interconnect delay**<br>(`core.mmu.phyMemReadProcedure.delay`, `core.mmu.phyMemWriteProcedure.delay`) | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | The interface/interconnect delay between the MMU and main memory. The actual delay is 1 plus the value set here: Sitar always adds a compulsory 1 cycle for communication over a net, on top of whatever additional delay this field specifies.<br>**Range:** non-negative int, per field. |

## Memory

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **`mainMemory.delay`** | core_only: [`Core.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_only/sitar_model/src/Core.sitar)<br>core_mmu and later: that configuration's own `System.sitar`, e.g. [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar) | Timing | Runtime | The memory's own service time, shared by every requester. `VirtualMainMemory.delay` in `core_only`, `PhysicalMainMemory.delay` in `core_mmu` and later.<br>**Range:** non-negative int. |

## Caches (`core_l1cache_mmu_devices` and `sparc_apara`)

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **Cache sizes**<br>(`--icache-lines`, `--icache-ways`, `--dcache-lines`, `--dcache-ways`) | command line, both models (defaults in [`CacheConfig.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/cache/CacheConfig.h)) | Structural | Runtime | Each cache's number of 64-byte lines, and its associativity (1 = direct mapped).<br>**Range:** powers of two, ways no more than lines. Default 512 lines, 1 way. |
| **`--always-cacheable`** | command line, both models (or `SPARC_ALWAYS_CACHEABLE=1` in the environment) | Structural | Runtime | Sets the MMU Control Register's "always cacheable" bit before the run, so ordinary accesses are cached with the MMU disabled. |
| **`core.caches.icacheHitDelay`**, **`core.caches.dcacheHitDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_l1cache_mmu_devices/sitar_model/src/System.sitar) | Timing | Runtime | Cycles charged on an instruction or data cache hit (a data cache hit can be a read or a write).<br>**Range:** non-negative int, default 0. |
| **`core.caches.fillDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_l1cache_mmu_devices/sitar_model/src/System.sitar) | Timing | Runtime | Cycles charged when a line is installed, on top of the line read itself.<br>**Range:** non-negative int, default 0. |

## Bus and devices (`core_mmu_devices` and up)

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **`bridge.delay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu_devices/sitar_model/src/System.sitar) | Timing | Runtime | Cycles the bridge adds to every physical transaction (memory and device alike), on top of the compulsory 1 cycle for each net crossed.<br>**Range:** non-negative int. |
| **`interconnect.delay`** | `sparc_apara`'s [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/sparc_apara/sitar_model/src/System.sitar) | Timing | Runtime | The same as `bridge.delay`, for `sparc_apara`'s two-master interconnect, which replaces the bridge there. Charged to every transaction, from the core or from the APARA engine.<br>**Range:** non-negative int. |
| **`devices.registerAccessDelay`** | [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu_devices/sitar_model/src/System.sitar) | Timing | Runtime | Cycles added to every device register access.<br>**Range:** non-negative int. |
| **`timerTickDivider`** | sitar_model: [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu_devices/sitar_model/src/System.sitar) (`devices.devices.timerTickDivider`)<br>both models: `--timer-tick-divider <n>` on the command line | Structural | Runtime | Core cycles per timer tick (the timer's `clock_in`). In the cpp_model a "cycle" is one instruction.<br>**Range:** positive int, default 1. |
| **`txTicksPerByte`** | sitar_model: [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu_devices/sitar_model/src/System.sitar) (`devices.devices.serial.txTicksPerByte`) | Timing | Runtime | Cycles a transmitted byte keeps the Serial device's `Tx_full` set. 0 sends a byte within the store itself.<br>**Range:** non-negative int, default 1. |
| **Serial I/O**<br>(`--serial-in`, `--serial-out`, `--serial-pty`) | command line, both models | Structural | Runtime | Where received bytes come from and transmitted bytes go. See the [Serial Device](peripheral_devices_serial_device.md#where-the-bytes-go-in-the-simulator) page. |

## APARA engine (`apara` and `sparc_apara`)

The engine's own settings. Each runtime knob is set in one place per
configuration: `Top.sitar` in `apara`, `System.sitar` in `sparc_apara`.
See [APARA Timing Model](apara/timing_model.md) for what each one
models.

| Parameter | Where to modify | Type | Compile time or runtime | Description |
|---|---|---|---|---|
| **Instruction latencies**<br>(the latency table) | defaults in [`AparaTiming.h`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/apara/AparaTiming.h) (`LatencyTable`)<br>apara: `--latency-file <file>` on the command line | Timing | apara: Runtime<br>sparc_apara: Compile time | Cycles a bundle spends in EXEC for each class of instruction (integer add, f32 multiply, divide, ...). A bundle takes its slowest instruction's figure. See [APARA Timing Model](apara/timing_model.md#timing-rules) for the table and the file format.<br>**Range:** positive int, per entry. |
| **`engine.fetch.imemDelay`** | apara: [`Top.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/apara/sitar_model/src/Top.sitar)<br>sparc_apara: [`System.sitar`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/sparc_apara/sitar_model/src/System.sitar) | Timing | Runtime | Cycles between FETCH picking a thread and that thread's line of instructions arriving from IMEM.<br>**Range:** non-negative int, default 0. |
| **`engine.exec.pipelined`** | same | Timing | Runtime | Whether EXEC is internally pipelined (takes a new bundle every cycle), or holds one bundle for its whole latency.<br>**Range:** true/false, default true. |
| **`engine.exec.latency.bankConflictCycles`** | same | Timing | Runtime | Cycles added for each extra access, in one bundle, to the same bank of data memory.<br>**Range:** non-negative int, default 1. |
| **`engine.regfile.tokens`** | same | Timing | Runtime | How many bundles may be in EXEC at once.<br>**Range:** positive int, default 2. |
| **`engine.regfile.interlock`** | same | Structural (for checking only) | Runtime | Whether REGFILE holds a bundle until the registers it uses are free. `false` shows which reads would be hazards without the interlock (see [Hazards](apara/running.md#hazards)): the results stay right (the functional state runs each thread in order), but the timing is no longer the engine's.<br>**Range:** true/false, default true. |

See [Performance Modeling](performance_modeling.md) for how to confirm a
change to any of the timing knobs above actually took effect, and for
the model's own reported performance measures.
