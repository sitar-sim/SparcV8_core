# cpp_common_code/cache/

The split L1 caches, as plain C++ classes with no notion of timing,
shared unchanged by both drivers. Behavior follows the AJIT processor's
own L1 caches. See [Model
Components](https://sitar-sim.github.io/SparcV8_core/model_components.html#caches).

| File | What |
|---|---|
| `CacheArray.h` / `.cpp` | One VIVT cache's storage and lookup: lines, context-qualified tags, ACC bits, round-robin replacement, flush. No policy. |
| `L1CachesCore.h` / `.cpp` | Both caches and the access policy (what is cached, read fills, write-through with write-allocate, atomics, flushes). Implements `VirtualMemoryInterface`, and also exposes the same work as small steps for the Sitar model to drive with timed accesses. |
| `CacheConfig.h` | Default sizes (512 lines, direct mapped). |

The line fill itself is the MMU's job (`MemAccessType::READ_LINE`, Ref
`../mmu/MmuCore.h`'s `handleReadLine()`), as in AJIT: the MMU
translates, decides cacheability, and reads the line.

`tests/test_l1_caches.cpp` is a standalone unit test against a fake MMU
(the build line is in its header comment).
