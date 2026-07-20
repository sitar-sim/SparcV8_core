# Performance Modeling

The Sitar model (`model/sitar_model/`) is a **simple, non-pipelined
cycle-level timing model** -- no pipelining, no out-of-order execution,
just a fixed delay per opcode plus separately configurable memory-access
latencies. This page covers where to change those numbers, and how to
confirm a change actually took effect.

---

## The three knobs

| Knob | Where | Charged | Default |
|---|---|---|---|
| Opcode latency | `model/sitar_model/src/cpp_code/OpcodeLatencies.h` | Every instruction, memory or not | 1 cycle |
| `MemoryInterface.delay` | `Core.sitar`'s `init` block | Requester side, per channel, after the response is available | 0 |
| `MainMemory.delay` | `Core.sitar`'s `init` block | The memory's own service time, shared by all requesters | 0 |

All three are independent and additive -- a load with opcode latency 1,
`MemoryInterface.delay` 2, and `MainMemory.delay` 3 takes 6 cycles total,
not 3. All three accept `0` with no special-casing -- with everything at
`0`, the Sitar model runs with zero elapsed simulated time per
instruction, functionally identical to the plain `cpp_model`.

---

## Opcode latency

`OpcodeLatencies.h` is a compile-time table:

```cpp
#define DEFAULT_PER_OPCODE_DELAY 1

static const std::unordered_map<Opcode, uint32_t> OPCODE_LATENCY_OVERRIDES = {
    // {UMUL, 4}, {SMUL, 4}, ...
};
```

`DEFAULT_PER_OPCODE_DELAY` applies to every opcode not listed in
`OPCODE_LATENCY_OVERRIDES`; list only the exceptions there, e.g. to
approximate a multi-cycle multiplier/divider. Edit and rebuild
(`model/sitar_model/build.py`) to change it -- this is deliberately not a
runtime-loaded config file.

## Memory-side latency

`MemoryInterface.delay` and `MainMemory.delay` both default to `0` and are
otherwise only ever assigned from outside, in `Core.sitar`'s `init` block,
alongside the `interface = &memInterface` wiring:

```sitar
init
$
sparcThread.ifetchThread.interface = &memInterface;
sparcThread.ifetchThread.delay     = 2;   // add a line like this
...
mainMemory.interface = &memInterface;
mainMemory.delay     = 3;                 // and/or this
$
```

---

## Confirming a change took effect

Rebuild with logging enabled and grep the trace for `Fetched Instruction`
lines, which are timestamped `[t=(cycle,phase)]`:

```sh
model/sitar_model/build.py --logging
model/sitar_model/executable/sitar_check_test <hex> <expected> 2>&1 1>/dev/null | grep "Fetched Instruction"
```

For example, overriding `ADD`'s latency to 4 cycles
(`{ADD, 4}` in `OPCODE_LATENCY_OVERRIDES`) and running
`validation/asm/integer_alu/Arithmetic/Add/ADD.hex` produces:

```
(13,0)TOP.core.sparcThread:[t=(13,0)] Fetched Instruction: OR;    Instruction word: 0x82102bad
(14,0)TOP.core.sparcThread:[t=(14,0)] Fetched Instruction: OR;    Instruction word: 0xa0102002
(15,0)TOP.core.sparcThread:[t=(15,0)] Fetched Instruction: ADD;   Instruction word: 0x90042003
(19,0)TOP.core.sparcThread:[t=(19,0)] Fetched Instruction: RDPSR; Instruction word: 0x93480000
```

Every other opcode (`OR`, `RDPSR`, ...) is fetched one cycle after the
previous one, at the unmodified default -- but `ADD` at `t=15` is followed
by the next fetch only at `t=19`, exactly the overridden 4-cycle gap.
Reverting the override (back to the empty
`OPCODE_LATENCY_OVERRIDES = {};` default) and rebuilding restores the
uniform 1-cycle spacing.

The same approach (rebuild with `--logging`, grep the relevant log lines)
works for `MemoryInterface.delay`/`MainMemory.delay` -- look for
`"servicing"`/`"response ready"` (`MainMemory`) and
`"Started memory reference"`/`"Finished memory reference"`
(`MemoryInterface`) instead.

Logging is off by default (rebuild without `--logging` to go back) --
it's noticeably slower and noisier, meant for exactly this kind of
debugging rather than everyday use.
