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

Each core has three nets of its own, and the bus reaches memory and the
devices over four more. Each net carries data from an output port to an
input port.

| Net | From | To |
|---|---|---|
| `coreRequestNet[i]` | `cores[i].requestOut` | `bridge.coreRequestIn[i]` |
| `coreResponseNet[i]` | `bridge.coreResponseOut[i]` | `cores[i].responseIn` |
| `interruptLevelNet[i]` | `devices.interruptLevelOut[i]` | `cores[i].interruptLevelIn` |
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
plays the same role. In a later stage it will also send the
invalidations that keep the caches coherent.

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

### The end of a run

In the single-core configurations, `Core` stops the simulation as soon
as its core halts. Here a halted core only logs that it has halted,
because the other cores may still be running. `System` watches every
running core and stops the simulation once all of them have halted. It
checks in the second phase of each cycle, after every core has
finished its work for that cycle, so the cycle on which a run ends does
not depend on the order in which the cores happen to run.

`System`'s third parameter, `STOP_WHEN_HALTED`, is `true` by default.
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

The model follows AJIT's multicore design wherever that design is
known. The table lists where it makes its own assumptions, and what is
not yet modeled.

| Aspect | In this model | Notes |
|---|---|---|
| Reset | Every core starts at PC 0 and runs the same program. The reset PC is `SparcCore`'s `resetPC`, which a model's main may change before the run. | As in AJIT. |
| Core ID | ASR29 reads `0x50520000 \| (core << 8) \| thread`. | As in AJIT. One thread per core, so the thread field is 0. |
| Threads per core | 1 | AJIT cores can have 2. |
| Number of cores | 1 to 4, set at compile time | Limited by the Interrupt Controller's 8 slots. |
| L1 caches | Each core's own, VIVT, write-through, as in `core_l1cache_mmu_devices` | |
| Coherence | None | A core's caches can hold an old copy of a line another core has written. Write-invalidate coherence, as in AJIT, is planned (`COHERENT`). |
| Atomic `LDSTUB` and `SWAP` across cores | Both models. | The cpp_model runs each instruction to completion. In the sitar_model, the bridge locks the bus from the read to the write (see [The bus lock](#the-bus-lock)), by core and for the whole bus, as in AJIT. |
| Bus arbitration (sitar_model) | Round-robin over the cores, one transaction at a time | An assumption, not taken from AJIT. |
| Bus timing (sitar_model) | `SystemBridge`'s, plus the `bridge.delay` knob | |
| Main memory and devices | One of each, shared by every core | As in AJIT. |
| Interrupt routing | Core `i` takes its interrupts from slot `2i` | As in AJIT, for thread 0. |
| End of run | When every running core has halted | A modeling convenience. AJIT has no such notion. |
