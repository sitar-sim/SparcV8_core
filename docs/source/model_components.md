# Model Components

This section describes the main components in the model, such as the
SparcCore, Mmu, Memory, Caches, and Devices, in detail. For a listing
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
    (`core_mmu`) wraps it with Sitar timing. `PhysicalMainMemory` is a
    module, reached over nets rather than a procedure handshake.

---

## Caches (planned)

Not yet implemented. Split instruction and data L1 caches are planned,
sitting between the core (or the MMU) and main memory. See
`Plan_Caches_integration.md`.

## Devices (planned)

Not yet implemented. A timer, an interrupt controller, and a serial
device are planned. See `Plan_Devices_integration.md`.

---

All component-wise timing configurations are listed in [Model
Configuration Settings](model_configuration_settings.md).
