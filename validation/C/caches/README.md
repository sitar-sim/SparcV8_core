# validation/C/caches/

Tests for the L1 caches, run on a configuration that has them
(`core_l1cache_mmu_devices` and up). Each sets the MMU Control
Register's "always cacheable" bit itself, so the caches work with the
MMU disabled. Reporting is the same as `validation/C/devices/`.

| Test | Checks |
|---|---|
| `write_through_visible` | Stores through the data cache are already in memory (bypass loads see them), including a byte store. |
| `stale_until_flush` | A bypass store changes memory but not the cached copy, which stays stale until the cache is flushed: the caches are not coherent. |
| `device_never_cached` | A device register read with plain loads keeps changing, even with "always cacheable" set. |
| `atomic_on_cached_line` | LDSTUB on a cached byte returns the old value, and the cache and memory both see 0xFF afterward. |

`stale_until_flush` deliberately fails on a configuration without
caches. The rest of the suite (asm, C, C/mmu, C/devices) also runs
through the caches on this configuration, and with every ordinary access
cached under `SPARC_ALWAYS_CACHEABLE=1`.
