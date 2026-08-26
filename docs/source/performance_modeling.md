# Performance Modeling

The Sitar model (`model/sitar_component_models/`, composed per
configuration under `model/system_models/*/sitar_model/`) is a **simple,
non-pipelined
cycle-level timing model**. There is no pipelining and no out-of-order
execution, just a fixed delay per opcode plus separately configurable
memory-access latencies. This page covers where to change those
numbers, and how to confirm a change actually took effect. See
[Logging](logging.md) for how logging itself is architected (this page
just uses it) and how to narrow a trace down at runtime.

---

## The three knobs

| Knob | Where | Charged | Default |
|---|---|---|---|
| Opcode latency | `model/sitar_component_models/cpp_code/OpcodeLatencies.h` | Every instruction, memory or not | 1 cycle |
| `MemoryInterface.delay` | `Core.sitar`'s `init` block | Requester side, per channel, after the response is available | 0 |
| `MainMemory.delay` | `Core.sitar`'s `init` block | The memory's own service time, shared by all requesters | 0 |

All three are independent and additive. A load with opcode latency 1,
`MemoryInterface.delay` 2, and `MainMemory.delay` 3 takes 6 cycles total,
not 3. All three accept `0` with no special-casing. With everything at
`0`, the Sitar model runs with zero elapsed simulated time per
instruction, functionally identical to the plain `cpp_model`.

---

## Opcode latency

This is a compile-time table, `OpcodeLatencies.h`:

```cpp
#define DEFAULT_PER_OPCODE_DELAY 1

static const std::unordered_map<Opcode, uint32_t> OPCODE_LATENCY_OVERRIDES = {
    // {UMUL, 4}, {SMUL, 4}, ...
};
```

Every opcode not listed in `OPCODE_LATENCY_OVERRIDES` gets
`DEFAULT_PER_OPCODE_DELAY`. List only the exceptions there, e.g. to
approximate a multi-cycle multiplier/divider. Edit and rebuild (each
configuration's own `sitar_model/build.sh`) to change it. This is
deliberately not a runtime-loaded config file.

## Memory-side latency

The other two knobs, `MemoryInterface.delay` and `MainMemory.delay`,
both default to `0` and are otherwise only ever assigned from outside,
in `Core.sitar`'s `init` block, alongside the `downstreamRequest`/
`downstreamResponse` wiring that connects each of `sparcThread`'s
memory-interface threads to `mainMemory`:

```sitar
init
$
sparcThread.ifetchThread.downstreamRequest  = &mainMemory.request;
sparcThread.ifetchThread.downstreamResponse = &mainMemory.response;
sparcThread.ifetchThread.delay              = 2;   // add a line like this
...
mainMemory.delay = 3;                              // and/or this
$
```

---

## Confirming a change took effect

Rebuild with logging enabled and run a test (commands below are for the
`core_only` configuration; substitute another configuration's own path
and executable name as needed):

```sh
model/system_models/core_only/sitar_model/build.sh --logging
model/system_models/core_only/sitar_model/executable/sparc_sim_sitar_core_only_logging <hex> <expected>
```

This writes `<hex>`'s own trace file (`<hex>` with its `.hex` replaced by
`.log`, see [Getting Started](getting_started.md#observing-the-simulation-log)
and [The log viewer](logging.md#the-log-viewer)) into the current
directory. Its `time` column is exactly the per-instruction cycle count
this page is about. Either open it in `log_viewer/viewer.html` and read
`time` off consecutive `FETCH` rows directly, or grep it on the command
line:

```sh
awk -F'\t' '$4=="FETCH"{print $2, $3, $5}' <hex_basename>.log
```

For example, overriding `ADD`'s latency to 4 cycles (`{ADD, 4}` in
`OPCODE_LATENCY_OVERRIDES`) and running
`validation/asm/integer_alu/Arithmetic/Add/ADD.hex` produces `time`
values increasing by 1 between fetches, except right after the `ADD`
row, where it jumps by 4, exactly the overridden gap. Reverting the
override (back to the empty `OPCODE_LATENCY_OVERRIDES = {};` default) and
rebuilding restores the uniform 1-cycle spacing.

For `MemoryInterface.delay`/`MainMemory.delay`, look in the *other* file
`--logging` produces, `sitar.log` (Sitar's own per-request/response
messages, not part of the architectural trace, see
`model/system_models/core_only/sitar_model/README.md`) for
`"servicing"`/`"response ready"`
(`MainMemory`) and `"Started memory reference"`/`"Finished memory
reference"` (`MemoryInterface`), each timestamped `[t=<cycle>]`.

Logging is off by default. Rebuild without `--logging` to go back to
that. It's noticeably slower and noisier, meant for exactly this kind of
debugging rather than everyday use.
