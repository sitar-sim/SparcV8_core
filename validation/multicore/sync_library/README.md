# validation/multicore/sync_library/

Tests of the routines in `compiler/sparc_common_routines/multicore_sync.h`. The
instructions they rely on are tested on their own in `../atomics/`, so run those
first if these fail.

| Test | Routines | What it checks |
|---|---|---|
| `mutex_routines` | `acquire_mutex_using_ldstub`, `acquire_mutex_using_swap`, `try_acquire_mutex_using_ldstub`, and the releases | Two exact counters, and that trying a mutex this core already holds fails. |
| `fetch_and_add` | `atomic_fetch_and_add`, `atomic_counter_read` | Every value is handed out exactly once. |
| `ticket_lock_order` | `ticket_lock_acquire`, `ticket_lock_release` | A log kept under the lock reads 0, 1, 2, and so on. |
| `barrier_phases` | `barrier_wait` | No core gets through a reused barrier before all have arrived, though each does a different amount of work. |
| `semaphore_limit` | `semaphore_wait`, `semaphore_post` | A semaphore with a count of 2 never lets in more than 2 cores, and is back at 2 at the end. |
| `flush_inside_lock` | a mutex with `flush_caches` | A plain load after a flush inside the lock sees the current value. It matters with `SPARC_ALWAYS_CACHEABLE=1`. |

```sh
validation/run_tests.py validation/multicore/sync_library --config multicore --sitar
validation/run_tests.py validation/multicore/sync_library --config multicore
SPARC_ALWAYS_CACHEABLE=1 validation/run_tests.py validation/multicore/sync_library --config multicore --sitar
```

With the bus lock turned off, every test here fails on the sitar_model except
`semaphore_limit`, so it is not a sensitive test of the lock underneath it. It
does fail with the semaphore removed. `flush_inside_lock` fails with its flush
removed, when the caches are on.

These routines wait without a limit, unlike the rest of the suite's waits, so a
broken lock makes one of these tests fail at its `MAX_CYCLES` limit rather than
at a bounded wait.
