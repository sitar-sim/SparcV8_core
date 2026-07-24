# sitar_model/

The timed model: drives `SparcCore` (`../cpp_common_code/`) through the
Sitar hardware-modeling DSL (a separate sibling repo), so that (unlike
`../cpp_model/`, which is instantaneous) instructions and memory accesses
actually take simulated cycles. Three independent, additive latency knobs
live here -- everything else about ISA behavior still comes from
`SparcCore`.

## What's what

- **`src/sitar_code/`** -- the `.sitar` source, translated by `sitar
  translate` into C++:
  - `Top.sitar` -- trivial wrapper module (`submodule core : Core`),
    required by `sitar compile`'s convention of looking for a module
    literally named `Top`.
  - `Core.sitar` -- top-level behavior: runs `sparcThread` and `mainMemory`
    as two parallel procedures sharing one `MemAccessInterface` struct,
    plus a third parallel branch that watches `sparcThread.HALT.VALUE`
    (`sparcThread`'s own procedure never returns -- it loops forever
    across `RESET`/`EXECUTE`/`ERROR` by design) and, once it's set,
    prints `sparcThread.printInfo()` and calls `stop simulation`.
  - `SparcThread.sitar` -- the core driver. State machine (`RESET` ->
    `EXECUTE`); the `EXECUTE` state is a plain loop: fetch one instruction
    (via `MemoryInterface`), decode it, execute it (via `SparcCore`,
    handling traps/annulment/memory ops), then `wait(opcode_delay, 0)` where
    `opcode_delay` comes from `OpcodeLatencies.h`. No structural per-iteration
    floor -- with every delay set to 0 this loop advances zero simulated
    cycles per instruction, same as `cpp_model`.
  - `MemoryInterface.sitar` -- requester-side memory-access procedure.
    Publishes a request onto the shared `MemAccessInterface`, waits for
    `MainMemory`'s response, then (optionally) charges its own `delay`
    (cycles) before returning -- e.g. models interconnect/cache latency
    between the core and memory.
  - `MainMemory.sitar` -- persistent procedure owning the actual
    `MemCore` storage. Services one request at a time off the shared
    `MemAccessInterface`, optionally charging its own `delay` (cycles) as
    the memory's own service time, before publishing the response.
- **`src/cpp_code/`** -- plain C++ headers used by the `.sitar` files:
  - `MemAccessInterface.h` -- the shared request/response struct
    (`request_valid`/`access_type`/`address`/... and
    `response_valid`/`readWord0`/... ) connecting `MemoryInterface` and
    `MainMemory`, plus the `MemAccessType` enum (`LOAD`/`STORE`/`IFETCH`/
    `ATOMIC_LS`/`FLUSH`). Handshake protocol is documented at the top of
    the file.
  - `OpcodeLatencies.h` -- `getOpcodeLatency(Opcode)`: a compile-time table,
    `DEFAULT_PER_OPCODE_DELAY` (currently `1`) plus an
    `OPCODE_LATENCY_OVERRIDES` map for opcodes that differ (e.g. a
    multi-cycle multiplier/divider -- see the commented example in the
    file). Edit and rebuild to change latencies; this deliberately isn't a
    runtime-loaded config.
- **`src/sitar_check_test.cpp`** -- the `-m` custom main for `sitar
  compile`, building `sitar_check_test`: the Sitar-driven counterpart to
  `../cpp_model/check_test`, with the identical CLI, expected-results
  format, and `PASS`/`FAIL`/`OVERALL` output, so
  `../../validation/run_tests.py` can point at either model interchangeably.
- **`build.py`** -- translates the 5 `.sitar` files and builds
  `executable/sitar_check_test` (requires the `sitar` CLI on `PATH`; see the
  sibling `sitar` repo). `build/` and the executable itself are gitignored
  build products.
- **`executable/test_simple_ADD.s`** -- a minimal, beginner-friendly example
  program (see below). Its assembled memory image
  (`executable/test_simple_ADD.hex`), a readable disassembly
  (`executable/test_simple_ADD.objdump`), and its expected-results file
  (`executable/test_simple_ADD.expected`) are committed alongside it, so
  trying it out needs no toolchain at all.

## Latency model

Three knobs, independent and additive -- e.g. a `LD` with opcode latency 1,
`MemoryInterface.delay` 2, and `MainMemory.delay` 3 takes 6 cycles total:

1. **Opcode latency** (`OpcodeLatencies.h`) -- charged by `SparcThread` for
   every instruction, memory or not.
2. **`MemoryInterface.delay`** -- charged on the requester side, after the
   response is available (e.g. interconnect/cache latency).
3. **`MainMemory.delay`** -- charged by the memory itself before publishing
   its response (memory service time), shared by all requesters.

All three default to sensible values (`DEFAULT_PER_OPCODE_DELAY=1`, both
`delay` fields init to `0`) and all three accept `0` -- with everything at
`0` the model runs with zero elapsed simulated time, functionally identical
to `cpp_model`.

## How to build and run it

Requires the `sitar` CLI on `PATH` (see the sibling `sitar` repo).
Commands below are relative to this directory (`model/sitar_model/`).

Build:

```sh
./build.py
```

### A first, minimal example

`executable/test_simple_ADD.s` adds two numbers and puts the result in a
register, then halts. It's a good first program to read end to end.

```sh
cat executable/test_simple_ADD.s
```

Run it, same CLI as `cpp_model/check_test`:

```sh
./executable/sitar_check_test executable/test_simple_ADD.hex executable/test_simple_ADD.expected
```

```
PASS: o0 = 0xc
PASS: l0 = 0x5
PASS: l1 = 0x7
OVERALL: PASS (3 checks)
```

### Next steps

To write your own assembly or C program, see
`../../docs/source/writing_and_running_assembly_programs.md` and
`../../docs/source/writing_and_running_c_programs.md`.

To run the full validation suite instead, against this Sitar-timed model
rather than the plain C++ one, from the repository root:

```sh
validation/run_tests.py validation/asm --sitar
```

To inspect timing (e.g. while changing a `delay` value) or the
instruction/state trace, rebuild with logging enabled (off by default --
noisy and slower):

```sh
./build.py --logging
./executable/sitar_check_test  <hex>  <expected>
```

This writes two files into the current directory, instead of Sitar's
usual stderr output:

- **`sparc_trace.log`** -- `sparcThread`'s own log only, one tab-separated
  row per architectural event from `SparcCore`'s `CoreLogger`, with
  Sitar's usual `(time)hierarchicalId:` line prefix turned off. Same
  format the cpp model's `--logging` build writes (see
  `../cpp_common_code/CoreLogger.h`); load it directly into
  `../../log_viewer/` (see that directory's `README.md`) with no
  extraction needed.
- **`sitar.log`** -- everything else: `mainMemory`/`ifetchThread`/the
  other `MemoryInterface` instances' own per-request/response messages,
  timestamped `[t=<cycle>]`, prefixed with each module's hierarchical id
  as usual.

To change a latency knob, edit the relevant source and rebuild:

- Opcode latency: `src/cpp_code/OpcodeLatencies.h`
  (`DEFAULT_PER_OPCODE_DELAY` / `OPCODE_LATENCY_OVERRIDES`).
- `MemoryInterface.delay` / `MainMemory.delay`: both fields default to `0`
  (set in each procedure's own `init` block) and are otherwise only ever
  assigned from outside in `Core.sitar`'s `init` block, alongside the
  `interface = &memInterface` wiring, e.g.:

  ```
  init
  $
  sparcThread.ifetchThread.interface = &memInterface;
  sparcThread.ifetchThread.delay     = 2;   // add this line
  ...
  mainMemory.interface = &memInterface;
  mainMemory.delay     = 3;                 // add this line
  $
  ```
