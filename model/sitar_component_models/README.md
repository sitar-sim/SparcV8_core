# sitar_component_models/

The reusable Sitar modules and procedures every `sitar_model`
configuration is built from. Each wraps one of the timing-agnostic C++
classes of `../cpp_common_code/` (or just moves tokens), and adds the
component's timing. A configuration's own `Top.sitar` (and, from
`core_mmu` on, `System.sitar` and `Core.sitar`) under
`../system_models/<config>/sitar_model/src/` instantiates and connects
them. The build compiles every `.sitar` file here into every
configuration, whether it uses it or not (see
`../build_scripts/build_sitar_model.py`).

| Files | What |
|---|---|
| `SparcThread.sitar` | The SPARC core: `SparcCore` driven through Sitar, with per-opcode timing. |
| `VirtualMainMemoryInterface.sitar`, `VirtualMainMemory.sitar` | The core's memory-access procedures, and `core_only`'s memory. |
| `Mmu.sitar`, `PhysicalMainMemoryInterface.sitar`, `PhysicalMainMemory.sitar` | The MMU, its physical-access procedures, and physical memory (a module). |
| `PullAToken.sitar`, `PushAToken.sitar` | Generic single-token receive and send, for procedures that talk over nets. |
| `L1Caches.sitar` | The split L1 caches. |
| `SystemBridge.sitar`, `SystemInterconnect.sitar` | The physical bus: one master, or several taken round robin (`sparc_apara`). |
| `PeripheralDevices.sitar` | The Timer, Serial, and Interrupt Controller. |
| `AparaEngine.sitar`, `AparaFetch.sitar`, `AparaDecode.sitar`, `AparaRegfile.sitar`, `AparaExec.sitar`, `AparaWriteback.sitar` | The APARA engine's five-stage pipeline. |
| `AparaHost.sitar` | The APARA engine's control and DMA units, in `sparc_apara`. |
| `cpp_code/OpcodeLatencies.h` | The SPARC core's per-opcode latencies (sitar-only C++). |

See [Model Components
Reference](https://sitar-sim.github.io/SparcV8_core/model_components_reference.html)
for the full per-configuration table, and each file's own header
comment for the detail.
