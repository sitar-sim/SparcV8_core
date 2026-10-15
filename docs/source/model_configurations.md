---
hide:
  - toc
---

# Model Configurations

This project provides several system configurations.

- **`core_only`**  
    Models only the SPARC core connected to main memory. Every
    processor-generated address (a virtual address) is used directly
    to index into main memory, with no translation.
- **`core_mmu`**  
    Adds a Memory Management Unit (MMU) between the core and main
    memory. Every processor-generated virtual address is translated to
    a physical address before it reaches main memory.
- **`core_mmu_devices`**  
    Adds a timer, an interrupt controller, and a serial device, as one
    shared set on the memory side of the MMU, reached by physical
    address like main memory.
- **`core_l1cache_mmu_devices`**  
    Adds split instruction and data L1 caches between the core and the
    MMU. VIVT, write-through, and compatible with the AJIT processor's
    own L1 caches.
- **`apara`**  
    One APARA engine on its own, with no SPARC core. The APARA engine is
    a vector compute engine designed to work alongside a SPARC processor
    as an accelerator. See [The APARA Engine](apara/index.md).
- **`sparc_apara`**  
    `core_l1cache_mmu_devices` plus one APARA engine. The SPARC program
    loads the engine's program, starts its threads, and moves data in
    and out, and the engine can also read and write main memory itself.

For each configuration, there exist two implementations:

- **`cpp_model`**  
    A 0-delay functional model. A plain host C++ function-call chain
    through the model's components, with no notion of cycles or
    timing.
- **`sitar_model`**  
    A cycle-timed model. The same components, driven through Sitar
    with real per-opcode, interconnect, and memory timing.

The configurations and their path in the project (linked) are
summarized here:

| Configuration | Type | Description |
|---|---|---|
| core_only | [cpp (functional model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/cpp_model/) | The core plus main memory. No MMU, devices, or caches. |
| core_only | [sitar (timing model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/sitar_model/) | The core plus main memory. No MMU, devices, or caches. |
| core_mmu | [cpp (functional model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/) | Adds an MMU between the core and main memory. |
| core_mmu | [sitar (timing model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/) | Adds an MMU between the core and main memory. |
| core_mmu_devices | [cpp (functional model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu_devices/cpp_model/) | Adds the peripheral devices below the MMU. |
| core_mmu_devices | [sitar (timing model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu_devices/sitar_model/) | Adds the peripheral devices below the MMU. |
| core_l1cache_mmu_devices | [cpp (functional model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_l1cache_mmu_devices/cpp_model/) | Adds split L1 caches between the core and the MMU. |
| core_l1cache_mmu_devices | [sitar (timing model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_l1cache_mmu_devices/sitar_model/) | Adds split L1 caches between the core and the MMU. |
| apara | [cpp (functional model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/apara/cpp_model/) | One APARA engine on its own, no SPARC core. See [The APARA Engine](apara/index.md). |
| apara | [sitar (timing model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/apara/sitar_model/) | One APARA engine on its own, with its pipeline's timing. |
| sparc_apara | [cpp (functional model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/sparc_apara/cpp_model/) | core_l1cache_mmu_devices plus one APARA engine. See [The Engine in a System](apara/system.md). |
| sparc_apara | [sitar (timing model)](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/sparc_apara/sitar_model/) | core_l1cache_mmu_devices plus one APARA engine, on a two-master bus. |

For each configuration, both the cpp and sitar models include the same
components: `core_mmu`'s MMU, for example, is present in both its
`cpp_model` and its `sitar_model`, just reached with 0 added delay in
the former and real Sitar timing in the latter.

See [Model Components](model_components.md) for the list of all
components, such as the SPARC Core, the MMU, and devices, that are
included in this project.

---

## Sitar Model Structure

For specifically the Sitar models, which have a notion of structure and
timing, this section describes the structure and component
interconnections for each configuration, as well as the code
structure.

### Configuration: core_only

#### Structure diagram

<img src="images/core_only_structure.svg" alt="core_only structure diagram" title="core_only structure diagram">

No net crossing anywhere. The core talks directly to memory over a
procedure handshake, so zero delay communication is possible between
the core and memory procedures. The "--||--" symbol indicates direct
communication between the two procedures using a handshake and shared
variables.

#### Model description

This shows component instance ownership: which design unit
instantiates which, and how many instances.

<pre>
<a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_only/sitar_model/src/Top.sitar">Top</a>
 |
 +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_only/sitar_model/src/Core.sitar">Core</a> (module)
      |
      +-- sparcThread : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SparcThread.sitar">SparcThread</a> (procedure)
      |    |
      |    +-- 5x <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/VirtualMainMemoryInterface.sitar">VirtualMainMemoryInterface</a> (procedure)
      |
      +-- mainMemory : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/VirtualMainMemory.sitar">VirtualMainMemory</a> (procedure)
</pre>

---

### Configuration: core_mmu

#### Structure diagram

<img src="images/core_mmu_structure.svg" alt="core_mmu structure diagram" title="core_mmu structure diagram">

The core talks to the MMU over the same procedure handshake `core_only`
uses. The MMU talks to physical memory over two nets, since
`PhysicalMainMemory` is a module, not a procedure. Crossing a net costs
Sitar's own unavoidable minimum one cycle each way, so even at every
knob's default this configuration cannot reach a fully 0-delay run the
way `core_only` can.

#### Model description

This shows component instance ownership: which design unit
instantiates which, and how many instances.

<pre>
<a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/Top.sitar">Top</a>
 |
 +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/System.sitar">System</a> (module)
      |
      +-- core : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu/sitar_model/src/Core.sitar">Core</a> (module)
      |    |
      |    +-- sparcThread : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SparcThread.sitar">SparcThread</a> (procedure)
      |    |    |
      |    |    +-- 5x <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/VirtualMainMemoryInterface.sitar">VirtualMainMemoryInterface</a> (procedure)
      |    |
      |    +-- mmu : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/Mmu.sitar">Mmu</a> (procedure)
      |         |
      |         +-- 2x <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PhysicalMainMemoryInterface.sitar">PhysicalMainMemoryInterface</a> (procedure)
      |              |
      |              +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PullAToken.sitar">PullAToken</a> / <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PushAToken.sitar">PushAToken</a> (procedure)
      |
      +-- mainMemory : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PhysicalMainMemory.sitar">PhysicalMainMemory</a> (module)
           |
           +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PullAToken.sitar">PullAToken</a> / <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PushAToken.sitar">PushAToken</a> (procedure)

core.requestOut  --requestNet-->  mainMemory.requestIn
core.responseIn  <-responseNet--  mainMemory.responseOut
</pre>

---

### Configuration: core_mmu_devices

#### Structure diagram

<img src="images/core_mmu_devices_structure.svg" alt="core_mmu_devices structure diagram" title="core_mmu_devices structure diagram">

The core and its MMU are unchanged from `core_mmu`. Below the MMU sits
a bridge, which reads the physical address of each access and sends it
either to main memory or to the peripheral devices (Timer, Serial,
Interrupt Controller). The devices are one shared set on the memory
side, not part of the core, the same way the AJIT processor organizes
them. That is what lets several cores share them later.

Every arrow between modules is a net, and every net crossing costs at
least one cycle. A memory access crosses four nets here (core to
bridge to memory, and back), two more than in `core_mmu`. The
Interrupt Controller sends its interrupt level to the core over its own
net, as a level: a token arrives only when the level changes, and the
core polls that net once per cycle. An interrupt therefore reaches the
core one cycle after the Interrupt Controller raises it.

The devices' behavior is the same C++ class in both models
(`PeripheralDevicesCore`). The cpp_model ticks it once after every core
cycle. The sitar_model's `PeripheralDevices` module ticks it once per
simulated cycle. See [Peripheral Devices](peripheral_devices.md) for
what the devices do.

#### Model description

This shows component instance ownership: which design unit
instantiates which, and how many instances.

<pre>
<a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu_devices/sitar_model/src/Top.sitar">Top</a>
 |
 +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu_devices/sitar_model/src/System.sitar">System</a> (module)
      |
      +-- core : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_mmu_devices/sitar_model/src/Core.sitar">Core</a> (module)
      |    |
      |    +-- sparcThread : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SparcThread.sitar">SparcThread</a> (procedure)
      |    |
      |    +-- mmu : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/Mmu.sitar">Mmu</a> (procedure)
      |
      +-- bridge : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SystemBridge.sitar">SystemBridge</a> (module)
      |
      +-- mainMemory : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PhysicalMainMemory.sitar">PhysicalMainMemory</a> (module)
      |
      +-- devices : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PeripheralDevices.sitar">PeripheralDevices</a> (module)

core.requestOut          --coreRequestNet-->     bridge.coreRequestIn
core.responseIn          <-coreResponseNet--     bridge.coreResponseOut
bridge.memoryRequestOut  --memoryRequestNet-->   mainMemory.requestIn
bridge.memoryResponseIn  <-memoryResponseNet--   mainMemory.responseOut
bridge.devicesRequestOut --devicesRequestNet-->  devices.requestIn
bridge.devicesResponseIn <-devicesResponseNet--  devices.responseOut
devices.interruptLevelOut --interruptLevelNet--> core.interruptLevelIn
</pre>

---

### Configuration: core_l1cache_mmu_devices

#### Structure diagram

<img src="images/core_l1cache_mmu_devices_structure.svg" alt="core_l1cache_mmu_devices structure diagram" title="core_l1cache_mmu_devices structure diagram">

The same system as `core_mmu_devices`, with one more procedure inside
`Core`: the split L1 caches, between `sparcThread` and `mmu`. All three
are procedures of the one `Core` module, so a cache hit completes with
no net crossing and no added delay (unless a hit-latency knob is set).
A miss reads the whole 64-byte line through the MMU, which costs the
MMU's translation plus eight doubleword transactions through the
bridge. See [Model Components](model_components.md#caches) for what the
caches do.

Nothing is cached while the MMU is disabled, unless the MMU Control
Register's "always cacheable" bit is set (as in AJIT). A program can set
it itself, or the simulator can, with `--always-cacheable`.

#### Model description

This shows component instance ownership: which design unit
instantiates which, and how many instances.

<pre>
<a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_l1cache_mmu_devices/sitar_model/src/Top.sitar">Top</a>
 |
 +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_l1cache_mmu_devices/sitar_model/src/System.sitar">System</a> (module)
      |
      +-- core : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/core_l1cache_mmu_devices/sitar_model/src/Core.sitar">Core</a> (module)
      |    |
      |    +-- sparcThread : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SparcThread.sitar">SparcThread</a> (procedure)
      |    |
      |    +-- caches : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/L1Caches.sitar">L1Caches</a> (procedure)
      |    |
      |    +-- mmu : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/Mmu.sitar">Mmu</a> (procedure)
      |
      +-- bridge : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SystemBridge.sitar">SystemBridge</a> (module)
      |
      +-- mainMemory : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PhysicalMainMemory.sitar">PhysicalMainMemory</a> (module)
      |
      +-- devices : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PeripheralDevices.sitar">PeripheralDevices</a> (module)
</pre>

The nets are the same seven as in `core_mmu_devices`.

---

### Configuration: apara

#### Structure diagram

<img src="images/apara_structure.svg" alt="apara structure diagram" title="apara structure diagram">

One APARA engine, on its own. There is no SPARC core and no system
around it: the engine's program, data, and starting register values
are placed straight into its memories before the run, and the run ends
once every thread it started has stopped (see [Writing and Running
APARA Programs](apara/running.md)).

The engine's pipeline has five stages, each a module, joined by nets
whose capacities are the hardware's channel depths. A bundle of
instructions moves from FETCH through DECODE and REGFILE to EXEC, which
executes it. Its result goes back to REGFILE, which releases the
registers the bundle had locked, and on to WRITEBACK, which tells FETCH
when a branch was mispredicted or a thread has stopped. Since every net
crossing takes a cycle, a bundle spends at least one cycle in each
stage, and the stages work on different bundles at the same time. See
[APARA Timing Model](apara/timing_model.md) for what each stage does
and the timing rules.

The engine's functional state (its memories, registers, and threads)
lives in `exec`, and is the same C++ class the cpp_model runs.

#### Model description

This shows component instance ownership: which design unit
instantiates which, and how many instances.

<pre>
<a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/apara/sitar_model/src/Top.sitar">Top</a>
 |
 +-- engine : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaEngine.sitar">AparaEngine</a> (module)
      |
      +-- fetch     : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaFetch.sitar">AparaFetch</a> (module)
      |
      +-- decode    : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaDecode.sitar">AparaDecode</a> (module)
      |
      +-- regfile   : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaRegfile.sitar">AparaRegfile</a> (module)
      |
      +-- exec      : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaExec.sitar">AparaExec</a> (module)
      |
      +-- writeback : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaWriteback.sitar">AparaWriteback</a> (module)

fetch.toDecode          --fetchToDecode-->          decode.fromFetch
decode.toRegfile[0..3]  --decodeToRegfile[0..3]-->  regfile.fromDecode[0..3]
regfile.toExec          --regfileToExec-->          exec.fromRegfile
exec.toRegfile          --execToRegfile-->          regfile.fromExec
regfile.toWriteback     --regfileToWriteback-->     writeback.fromRegfile
writeback.correctionOut --correctionNet-->          fetch.correctionIn
writeback.haltOut       --haltNet-->                fetch.haltIn
exec.fetchControlOut    --fetchControlNet-->        fetch.controlIn
</pre>

`decodeToRegfile` is one net per thread, so REGFILE can hold a waiting
bundle of each thread and issue whichever one is ready.
`fetchControlNet` carries thread starts and resets to FETCH.

---

### Configuration: sparc_apara

#### Structure diagram

<img src="images/sparc_apara_structure.svg" alt="sparc_apara structure diagram" title="sparc_apara structure diagram">

`core_l1cache_mmu_devices`, plus one APARA engine. The core, its
caches and MMU, main memory, and the devices are unchanged. Two modules
join them:

- **`engine`**, the engine's five-stage pipeline, the same module as in
  the `apara` configuration.
- **`host`**, the engine's host side: its control unit, through which
  the SPARC program loads programs and starts threads, and its DMA
  unit, which copies data between main memory and the engine's data
  memory.

The bridge of the earlier configurations becomes an interconnect with
two masters, the core and the engine's host side, taken round robin.
The SPARC program reaches the engine through three address windows on
it (the engine's data memory, its control unit, its DMA unit), which
the interconnect routes to `host`. In the other direction, `host` sends
the DMA unit's transfers, and the engine's own loads and stores outside
its data memory, out through the interconnect as its second master.

`host` reaches the engine's state in `exec` over five more nets: one
pair for its requests to the engine (read a register, write IMEM, start
a thread, ...), one pair for the engine's loads and stores that leave
it, and one for the notice that a thread has stopped. The engine's
interrupt goes from `host` to the Interrupt Controller's external
input, IRL 14.

See [The Engine in a System](apara/system.md) for the programmer's view
of all this, and what each address window holds.

#### Model description

This shows component instance ownership: which design unit
instantiates which, and how many instances.

<pre>
<a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/sparc_apara/sitar_model/src/Top.sitar">Top</a>
 |
 +-- <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/sparc_apara/sitar_model/src/System.sitar">System</a> (module)
      |
      +-- core : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/system_models/sparc_apara/sitar_model/src/Core.sitar">Core</a> (module)
      |    |
      |    +-- sparcThread : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SparcThread.sitar">SparcThread</a> (procedure)
      |    |
      |    +-- caches : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/L1Caches.sitar">L1Caches</a> (procedure)
      |    |
      |    +-- mmu : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/Mmu.sitar">Mmu</a> (procedure)
      |
      +-- interconnect : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/SystemInterconnect.sitar">SystemInterconnect</a>&lt;2&gt; (module)
      |
      +-- mainMemory : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PhysicalMainMemory.sitar">PhysicalMainMemory</a> (module)
      |
      +-- devices : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/PeripheralDevices.sitar">PeripheralDevices</a> (module)
      |
      +-- engine : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaEngine.sitar">AparaEngine</a> (module: fetch, decode, regfile, exec, writeback, as in apara)
      |
      +-- host : <a href="https://github.com/sitar-sim/SparcV8_core/blob/main/model/sitar_component_models/AparaHost.sitar">AparaHost</a> (module)

core.requestOut                   --coreRequestNet-->       interconnect.masterRequestIn[0]
core.responseIn                   <-coreResponseNet--       interconnect.masterResponseOut[0]
host.masterRequestOut             --hostRequestNet-->       interconnect.masterRequestIn[1]
host.masterResponseIn             <-hostResponseNet--       interconnect.masterResponseOut[1]
interconnect.memoryRequestOut     --memoryRequestNet-->     mainMemory.requestIn
interconnect.memoryResponseIn     <-memoryResponseNet--     mainMemory.responseOut
interconnect.devicesRequestOut    --devicesRequestNet-->    devices.requestIn
interconnect.devicesResponseIn    <-devicesResponseNet--    devices.responseOut
interconnect.engineRequestOut     --engineRequestNet-->     host.slaveRequestIn
interconnect.engineResponseIn     <-engineResponseNet--     host.slaveResponseOut
devices.interruptLevelOut         --interruptLevelNet-->    core.interruptLevelIn
host.interruptOut                 --engineInterruptNet-->   devices.externalInterruptIn
host.serviceOut                   --serviceRequestNet-->    engine.exec.serviceIn
host.serviceIn                    <-serviceResponseNet--    engine.exec.serviceOut
engine.exec.offIslandOut          --offIslandRequestNet-->  host.offIslandIn
engine.exec.offIslandIn           <-offIslandResponseNet--  host.offIslandOut
engine.exec.stopOut               --stopNet-->              host.stopIn
</pre>
