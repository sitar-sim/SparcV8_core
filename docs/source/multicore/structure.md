# Model Structure and Assumptions

This page describes how the `multicore` configuration is put together
in each of its two models, and lists the assumptions the model makes
where AJIT's own design was not followed or is not yet modeled. It
builds on the single-core structure described in [Model
Configurations](../model_configurations.md#configuration-core_l1cache_mmu_devices).

---

## The system

Every core of the `multicore` configuration is the core of
`core_l1cache_mmu_devices`, with its own split L1 caches and its own
MMU. Below the MMUs, one shared bus connects all the cores to one main
memory and one set of peripheral devices.

```
  core 0          core 1          core 2          core 3
  L1 I/D caches   L1 I/D caches   L1 I/D caches   L1 I/D caches
  MMU             MMU             MMU             MMU
    |               |               |               |
  ==+===============+===============+===============+==  shared bus
                    |                       |
               main memory          peripheral devices
                (256 MB)      (Timer, Serial, Interrupt Controller,
                                         Scratch-pad)
```

A cache hit stays inside its core. A cache miss, every store (the
caches are write-through), every uncached access, and every access to a
device goes over the shared bus.

---

## The cpp_model

The cpp_model builds `NUM_CORES` copies of the single-core
configuration's chain of C++ objects, one per core. Each copy holds a
`SparcCore`, its `SparcStateMachine`, an `L1CachesCore` and an
`MmuCore`. Every core's `MmuCore` is connected to the same
[`SystemBus`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/SystemBus.h)
object, which sends each access to main memory or to the devices by its
address, exactly as in the single-core configurations.

The cpp_model runs on one host thread. A
[`Scheduler`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/multicore/cpp_model/src/Scheduler.h)
picks which core executes next and for how many instructions. Every
access completes before the next one starts, so the bus never has two
requests at once and needs no arbitration. The [Execution
Model](execution_model.md) page describes the scheduling strategies.

---

## The sitar_model

### Modules and nets

`System` holds `NUM_CORES` copies of the single-core configuration's
`Core` module, as a Sitar `submodule_array`. Each `Core` contains the
SPARC core, its L1 caches and its MMU as procedures, so a cache hit
never leaves the core. Below the MMUs sits a `CoherentBridge`, the
shared bus, and below it one main memory and one set of peripheral
devices.

<pre>
<a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/multicore/sitar_model/src/Top.sitar">Top</a>
 |
 +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/multicore/sitar_model/src/System.sitar">System</a> (module)
      |
      +-- cores[NUM_CORES] : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/multicore/sitar_model/src/Core.sitar">Core</a> (module, one per core)
      |    |
      |    +-- sparcThread : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SparcThread.sitar">SparcThread</a> (procedure)
      |    |
      |    +-- caches : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/L1Caches.sitar">L1Caches</a> (procedure)
      |    |
      |    +-- mmu : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/Mmu.sitar">Mmu</a> (procedure)
      |
      +-- bridge : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/CoherentBridge.sitar">CoherentBridge</a> (module)
      |
      +-- mainMemory : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PhysicalMainMemory.sitar">PhysicalMainMemory</a> (module)
      |
      +-- devices : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PeripheralDevices.sitar">PeripheralDevices</a> (module)
</pre>

Each core has four nets of its own, and the bus reaches memory and the
devices over four more. Each net carries data from an output port to an
input port.

| Net | From | To |
|---|---|---|
| `coreRequestNet[i]` | `cores[i].requestOut` | `bridge.coreRequestIn[i]` |
| `coreResponseNet[i]` | `bridge.coreResponseOut[i]` | `cores[i].responseIn` |
| `interruptLevelNet[i]` | `devices.interruptLevelOut[i]` | `cores[i].interruptLevelIn` |
| `coreInvalidateNet[i]` | `bridge.coreInvalidateOut[i]` | `cores[i].invalidateIn` |
| `memoryRequestNet` | `bridge.memoryRequestOut` | `mainMemory.requestIn` |
| `memoryResponseNet` | `mainMemory.responseOut` | `bridge.memoryResponseIn` |
| `devicesRequestNet` | `bridge.devicesRequestOut` | `devices.requestIn` |
| `devicesResponseNet` | `devices.responseOut` | `bridge.devicesResponseIn` |

`System` sets each core's ID in its `init` block, so `cores[i]` is core
`i`.

### The shared bus

`CoherentBridge` does the work of the single-core configuration's
`SystemBridge` for several cores. It has one request port and one
response port for each core. It takes one request at a time, reads its
physical address, forwards it to main memory or to the devices, and
returns the answer to the core that asked. Its timing is
`SystemBridge`'s, so with one core running, the `multicore` sitar_model
reproduces `core_l1cache_mmu_devices` cycle for cycle.

When several cores have requests waiting, the bridge grants them in
**round-robin** order. Starting from the port after the last one
granted, it checks each port in turn, skips a port with no request
waiting, and grants the first one that has a request.

The bridge is named after AJIT's coherent memory controller, which
plays the same role.

### The bus lock

The bridge makes `LDSTUB` and `SWAP` atomic across cores. Each of these
instructions reads a location and then writes it, and in the
sitar_model those are two separate bus transactions, so another core
could otherwise come in between them. The core's MMU marks the read
with a `lock` bit, as AJIT's does.

A read with the `lock` bit set locks the bus to the core that made it,
and that core's next request releases it. While the bus is locked, the
bridge looks only at that core's port, so every other core's requests
wait, whichever address they are for. As in AJIT's bridge, there is one
lock for the whole bus, and it belongs to a core. This is coarser than
atomicity strictly needs, since two atomic instructions on unrelated
addresses need not exclude each other, but it is simple and it covers
main memory and the devices alike.

The lock holds no extra time beyond the two transactions, so it changes
no timing when only one core is using the bus. An access to an address
that maps to nothing still takes and releases the lock, so it cannot
leave the bus locked. `--stats` prints the number of locked read-write
pairs the bridge has served.

### Coherence

With `--coherent`, a write to main memory removes that line from every
other core's caches. Only the transport differs between the two models.
The caches themselves are the same `L1CachesCore` class that every
configuration uses, and in a single-core system nothing ever sends them
an invalidate.

- **Finding a line.** The caches are virtually indexed and tagged, but an
  invalidate carries a physical address. Each line therefore also keeps
  its physical address. A virtual and a physical address agree within a
  page, so only the sets the rest of the index could select need
  searching. In a 32 KB cache with 4 KB pages, that is 8 sets.
- **The sitar_model.** When the bridge forwards a write to main memory,
  it pushes the line's address to every other core, on a net of its own,
  in that same phase. Each core polls this net every cycle, whatever it
  is doing, and again before every cache access, so a hit in that phase
  cannot see a line that has just been invalidated. The invalidate
  reaches the other cores in the same cycle that memory takes the write,
  before the writer gets its response.
- **The cpp_model.** A small `CoherentBus` gives each core a port of its
  own onto the bus, and a write calls the other cores' caches directly.
  Nothing else is running at that moment, because the cores take turns.

**A fill in progress.** A line fill in the sitar_model is 8 separate bus
reads, and another core can write the line between them. The invalidate
then finds nothing to remove, since the line is not installed yet, and
installing it would leave a stale line that nothing would ever remove.
A cache therefore remembers the invalidates that arrive during a fill. If
one of them is for this line, the fill still serves the read that started
it, but the line is not installed. `--stats` counts these as `fills
abandoned`.

**The writer's own caches** get no invalidate, as in AJIT. A store updates
the writer's own data cache, but not its instruction cache, so code that
modifies itself must still execute `FLUSH`.

**Snoop filter.** Every write sends an invalidate to every other core,
since the bus cannot see which lines each cache holds. `--snoop-filter`
leaves one out if that core's last invalidate was for the same line and
it has read nothing from the bus since, because it cannot then hold the
line. The results of a correct program do not change. Timing can change
slightly, because the filter changes which fills in progress hear about a
write, and so which of them are abandoned. `--stats` shows how many
invalidates were left out. AJIT's bridge has a larger filter with the same
purpose.

### Synonyms

Two virtual addresses, or one address in two MMU contexts, can map to one
physical line. A cache holds at most one copy of it, in every
configuration. Installing a line first removes any older copy with the
same physical address, so a store through one address is never missed by
a load through the other. A store through an uncached alias and an atomic
instruction never install a line, so they remove the other copy themselves.
A store or atomic whose fault is suppressed by the MMU's NF bit reaches no
memory and has no physical address, so it removes nothing.
`--stats` counts these as `synonyms removed`. A bypass-ASI access goes
around the cache on purpose, and leaves this core's own copy alone.

### Page table updates

A successful translation sets the R bit of the page table entry, and a first write also
sets its M bit. Both are written back to memory. With several cores, what the walk or
the TLB holds may by then be out of date, and writing it back could undo a change
another core has just made. So when more than one core runs, the MMU reads the entry
again and sets the bits on what it finds, and an entry that is no longer a PTE is left
alone. In the sitar_model the second read is locked, so the bus is held until the
write. In the cpp_model each access runs to completion, so nothing can come between
them. The second read costs a memory access, so it is left out with `--run-cores 1`,
and in the single-core configurations, where nothing else writes the entry.

### The end of a run

In the single-core configurations, `Core` stops the simulation as soon
as its core halts. Here a halted core only logs that it has halted,
because the other cores may still be running. `System` watches every
running core and stops the simulation once all of them have halted. It
checks in the second phase of each cycle, after every core has
finished its work for that cycle, so the cycle on which a run ends does
not depend on the order in which the cores happen to run.

`System`'s second parameter, `STOP_WHEN_HALTED`, is `true` by default.
A model that holds several `System`s sets it to `false`, since the first
system to finish would otherwise end the run for all of them, and stops
the run itself once every system has halted (see [A larger
model](../parallel_simulation.md#a-larger-model)).

Cores beyond `--run-cores` are held in reset for the whole run, through
`SparcThread`'s reset pin, and the run does not wait for them.

### Latency knobs

`System.sitar`'s `init` block holds every latency knob. The per-core
knobs (memory-interface delays, cache hit and fill delays, MMU delays)
are set in a loop, the same for every core. The bus's `bridge.delay`,
`mainMemory.delay` and the device knobs follow. All default to 0, as in
the single-core configurations. See [Model Configuration
Settings](../model_configuration_settings.md#multicore-multicore) for
what each one does.

---

## Interrupts

The [Interrupt Controller](../peripheral_devices_interrupt_controller.md)
has 8 slots, one for each of 2 threads on each of 4 cores. Thread 0 of
core `i` uses slot `2i`. Every core here has one thread, so slots `0`,
`2`, `4` and `6` are in use. Each core's interrupt input is driven from
its own slot.

- **cpp_model.** At the end of each scheduling round, every core's
  interrupt input takes the level its slot presents.
- **sitar_model.** `PeripheralDevices` has one interrupt-level output
  for each of the 4 cores the controller supports, and `System`
  connects output `i` to core `i`. Each core polls its own net once
  per cycle. The single-core configurations connect output 0 only.

The controller's slot count is the reason `NUM_CORES` is at most 4.

---

## Assumptions

The model follows AJIT's multi-core design wherever that design is
known, from the [AJIT processor
description](../references/ajit_processor_description.pdf#page=47) and its
section on [cache coherence](../references/ajit_processor_description.pdf#page=43).
The table lists where it makes its own assumptions, and what is not yet
modeled.

| Aspect | In this model | Notes |
|---|---|---|
| Reset | Every core starts at PC 0 and runs the same program. The reset PC is `SparcCore`'s `resetPC`, which a model's main may change before the run. | As in AJIT. |
| Core ID | ASR29 reads `0x50520000 \| (core << 8) \| thread`. | As in AJIT. One thread per core, so the thread field is 0. |
| Threads per core | 1 | AJIT cores can have 2. |
| Number of cores | 1 to 4, set at compile time | Limited by the Interrupt Controller's 8 slots. The validation suite assumes 4. |
| L1 caches | Each core's own, VIVT, write-through, as in `core_l1cache_mmu_devices` | |
| Coherence | Off by default, write-invalidate with `--coherent` | See [Coherence](#coherence). Each line keeps its physical address, where AJIT keeps a separate reverse table (its RLUT). Data is the same either way, and only hit and miss counts differ. |
| Synonyms | At most one copy of a physical line per cache | AJIT removes an older copy too, unless both have the same virtual address, in different contexts. Here that older copy is removed as well, since a store in one context would otherwise leave it stale. |
| `FLUSH` | Empties the caches of the core that executes it, and no other | The other cores' copies go through coherence, or a flush of their own. |
| Memory ordering | Sequentially consistent | No store buffer. SPARC's TSO allows more than this, so correct programs still work. `STBAR` has no effect. |
| Atomic `LDSTUB` and `SWAP` across cores | Both models. | The cpp_model runs each instruction to completion. In the sitar_model, the bridge locks the bus from the read to the write (see [The bus lock](#the-bus-lock)), by core and for the whole bus, as in AJIT. |
| Page table entry updates | Atomic across cores, by a locked read and write in the sitar_model | The R and M bits are set on the entry in memory, not on a copy. See [Page table updates](#page-table-updates). |
| Bus arbitration (sitar_model) | Round-robin over the cores, one transaction at a time | An assumption, not taken from AJIT. |
| Bus timing (sitar_model) | `SystemBridge`'s, plus the `bridge.delay` knob | |
| Main memory and devices | One of each, shared by every core | As in AJIT. |
| Interrupt routing | Core `i` takes its interrupts from slot `2i` | As in AJIT, for thread 0. |
| End of run | When every running core has halted | A modeling convenience. AJIT has no such notion. |
