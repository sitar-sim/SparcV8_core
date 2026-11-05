# validation/multicore/mmu_coherence/

Coherent caches with the MMU on. In `../coherence/` the MMU is off, so a virtual and a
physical address are the same, and an invalidate can only be looking in the obvious place.
Here each core has its own view of a shared physical page, in some combination of virtual
address, context and page tables, so an invalidate has to find its line from the
physical address alone. Each test's `.vprj` has `RUN_OPTIONS = --coherent`.

| Test | Virtual address | Context | What else |
|---|---|---|---|
| `diff_va_across_cores` | Different per core | Shared | Each in a different cache set. Every kind of write. |
| `same_va_diff_context` | Same | Different per core | The tags all differ. Every kind of write. |
| `diff_va_diff_context` | Different per core | Different per core | Every kind of write. |
| `separate_page_tables` | Different per core | Own context table per core | Every kind of write. |
| `same_va_diff_pa` | Same, different physical pages | Different per core | Not synonyms, so a write must not disturb another core's line. |
| `line_in_another_context` | Same | A reader switches away and back | An invalidate goes by physical address, whatever context is running. Two ways, so that the second context's line does not evict the first. |
| `code_through_another_address` | Different per core | Shared | The instruction cache. |
| `lock_through_aliases` | Different per core | Different per core | A spinlock and counter, with plain loads. |
| `fill_race` | Different per core | Shared | A write during a fill. |
| `litmus_mp` | Different per core | Shared | Message passing. |

The one-core versions of the same combinations are in `../../C/caches/synonyms/`.
