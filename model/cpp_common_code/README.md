# cpp_common_code/

Timing-agnostic C++ model of the SPARC V8 core: pure state and behavior,
with no notion of cycles, phases, or memory latency. This is the one
place SPARC ISA semantics live -- `SparcCore` is reused unmodified by
every `sitar_model` configuration's own timed driver
(`../sitar_component_models/SparcThread.sitar`), and `SparcStateMachine`,
the reusable 0-delay fetch-decode-execute FSM, is reused unmodified by
every `cpp_model` configuration under `../system_models/*/cpp_model/`,
whatever each configuration connects downstream (memory directly, or
later an MMU or a cache).

## What's what

- **`SparcCore.h` / `.cpp`** -- the core itself: `Registers reg`, the
  decoded-instruction dispatch (`executeInstruction(Opcode)`), trap logic
  (`checkExternalTraps()`, `checkInstructionException()`, `executeTraps()`
  per the SPARC V8 manual's Appendix C reference algorithms), and
  `SparcCore::state` (`EXECUTE`/`ERROR`/...). Has no `run()` loop of its own
  and performs no memory access with implied timing -- a driver calls its
  methods in the right order and supplies memory itself.
- **`Registers.h`** -- the register file: windowed integer registers
  (`r0`-`r31` via the current `CWP`), floating-point registers `f0`-`f31`,
  and state registers (`psr`, `fpsr`/`fsr`, `y`, `wim`, `tbr`, `pc`, `npc`,
  `asr0`-`asr31`), with `R_*`/`W_*` accessors.
- **`Opcodes.h` / `.cpp`** -- the `Opcode` enum (every SPARC V8 instruction
  mnemonic) and helpers like `isBranchInstruction(Opcode)`.
- **`Decoder.h` / `.cpp`** -- `Decoder::decode(Registers*)`: reads the
  instruction word already loaded into `reg` and returns the matching
  `Opcode`, or an unimplemented/illegal marker.
- **`MemoryInterfaces.h`** -- two abstract interfaces: `VirtualMemoryInterface`
  (formerly `MemoryAccessProvider`), what `SparcCore` and
  `SparcStateMachine` actually depend on for memory access (32-bit
  address, ASI, a word read, a masked doubleword write, an atomic
  read-modify-write) -- whatever a cpp_model configuration connects
  downstream implements this; neither `SparcCore` nor `SparcStateMachine`
  know or care what that is. See `Plan_SoC_Integration_Roadmap.md`'s
  "lego-block interface contract". `PhysicalMemoryInterface` is what sits
  below an MMU instead (64-bit/36-bit-meaningful address, no ASI,
  doubleword-shaped transactions mimicking AJIT's own bus -- see that
  file's own comment for the citation).
- **`MemCore.h` / `.cpp`** -- flat, word-addressable functional memory (256MB,
  byte addresses), implementing `VirtualMemoryInterface` directly.
  `initializeMemory(hex_dump_file)` loads a hex-dump memory image (see
  `compiler/hexdump_to_memimage.py`). Used directly by the `core_only`
  configuration (0-delay); `sitar_model`'s `MainMemory` procedure owns one
  too, wrapped with modeled latency.
- **`MainMemory.h` / `.cpp`** -- the physical-memory endpoint for a
  cpp_model configuration with an MMU (`core_mmu` today): implements
  `PhysicalMemoryInterface`, wraps a `MemCore` for the actual backing
  storage. Not used by `core_only`, which has no MMU and talks to
  `MemCore` directly, same as before this class existed.
- **`MainMemoryStats.h` / `.cpp`** -- functional counters for `MainMemory`
  (reads/writes/atomics, full vs. partial doubleword accesses), in the
  same spirit as `mmu/MmuStats.h`.
- **`SparcStateMachine.h` / `.cpp`** -- the reusable 0-delay
  fetch-decode-execute FSM every `cpp_model` configuration drives
  `SparcCore` through: `SparcStateMachine(core, mem)`, then
  `run(maxCycles)`. `mem` is a `VirtualMemoryInterface&`, not a concrete
  `MemCore&`, which is what makes this file itself configuration-invariant
  -- only what a given configuration's own entry point (e.g.
  `../system_models/core_only/cpp_model/src/sparc_sim.cpp`) constructs and
  passes in as `mem` changes per configuration.
- **`BitManipulation.h` / `.cpp`** -- bitfield read/write helpers
  (`readBits`, `writeBits`, sign-extension, ...) used throughout the decoder
  and core.
- **`FloatingPointFunctions.h`** -- IEEE 754 single/double/quad-precision
  arithmetic (quad via `libquadmath`) backing the `FADD*`/`FSUB*`/.../`FSQRT*`
  family and FSR exception-flag tracking.
- **`ImplementationDependent.h`** -- constants the SPARC V8 spec leaves
  implementation-defined (e.g. number of register windows).
- **`ConvertToString.h`** -- small formatting helpers used in a few places
  around the codebase.
- **`CoreLogger.h`/`.cpp`** -- formats/emits a `SparcCore`'s state as a
  trace of architectural events (fetch, trap, memory access, ...); owned
  by `SparcCore` itself (`SparcCore::logger`), so any driver gets one for
  free. See `CoreLogger.h` for the full API.

## How to use it

This directory builds no executable of its own -- it's a library, compiled
directly into each configuration's binary (see
`../build_scripts/build_cpp_model.sh` and
`../build_scripts/build_sitar_model.py`). For the 0-delay `cpp_model`
side, most configurations should just reuse `SparcStateMachine` as-is
rather than driving `SparcCore` directly:

```cpp
#include "SparcCore.h"
#include "MemCore.h"
#include "SparcStateMachine.h"

MemCore mem;
mem.initializeMemory("program.hex");   // see compiler/hexdump_to_memimage.py

SparcCore core;
core.memCore = &mem;                   // MemCore implements VirtualMemoryInterface directly

SparcStateMachine runner(core, mem);
runner.run(maxCycles);
```

A configuration that needs something other than direct `MemCore` access
(an MMU, a cache) implements `VirtualMemoryInterface` itself and passes
that in as `mem` instead -- `SparcCore` and `SparcStateMachine` need no
changes either way. For a timed driver, see
`../sitar_component_models/SparcThread.sitar` instead, which drives the
same `SparcCore` through Sitar rather than through
`SparcStateMachine`.

Link flags: `-lquadmath` is required (`FloatingPointFunctions.h` uses
`__float128` for quad-precision ops).
