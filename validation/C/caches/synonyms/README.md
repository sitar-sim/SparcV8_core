# validation/C/caches/synonyms/

A cache holds at most one copy of a physical line. Each test here maps one physical page
at two addresses with the MMU on, and checks that a write through one is seen through
the other. They run on one core, on every configuration with caches.

| Test | Virtual address | Context | Note |
|---|---|---|---|
| `diff_va_diff_set` | Different, different sets | Same | |
| `diff_va_same_set` | Different, same set | Same | A new line replaces the other anyway. |
| `diff_va_same_set_two_ways` | Different, same set | Same | A 2-way cache could hold both, so only the physical address keeps them apart. |
| `same_va_diff_context` | Same | Different | The tags differ, so they look like two lines. |
| `diff_va_diff_context` | Different | Different | |
| `uncached_alias` | Different | Same | One alias is not cacheable, so a write through it never fills. |
| `code_aliases` | Different | Same | In the instruction cache. |
| `diff_pa_same_va` | Same | Different | Different physical pages, so these are not synonyms. They must stay apart. |
| `faulting_access_keeps_line` | Not an alias | Same | A fault suppressed by the NF bit looks like a store to an uncached page, but it has no address, so it must not remove a line. |

All but the last three call `check_alias_pair()` in `alias_common.h`. In each direction it writes
through one alias with a store that misses, a store that hits, a byte store, `LDSTUB` and
`SWAP`, and reads through the other. That makes twelve checks, one bit each in `%o1`.

A bypass-ASI store or atomic is deliberately not covered, since it goes around the cache and
leaves this core's own copy alone (see `../stale_until_flush`).
