# Model Components Reference

A complete, per-file index of every Sitar design unit (`module` or
`procedure`) in this repo. For each one it lists what it is, where it
lives, what plain C++ class (if any) it wraps, what design unit embeds
it, and its one-line description. See [Model
Components](model_components.md) for the narrative overview this table
indexes. See each file's own header comment for the full detail behind
its one-line description here.

There is one table per configuration, listed top-down: the root module
first, then its children in the order each parent instantiates them,
depth-first. A design unit shared by both configurations (everything
under `sitar_component_models/`) appears in both tables, once per
configuration that uses it.

- **Scope**  
    `common` means the file lives in `model/sitar_component_models/` and
    is translated into every configuration's build, whether or not that
    configuration actually instantiates it. See that folder's own
    build-script comment. `core_only`/`core_mmu` means the file lives
    under that configuration's own `system_models/<config>/sitar_model/src/`.

- **Parent**  
    Names what instantiates this row within the current table's
    configuration, and how many instances. Reads "None (root)" for `Top`.

## core_only

| Design unit | File | Scope | Embedded C++ class | Parent | Description |
|---|---|---|---|---|---|
| **Top** (module) | [`Top.sitar`](../../model/system_models/core_only/sitar_model/src/Top.sitar) | core_only | None | None (root) | The required root module for the `core_only` build. It just instantiates `Core`. |
| **Core** (module) | [`Core.sitar`](../../model/system_models/core_only/sitar_model/src/Core.sitar) | core_only | None | `Top` | Wires `sparcThread` and `mainMemory : VirtualMainMemory` as two parallel procedures sharing a request/response handshake. |
| **SparcThread** (procedure) | [`SparcThread.sitar`](../../model/sitar_component_models/SparcThread.sitar) | common | [`SparcCore`](../../model/cpp_common_code/SparcCore.h) | `Core` (1 instance: `sparcThread`) | The SPARC V8 fetch-decode-execute-trap state machine. Owns 5 `VirtualMainMemoryInterface` instances for ifetch, load, store, atomic, and flush. |
| **VirtualMainMemoryInterface** (procedure) | [`VirtualMainMemoryInterface.sitar`](../../model/sitar_component_models/VirtualMainMemoryInterface.sitar) | common | None | `SparcThread` (5 instances: `ifetchProcedure`, `memReadProcedure`, `memWriteProcedure`, `atomicLoadStoreProcedure`, `flushProcedure`) | Blocking, VM-shaped (`VirtualMemoryRequest`/`Response`) memory-access interface. One `run` per access. Reused across calls. |
| **VirtualMainMemory** (procedure) | [`VirtualMainMemory.sitar`](../../model/sitar_component_models/VirtualMainMemory.sitar) | common | [`MemCore`](../../model/cpp_common_code/MemCore.h) | `Core` (1 instance: `mainMemory`) | Persistent VM-shaped memory model wrapping `MemCore`. `core_only`'s terminal memory node. No MMU sits downstream of it. |

## core_mmu

| Design unit | File | Scope | Embedded C++ class | Parent | Description |
|---|---|---|---|---|---|
| **Top** (module) | [`Top.sitar`](../../model/system_models/core_mmu/sitar_model/src/Top.sitar) | core_mmu | None | None (root) | The required root module for the `core_mmu` build. It just instantiates `System`. |
| **System** (module) | [`System.sitar`](../../model/system_models/core_mmu/sitar_model/src/System.sitar) | core_mmu | None | `Top` | Assembles `Core` and `PhysicalMainMemory` as sibling submodules, connected by two nets. Owns the consolidated latency-knob block for this configuration. |
| **Core** (module) | [`Core.sitar`](../../model/system_models/core_mmu/sitar_model/src/Core.sitar) | core_mmu | None | `System` (1 instance: `core`) | Wires `sparcThread` and `mmu` as two parallel procedures sharing a request/response handshake. Exposes two ports so `mmu` can reach physical memory over nets. |
| **SparcThread** (procedure) | [`SparcThread.sitar`](../../model/sitar_component_models/SparcThread.sitar) | common | [`SparcCore`](../../model/cpp_common_code/SparcCore.h) | `Core` (1 instance: `sparcThread`) | The SPARC V8 fetch-decode-execute-trap state machine. Owns 5 `VirtualMainMemoryInterface` instances for ifetch, load, store, atomic, and flush. |
| **VirtualMainMemoryInterface** (procedure) | [`VirtualMainMemoryInterface.sitar`](../../model/sitar_component_models/VirtualMainMemoryInterface.sitar) | common | None | `SparcThread` (5 instances: `ifetchProcedure`, `memReadProcedure`, `memWriteProcedure`, `atomicLoadStoreProcedure`, `flushProcedure`) | Blocking, VM-shaped (`VirtualMemoryRequest`/`Response`) memory-access interface. One `run` per access. Reused across calls. |
| **Mmu** (procedure) | [`Mmu.sitar`](../../model/sitar_component_models/Mmu.sitar) | common | [`MmuCore`](../../model/cpp_common_code/mmu/MmuCore.h) | `Core` (1 instance: `mmu`) | The Sitar timing model for the MMU. Sits between `SparcThread` and physical memory. Drives `MmuCore`'s step-primitives through real, timed physical accesses. |
| **PhysicalMainMemoryInterface** (procedure) | [`PhysicalMainMemoryInterface.sitar`](../../model/sitar_component_models/PhysicalMainMemoryInterface.sitar) | common | None | `Mmu` (2 instances: `phyMemReadProcedure`, `phyMemWriteProcedure`) | `Mmu`'s own physical-access transaction procedure. Nests one `PushAToken`/`PullAToken` pair to reach `PhysicalMainMemory` over nets. |
| **PullAToken** (procedure) | [`PullAToken.sitar`](../../model/sitar_component_models/PullAToken.sitar) | common | None | `PhysicalMainMemoryInterface` (1 instance: `getPhyMemResponse`) and `PhysicalMainMemory` (1 instance: `getRequest`) | Generic single-token consumer, parameterized by width. Retry-pulls from an inport until it receives exactly one token. |
| **PushAToken** (procedure) | [`PushAToken.sitar`](../../model/sitar_component_models/PushAToken.sitar) | common | None | `PhysicalMainMemoryInterface` (1 instance: `sendPhyMemRequest`) and `PhysicalMainMemory` (1 instance: `sendResponse`) | Generic single-token producer, parameterized by width. Retry-pushes one token onto an outport until there's room. |
| **PhysicalMainMemory** (module) | [`PhysicalMainMemory.sitar`](../../model/sitar_component_models/PhysicalMainMemory.sitar) | common | [`MainMemory`](../../model/cpp_common_code/MainMemory.h) | `System` (1 instance: `mainMemory`) | Persistent PM-shaped memory model wrapping `MainMemory`. `core_mmu`'s terminal memory node, below the MMU, reached over nets rather than a procedure handshake. |

## Notes

- **Module vs. procedure**  
    `Top`, `System`, `Core`, and `PhysicalMainMemory` are `module`s.
    Every other row above is a `procedure`. See the sibling `sitar`
    repo's own documentation for the general module/procedure
    distinction, and `System.sitar`'s own header comment for how it
    plays out in `core_mmu` specifically.

- **Reading "None" in the C++ class column**  
    This applies to every request/response-only or token-only procedure
    (`VirtualMainMemoryInterface`, `PhysicalMainMemoryInterface`,
    `PullAToken`, `PushAToken`) and to the three purely structural
    modules (`Top`, `System`, `Core`). None of these hold a
    functional-model class instance themselves.

- **Why the procedure names differ from the C++ class names**  
    `VirtualMainMemory`, `PhysicalMainMemory`, and `Mmu`'s names
    deliberately differ from the C++ class each one embeds (`MemCore`,
    `MainMemory`, `MmuCore`). Naming a Sitar procedure or module
    identically to a C++ class it embeds has caused real build failures
    in this repo before: injected-class-name shadowing, header-guard
    collisions, and quote-include self-resolution. See each file's own
    header comment and
    [`sitar-procedure-composition`](../../.claude/skills/sitar-procedure-composition/SKILL.md)
    for the general pattern.
