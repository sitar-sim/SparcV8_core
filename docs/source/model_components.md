# Model Components

This section describes the main components in the model, such as the
SparcCore, Mmu, Memory, Caches, Devices, the system bus, and the APARA
engine, in detail. For a listing
of each component's model see [Model Components
Reference](model_components_reference.md).

---

## SparcCore

`SparcCore` is a pure C++ class implementing SPARC V8 instruction
semantics: decode dispatch, ALU/FPU operations (including
quad-precision, via `libquadmath`), trap logic, and the full register
file (windowed integer registers, `f0`-`f31`, and all state
registers). It has no notion of cycles, timing, or a driving loop of
its own. A driver calls its methods in the right order and supplies
memory access itself. This is the one place ISA semantics live, shared
unmodified by both models below, so a bug fix or new instruction
benefits both.

Decode dispatch and trap handling follow Appendix C's ISP pseudocode
closely, with section citations throughout the source. See [SPARC V8
Architecture](sparcv8_architecture.md#appendix-c-in-detail) for the
section-by-section mapping.

Also part of it: `Decoder` (instruction word to `Opcode`),
`FloatingPointFunctions.h` (IEEE-754 arithmetic), and `CoreLogger`
(`SparcCore::logger`, which formats and emits the core's state as a
trace of architectural events, viewable in the [log
viewer](logging.md#the-log-viewer)). Both models below produce the
identical trace format.

- **cpp_model**  
    `SparcStateMachine` drives it through an ordinary
    fetch-decode-execute-trap loop, with zero modeled latency. Every
    instruction completes in the iteration it starts.
- **sitar_model**  
    `SparcThread` drives it through Sitar, with real per-opcode and
    memory-access timing.

---

## Mmu

A Memory Management Unit (MMU) sits between the core and physical
memory, translating the virtual addresses instructions generate into
physical addresses, and enforcing the access permissions recorded in
an in-memory page table. Present only in `core_mmu` and later
configurations that include an MMU.

This project implements the [SPARC Reference
MMU](sparcv8_Architecture_reference_Manual.pdf#page=236), the
suggested (not mandatory) MMU design described in Appendix H: a
3-level page table, a Translation Lookaside Buffer (TLB, the manual's
own term for it is Page Descriptor Cache), MMU control/context/fault
registers addressed through the ASI mechanism, and referenced/modified
(R/M) bit tracking in each page-table entry.

What the model implements:

- The full page-table walk (all 3 levels, terminating early on a valid
  leaf or a fault).
- TLB lookup, with a configurable size and associativity per level,
  and TLB fill on a miss.
- R/M bit write-back on a successful translated access.
- The register map (control, context table pointer, context, fault
  status, fault address).
- Probe and flush handling, and the explicit MMU bypass ASI range.

See `model/cpp_common_code/mmu/README.md` for the full detail.

- **cpp_model**  
    `MmuCore`, a plain C++ class with no notion of cycles or timing,
    is called directly, the same way `MemCore` is called in
    `core_only`.
- **sitar_model**  
    `Mmu` wraps that same `MmuCore` class, driving its step-by-step
    primitives (walk one page-table level, fill the TLB, write back
    R/M) through real, timed physical accesses instead of one instant
    call. `SparcThread` talks to it over the same procedure handshake
    used for memory in `core_only`. Below the MMU, physical memory is
    reached over real Sitar nets. See [Model
    Configurations](model_configurations.md) for the block diagram.

---

## Memory

The model's backing store for main memory. Two implementations exist,
depending on configuration:

- **`MemCore`**  
    Flat, byte-addressed, virtual-address-shaped. Used directly by
    `core_only`.
- **`MainMemory`**  
    Physical-address-shaped (64-bit/doubleword), used only where an
    MMU is present. Wraps a `MemCore` internally and does the
    doubleword/half-select adaptation itself.

- **cpp_model**  
    Called directly, with zero modeled latency.
- **sitar_model**  
    `VirtualMainMemory` (`core_only`) or `PhysicalMainMemory`
    (`core_mmu` and every later configuration) wraps it with Sitar timing. `PhysicalMainMemory` is a
    module, reached over nets rather than a procedure handshake.

---

## Caches

Split instruction and data L1 caches, between the core and the MMU, in
`core_l1cache_mmu_devices`. Both are virtually indexed and virtually
tagged (VIVT): they are looked up with the virtual address, before any
translation, which is what lets them sit above the MMU. Their main
properties:

- **Organization**  
    64-byte lines. By default 512 lines (32 KB) per cache, direct mapped.
    Both size and associativity are run-time options
    (`--icache-lines`, `--icache-ways`, `--dcache-lines`,
    `--dcache-ways`). Replacement is round-robin within a set. The MMU
    context is part of every tag, so the same virtual address in two
    contexts is two different lines.
- **What is cached**  
    Ordinary instruction and data accesses (ASIs 8 to B) to pages the MMU
    says are cacheable. Everything else (MMU registers, the bypass ASIs)
    goes straight to the MMU. Device registers are never cached.
- **Reads**  
    A hit is served by the cache, provided the page's access permissions
    (kept with the line) allow it. A miss reads the whole line through
    the MMU.
- **Writes**  
    Write-through: every store also goes to memory at once. A store miss
    then brings the line into the cache (write-allocate). An atomic
    load-store bypasses the cache, and updates a cached copy of its line.
- **Flushes**  
    Always of a whole cache: a store with ASI `0x10` to `0x14` flushes
    both caches, `0x18` to `0x1C` the instruction cache, the `FLUSH`
    instruction both, and a write to the MMU's registers (except the
    context register) both.
- **Not coherent**  
    The caches do not see memory changed behind their back, for example
    by a bypass store, so a program that does that must flush first (see
    `validation/C/caches/stale_until_flush`). In particular,
    self-modifying code must execute `FLUSH` before running the new
    instructions, as the SPARC manual requires.

The C++ class `L1CachesCore` (`model/cpp_common_code/cache/`) holds
both caches and the whole policy, the same class in both models:

- **cpp_model**  
    Called directly between `SparcStateMachine` and the MMU, with zero
    modeled latency.
- **sitar_model**  
    `L1Caches.sitar` runs the same steps, with each downstream access a
    real, timed transaction with the MMU.

---

## Peripheral Devices

A Timer, a multi-thread Interrupt Controller, and a Serial device, one
shared set on the memory side of the MMU. The C++ class `PeripheralDevicesCore`
(`model/cpp_common_code/devices/`) holds all three, the same class in
both models. In the sitar_model the `PeripheralDevices` module wraps it,
reached through the `SystemBridge` over nets. See [Peripheral
Devices](peripheral_devices.md) for the register-level detail.

---

## System bus

From `core_mmu_devices` on, more than one thing sits below the MMU, so
a bus routes each physical access by its address: to main memory, to
the devices, or (in `sparc_apara`) to the APARA engine. Which address
belongs to which target is defined once, in `SystemAddressMap.h`, and
shared by both models, so the two can never disagree.

- **cpp_model**  
    `SystemBus`, a plain C++ class, called directly, with zero modeled
    latency.
- **sitar_model**  
    `SystemBridge`, a module with one master (the core), carries one
    transaction at a time. `sparc_apara` uses `SystemInterconnect`
    instead, the same bus with several masters (the core and the APARA
    engine's host side), served round robin.

---

## APARA Engine

A four-threaded vector compute engine, with its own instruction and
data memories, designed to work alongside a SPARC processor as an
accelerator. It is modeled in the `apara` configuration on its own and
in `sparc_apara` next to the SPARC core. See [The APARA
Engine](apara/index.md) for the engine itself.

The C++ class `AparaCore` (`model/cpp_common_code/apara/`) holds the
engine's state and executes its instructions, the same class in both
models, like `SparcCore` for the SPARC. In `sparc_apara` two more
classes model the engine's host side, its control unit and its DMA
unit.

- **cpp_model**  
    Runs the engine one bundle (a group of instructions executed
    together) at a time, with zero modeled latency. In `sparc_apara`, the
    engine runs one bundle and its DMA unit moves up to 8 bytes after
    every SPARC instruction.
- **sitar_model**  
    `AparaEngine` models the engine's five-stage pipeline, one module per
    stage, with the hardware's timing rules (see [APARA Timing
    Model](apara/timing_model.md)). In `sparc_apara`, `AparaHost` models
    the control and DMA units, beside the core on the system bus.

---

All component-wise timing configurations are listed in [Model
Configuration Settings](model_configuration_settings.md).
