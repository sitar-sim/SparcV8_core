# validation/multicore/tlb_shootdown/

Each core's TLB is its own. A core that changes a page table entry must get every other core to
drop its copy, through `tlb_shootdown_page()` in
`compiler/sparc_common_routines/multicore_platform.h`. It sends an IPI to each core, and waits
for each to answer. The tests use the page table setup of `../mmu_coherence/`.

| Test | Checks |
|---|---|
| `stale_without_shootdown` | Why it is needed. After core 0 changes an entry, a core that empties its caches still reads the old page, until it drops its TLB entry. |
| `remap_page` | Core 0 keeps moving a page between two physical pages. Each round, every core reads the page chosen. |
| `revoke_write` | Write permission taken away. A store by every core faults, and does not reach memory. |
| `from_every_core` | Every core moves a page of its own at once, so shootdowns overlap. A core waiting for its turn must still take the one under way. |
| `other_context` | The other cores are running in another context when the entry changes. |
| `waits_for_every_core` | The other cores hold their interrupts off for a while. The shootdown must not return before they have answered. |
| `core_that_does_not_answer` | One core holds its interrupts off until two shootdowns return, so the second cannot even send it an IPI. Each must return anyway, and report that core. |
