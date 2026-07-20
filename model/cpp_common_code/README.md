# cpp_common_code/

Timing-agnostic C++ model of the SPARC V8 instruction set: pure state plus
`execute_*()` behavior, with no notion of cycles, phases, or memory latency.
Shared, unmodified, by both drivers in `../cpp_model/` and `../sitar_model/`
-- this is the one place SPARC ISA semantics live; neither driver
re-implements or overrides them.

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
- **`MemCore.h` / `.cpp`** -- flat, word-addressable functional memory (256MB,
  byte addresses). `initializeMemory(hex_dump_file)` loads a hex-dump memory
  image (see `compiler/hexdump_to_memimage.py`); `readWord`/`writeWord` and
  masked doubleword helpers (`writeMaskedDoubleWord`,
  `atomicReadModifyWrite`) back STORE and atomic load-store instructions.
  Used directly by `cpp_model` (0-delay); `sitar_model`'s `MainMemory`
  procedure owns one too, wrapped with modeled latency.
- **`BitManipulation.h` / `.cpp`** -- bitfield read/write helpers
  (`readBits`, `writeBits`, sign-extension, ...) used throughout the decoder
  and core.
- **`FloatingPointFunctions.h`** -- IEEE 754 single/double/quad-precision
  arithmetic (quad via `libquadmath`) backing the `FADD*`/`FSUB*`/.../`FSQRT*`
  family and FSR exception-flag tracking.
- **`ImplementationDependent.h`** -- constants the SPARC V8 spec leaves
  implementation-defined (e.g. number of register windows).
- **`ConvertToString.h`** -- small formatting helpers used by
  `SparcCore::printSparcRegisters()` and similar debug dumps.

## How to use it

This directory builds no executable of its own -- it's a library, compiled
directly into each driver's binary (see `../cpp_model/build.sh` and
`../sitar_model/build.py`). To use it from a new driver:

```cpp
#include "SparcCore.h"
#include "MemCore.h"

MemCore mem;
mem.initializeMemory("program.hex");   // see compiler/hexdump_to_memimage.py

SparcCore core;
core.memCore = &mem;                   // used by SparcCore::instructionFetch()

// your driver now calls core's methods (decode, executeInstruction, trap
// checks, ...) in the fetch-decode-execute order it wants, at whatever
// timing it wants -- SparcCore itself has no opinion on either.
```

For a complete, minimal example of that driving loop, read
`../cpp_model/SparcStateMachine.cpp` (0-delay, plain C++) or
`../sitar_model/src/sitar_code/SparcThread.sitar` (Sitar-timed).

Link flags: `-lquadmath` is required (`FloatingPointFunctions.h` uses
`__float128` for quad-precision ops).
