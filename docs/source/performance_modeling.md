---
hide:
  - toc
---

# Performance Modeling

Model configuration knobs are of two kinds, structural and timing. See
[Model Configuration Settings](model_configuration_settings.md) for
the complete list of both kinds, and where to set each one.

Once you've chosen knob values to model a specific system (rebuild
first if any of them are compile-time), run the simulation with
`--stats` enabled.

---

## Printing the performance measures

Every configuration's own executable, both drivers, takes an optional
`--stats` flag, alongside the existing `<hex_file> [expected_file]
[max_cycles]` arguments (it can appear anywhere among them):

```sh
model/system_models/core_mmu/cpp_model/executable/sparc_sim_cpp_core_mmu <hex> --stats
```

Off by default, so `run_simple_test.sh` and `validation/run_tests.py`
run unaffected. When given, it prints every performance measure the
model tracks (the table below), to stdout, once the run finishes. Each
configuration prints only what it actually has: `core_only` prints its
core statistics alone. `core_mmu` prints core statistics, then MMU
statistics, then physical memory statistics. The later configurations
add their caches' and devices' statistics, and, in `sparc_apara`, the
APARA engine's.

---

## Performance measures reported by the model

### Core

| Performance measure | Component | Models/configs available in | Description |
|---|---|---|---|
| **Total cycles to halt** | [`SparcStateMachine`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/SparcStateMachine.h) | [core_only/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/cpp_model/), [core_only/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/sitar_model/), [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with a SPARC core | The number of cycles the run took before the core halted, or the cycle limit was reached first. This number corresponds to the total instruction execution count in the functional `cpp_model`, whereas in the `sitar_model` it corresponds to the actual elapsed clock cycles of the timed simulation. |
| **Core memory references**<br>(`ifetches`, `loads`, `stores`, `atomicLoadStores`, `flushes`) | [`SparcCoreStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/SparcCoreStats.h) | [core_only/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/cpp_model/), [core_only/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/sitar_model/), [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with a SPARC core | The number of memory references made by the core, broken down by access type. `ifetches` equals total instructions fetched, one fetch per instruction. An annulled instruction is still fetched, just not executed, so this is not the same as a count of instructions executed. A Load/Store/AtomicLoadStore that faults before reaching memory (e.g. a misaligned address) is not counted. One that faults as a result of the access itself is still counted, since the access happened. |
| **Annulled instructions**<br>(`annulledInstructions`) | [`SparcCoreStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/SparcCoreStats.h) | [core_only/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/cpp_model/), [core_only/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/sitar_model/), [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with a SPARC core | The number of not-taken annulling branches whose delay-slot instruction was fetched but never executed (Appendix B.4's `a` bit). |
| **Traps by type**<br>(`trapIllegalInstruction`, `trapWindowOverflow`, ...) | [`SparcCoreStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/SparcCoreStats.h) | [core_only/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/cpp_model/), [core_only/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/sitar_model/), [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with a SPARC core | The number of traps raised, broken down by trap type (Appendix C.8, Table 7-1): illegal instruction, privileged instruction, window overflow/underflow, misaligned address, division by zero, and more. `trapTicc` counts software-raised traps (a `Ticc` instruction executed). Every other counter is hardware-detected. |
| **FP execution outcomes**<br>(`fpInstructionsExecuted`, `fpTrapsIEEE754Exception`, ...) | [`SparcCoreStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/SparcCoreStats.h) | [core_only/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/cpp_model/), [core_only/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_only/sitar_model/), [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with a SPARC core | The number of floating-point instructions that completed, and the number that hit each of three possible FP trap outcomes (Appendix C.7). An FP result that only sets an accrued exception flag without actually trapping (e.g. an inexact result with that trap disabled) still counts as completed, but not as one of the three trap outcomes. |

### MMU

| Performance measure | Component | Models/configs available in | Description |
|---|---|---|---|
| **TLB hits and misses**<br>(`tlbHitsAtLevel[0..3]`, `tlbMisses`) | [`MmuStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuStats.h) | [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with an MMU | The number of TLB hits, broken down by the page-table level the hit occurred at, and the number of misses (any access that needed a page-table walk because it wasn't found at any level). |
| **Page-table walks**<br>(`walksTerminatedAtLevel[0..3]`, `walksNotFound`, `pageTableMemoryAccesses`) | [`MmuStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuStats.h) | [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with an MMU | The number of page-table walks, broken down by the level a valid leaf PTE was found at, the number that found no valid PTE at all, and the total physical memory accesses issued purely to walk the page tables (one per level actually visited). |
| **MMU faults**<br>(`faultsInvalidAddress`, `faultsProtection`, `faultsPrivilege`, `faultsTranslationError`) | [`MmuStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuStats.h) | [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with an MMU | The number of faults raised, broken down by fault type (Appendix H.5's FT field). |
| **R/M bit write-backs**<br>(`referencedBitWriteBacks`, `modifiedBitWriteBacks`) | [`MmuStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuStats.h) | [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with an MMU | The number of translations that required writing an updated Referenced or Modified bit back to the page-table entry in memory. |
| **MMU register accesses**<br>(`registerReads`, `registerWrites`, `contextRegisterWrites`) | [`MmuStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuStats.h) | [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with an MMU | The number of reads and writes of the MMU's own control/context/fault registers (ASI 4), and the number of writes to the context register specifically. |
| **MMU access mix**<br>(`flushRequests`, `probeRequests`, `bypassAccesses`, `translatedAccesses`) | [`MmuStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/mmu/MmuStats.h) | [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with an MMU | The number of accesses that were TLB flushes, probes, explicit MMU-bypass accesses, or ordinary translated accesses. |

### Main Memory

| Performance measure | Component | Models/configs available in | Description |
|---|---|---|---|
| **Physical memory accesses**<br>(`reads`, `maskedWrites`, `lockedReads`, `fullDoublewordAccesses`, `partialAccesses`) | [`MainMemoryStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/MainMemoryStats.h) | [core_mmu/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/cpp_model/), [core_mmu/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu/sitar_model/), and every later configuration with an MMU | The number of doubleword transactions reaching physical memory, broken down by read/write, whether a read was the locked half of an atomic pair, and whether a write touched all 8 bytes of the doubleword or only some of them. |

### Caches

| Performance measure | Component | Models/configs available in | Description |
|---|---|---|---|
| **Cache hits and misses**<br>(`read hits`, `read misses`, `write hits`, `write misses`) | [`L1CachesCore`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/cache/L1CachesCore.h) | [core_l1cache_mmu_devices/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_l1cache_mmu_devices/cpp_model/), [core_l1cache_mmu_devices/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_l1cache_mmu_devices/sitar_model/), and sparc_apara | Per cache, the lookups of cacheable-ASI accesses that hit or missed. |
| **Line fills and uncached misses**<br>(`lines filled`, `uncached misses`) | [`L1CachesCore`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/cache/L1CachesCore.h) | same | Lines installed, and read misses the MMU reported as not cacheable (which read just one doubleword). |
| **Forwarded accesses and flushes**<br>(`forwarded`, `flushes`) | [`L1CachesCore`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/cache/L1CachesCore.h) | same | Accesses with a non-cacheable ASI, passed straight to the MMU, and whole-cache flushes. |

### Peripheral devices

| Performance measure | Component | Models/configs available in | Description |
|---|---|---|---|
| **Device accesses**<br>(`timer`, `serial`, `interrupt controller`, `unmapped`) | [`PeripheralDevicesCore`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/devices/PeripheralDevicesCore.h) | [core_mmu_devices/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu_devices/cpp_model/), [core_mmu_devices/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/core_mmu_devices/sitar_model/), and every configuration with devices | Register accesses to each device (one per 32-bit register word touched), and accesses in the device window no device decodes. |

### APARA engine

| Performance measure | Component | Models/configs available in | Description |
|---|---|---|---|
| **Bundles executed, per thread** | [`AparaCore`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/apara/AparaCore.h) | [apara/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/apara/cpp_model/) (per thread), [sparc_apara/cpp](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/sparc_apara/cpp_model/) (total) | The bundles (groups of instructions executed together) each engine thread ran, and the instructions in them, not counting the padding `$null`s. |
| **Pipeline counters**<br>(`bundles fetched`, `executed`, `skipped`, `mispredicts`, `BTB-predicted fetches`) | [`AparaTimingStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/apara/AparaTiming.h) | [apara/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/apara/sitar_model/), [sparc_apara/sitar](https://github.com/sitar-sim/SparcV8_core/tree/main/model/system_models/sparc_apara/sitar_model/) | Bundles FETCH sent, bundles EXEC executed, and bundles it skipped because they were fetched on a wrong path. Mispredicts are bundles whose next PC differed from FETCH's prediction. BTB-predicted fetches are the fetches that followed a predicted branch target. |
| **Stall counters**<br>(`register-lock stalls`, `REGFILE token stalls`, `divider stalls`, `DMEM bank conflicts`) | [`AparaTimingStats`](https://github.com/sitar-sim/SparcV8_core/blob/main/model/cpp_common_code/apara/AparaTiming.h) | same | Cycles a ready bundle waited because a register it uses was still being written, because the maximum number of bundles was already in EXEC, or because the shared divider was busy, and the extra accesses to an already-used data-memory bank. See [APARA Timing Model](apara/timing_model.md) for each rule. |

The `apara` configuration's sitar_model also prints the cycles the run
took (`ran N bundles in M cycles`).

In `core_only`, the core connects directly to virtual memory, so the
Core memory references above already reflect every access actually
served. In configurations with an MMU, a core-side access doesn't
necessarily correspond 1:1 to a physical memory access: a TLB hit
needs none, and a page-table walk needs several. Physical memory is
also doubleword-addressed in this model (see [Model
Components](model_components.md#memory)), a different unit than a
core-side access. This is why physical memory accesses are reported
separately, only where an MMU is present, rather than folded into the
Core table above.
