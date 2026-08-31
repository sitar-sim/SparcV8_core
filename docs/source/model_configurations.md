# Model Configurations

A block-diagram-level summary of each testbench configuration under
`model/system_models/`, current and planned. See [Model
Components](model_components.md) for what each piece actually is, and
[Model Components Reference](model_components_reference.md) for the
full per-file table.

Each configuration provides two drivers: a `cpp_model` (0-delay
functional) and a `sitar_model` (cycle-timed). The diagrams below are
for the `sitar_model` side, since that's where the structure differs
between configurations. The `cpp_model` side is always a plain,
untimed function-call chain through the same C++ classes.

## core_only

```
Top
 |
 +-- Core (module)
      |
      +-- sparcThread : SparcThread (procedure)
      |    |
      |    +-- 5x VirtualMainMemoryInterface (procedure)
      |
      +-- mainMemory : VirtualMainMemory (procedure)
```

The core talks directly to memory over a procedure handshake, the same
pattern all the way down. No net crossing anywhere, so a fully 0-delay
run is possible with every latency knob at its default.

## core_mmu

```
Top
 |
 +-- System (module)
      |
      +-- core : Core (module)
      |    |
      |    +-- sparcThread : SparcThread (procedure)
      |    |    |
      |    |    +-- 5x VirtualMainMemoryInterface (procedure)
      |    |
      |    +-- mmu : Mmu (procedure)
      |         |
      |         +-- 2x PhysicalMainMemoryInterface (procedure)
      |              |
      |              +-- PullAToken / PushAToken (procedure)
      |
      +-- mainMemory : PhysicalMainMemory (module)
           |
           +-- PullAToken / PushAToken (procedure)

core.requestOut  --requestNet-->  mainMemory.requestIn
core.responseIn  <-responseNet--  mainMemory.responseOut
```

The core talks to the MMU over the same procedure handshake `core_only`
uses. The MMU talks to physical memory over two nets, since
`PhysicalMainMemory` is a module, not a procedure. Crossing a net costs
Sitar's own unavoidable minimum one cycle each way, so even at every
knob's default this configuration cannot reach a fully 0-delay run the
way `core_only` can. See `core_mmu/sitar_model/src/System.sitar`'s own
header comment for the full design and the reasoning behind it.

## core_mmu_devices (planned)

Adds a timer, an interrupt controller, and a serial device as further
sibling submodules of `System`, each reached over its own net pair
through a shared bus. See `Plan_Devices_integration.md`.

## core_l1cache_mmu_devices (planned)

Adds split instruction and data L1 caches between the core and the MMU.
See `Plan_Caches_integration.md`.
