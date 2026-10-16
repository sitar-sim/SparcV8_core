# validation/sparc_apara/

Tests of the SPARC core using an APARA engine, on the `sparc_apara`
configuration (the "1p1e" system: one processor, one engine). Each test
is a bare-metal C program for the SPARC, built and run like the other C
tests (`validation/build_hex.py`, `validation/run_tests.py --config
sparc_apara`), most with one or more engine programs.

```bash
source compiler/toolchain_env.sh
python3 validation/build_hex.py validation/sparc_apara
python3 validation/run_tests.py validation/sparc_apara --config sparc_apara
python3 validation/run_tests.py validation/sparc_apara --config sparc_apara --sitar --max-cycles 50000000
```

| Folder | What it checks |
|---|---|
| `basic/` | Each part of the engine's interface on its own: IMEM and registers, running and polling, the completion interrupt, exceptions, four threads, the engine's own main-memory accesses, DMA. |
| `setup/` | Bringing the engine up from power-up, one thread: its initial state, loading and reading back its memories, complete offloads (by polling and by interrupt) of a program compiled from C, and loading a second program over the first. |
| `threads/` | The same program on 1, 2, 3 and 4 engine threads, each on its own slice of the data; threads started and restarted at different times. |
| `interference/` | Whether threads, the SPARC and the DMA unit disturb one another: threads on their own DMEM regions, the SPARC and the DMA unit working on DMEM while threads run, one thread's exception, and the one real interference, a race on shared data. |
| `linalg/` | Linear algebra offloaded to the engine: a matrix product on four threads, SAXPY and a four-thread dot product compiled from C. |

Every test reports like the device tests (`apara_common.h`, Ref
`../C/devices/devices_common.h`): `%o0` = 1 if every check passed,
`%o1` one bit per check, listed in the test's header comment. The SPARC
program computes the expected results itself (with 32-bit integer
arithmetic: there is no 64-bit multiply on the SPARC side, and the
startup code leaves the FPU off, so `saxpy` turns it on first).

## Engine programs

A test names its engine programs in its `.vprj`, one `MCODE = <file>`
line each. `build_hex.py` turns each into a C header the test includes
(`compiler/apara/apara_obj_to_c.py`), so the engine program travels
inside the SPARC program's image as data (the system has no disk: the
SPARC loads it into the engine's IMEM itself):

- **`kernel.mcode`** (mcode, assembled): `kernel.mcode.h` has
  `kernel_program[]`, `KERNEL_PROGRAM_WORDS`, and each label's IMEM
  address (`KERNEL_START`).
- **`kernel.c`** (C, compiled with `compiler/apara/apcc.py` for DMEM at
  its window address): `kernel.c.h` also has each global variable's DMEM
  offset (`KERNEL_DMEM_DATA`), and the DMEM words its initializers set
  (`kernel_dmem_image[]`, loaded with `apara_load_dmem_image()`). An
  `__entry` function's parameters arrive in `$r1`, `$r2`, ...

An engine program in a system addresses DMEM through the window
(`APARA_DMEM_BASE` + offset): any other address goes out to the system.

## How the SPARC drives the engine

At power-up no engine thread runs, and IMEM, DMEM and every register are
zero (`setup/cold_state`). A SPARC program then, for each piece of work:

1. **Loads the program** into IMEM, word by word through the control
   unit (`apara_load_program`). IMEM is shared by the four threads; it
   may be reloaded between runs (`setup/reload_program`), but not while a
   thread is running.
2. **Puts the input data in DMEM**: through the window, one 32-bit word
   at a time (`apara_dmem_write_word`), or by DMA, which copies from main
   memory while the SPARC goes on (`apara_dma_load`, or
   `apara_dma_start` + `apara_dma_wait` to overlap copies). A C program's
   initialized globals: `apara_load_dmem_image`.
3. **Sets each thread's registers** (its arguments) and **starts it** at
   an IMEM address (`apara_write_thread_register`, `apara_start_thread`).
4. **Learns that the thread stopped**, either way:
    - **polling**: `apara_poll_thread` returns 0 while the thread runs,
      and its completion word once, when it has stopped;
      `apara_wait_thread` polls until then.
    - **interrupt**: `apara_request_completion_interrupt` asks the control
      unit to raise the engine interrupt (IRL 14) when the thread stops;
      the SPARC goes on with its own work, and its handler reads the
      completion word (`apara_thread_completion`) and clears the interrupt
      (`apara_clear_interrupt`). DMA channels can interrupt the same way.

   The completion word is `HALTED` (`APARA_COMPLETION_VALID |
   APARA_ERROR_HALT`) for a thread that ended with `$halt`; after an
   exception it has `APARA_ERROR_EXCEPTION` and the exception code of
   each slot, and `apara_thread_stop_pc` gives the bundle that failed.
   Each stop is reported exactly once (`threads/staggered`).
5. **Collects the results** from DMEM, through the window or by DMA
   (`apara_dma_store`, which writes main memory behind the SPARC's data
   cache: read such data with `physical_word`, or invalidate first).
6. A stopped thread can be **started again** at once, with new
   registers; after an exception, reset it first (`apara_reset_thread`,
   `interference/fault_isolation`).

Threads share IMEM, DMEM and the pipeline, and have their own registers,
PC and return-address stack. They do not disturb one another as long as
each works on its own part of DMEM (`interference/disjoint_regions`):
the instruction set has no atomic read-modify-write, so threads that
update the same word race (`interference/shared_counter`). The SPARC
and the DMA unit may work on other parts of DMEM while threads run
(`interference/host_while_running`, `interference/dma_while_running`).

See the documentation's "The Engine in a System" page for the control
unit's and DMA unit's registers and commands.
