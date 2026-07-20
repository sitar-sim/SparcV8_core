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
    as two parallel procedures sharing one `MemAccessInterface` struct; on
    halt, prints `sparcThread.printInfo()` and calls `stop simulation`.
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
  sibling `sitar` repo). `build/` and `executable/` are gitignored build
  products.

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

Requires the `sitar` CLI on `PATH` (see the sibling `sitar` repo). Build:

```sh
model/sitar_model/build.py
```

Run a single test directly, same CLI as `cpp_model/check_test`:

```sh
model/sitar_model/executable/sitar_check_test \
    validation/asm/integer_alu/Arithmetic/Add/ADD.hex \
    validation/asm/integer_alu/Arithmetic/Add/ADD.expected
```

Run the full 223-test suite against the Sitar model instead of the plain
C++ one:

```sh
validation/run_tests.py validation/asm --sitar
```

To inspect timing (e.g. while changing a `delay` value), rebuild with
per-cycle logging enabled (off by default -- noisy and slower) and pipe
stderr somewhere readable; log lines are timestamped `[t=<cycle>]`:

```sh
model/sitar_model/build.py --logging
model/sitar_model/executable/sitar_check_test  <hex>  <expected>  2> trace.log
```

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
