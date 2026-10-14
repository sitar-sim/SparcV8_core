# The APARA Engine in a System (sparc_apara)

The `sparc_apara` configuration puts one APARA engine next to the SPARC
core of `core_l1cache_mmu_devices` (with its L1 caches, MMU, and
peripheral devices), as the APARA hardware attaches to an AJIT
processor: the SPARC loads the engine's program, starts its threads and
learns when they stop, and moves data in and out, all through memory-
mapped registers; the engine can also read and write the system's
memory itself.

## Address map

The system's physical addresses follow the AJIT_APARA layout (Ref
`model/cpp_common_code/SystemAddressMap.h`), with the APARA parameter
template's addresses for engine 0 of cluster 0:

| Range | What |
|---|---|
| `0x0000_0000` .. | main memory (256 MB), except: |
| `0x0100_0000` .. `0x0100_FFFF` | the engine's DMEM, 64 KB |
| `0xFFFE_0000` .. `0xFFFE_007F` | the engine's control unit (CCU) registers |
| `0xFFFE_2000` .. `0xFFFE_207F` | the engine's DMA registers |
| `0xFFFF_0000` .. `0xFFFF_FFFF` | the peripheral devices |

Only main memory is ever cached; the engine's windows never are. A SPARC
program should reach them with MMU-bypass accesses (ASI 0x20), as the
routines below do. A program's own code and data must stay clear of the
DMEM window.

Inside the engine, an address in its own DMEM window is local; **every
other address goes off island**, to the system (the hardware's rule).
So an engine program in a system addresses its DMEM by the window's
address, usually through a register the host sets:

```mcode
// $r9 = 0x01000000 (set by the SPARC): DMEM byte 0x100 is $r9 + 256.
    || $st ($i64) [$r9 + 256] $r3 ;
```

(The standalone `apara` configuration instead aliases every address into
DMEM, as the APARA reference model does.)

## The control unit

Each thread has 8 32-bit registers at `0xFFFE_0000 + 32*thread +
4*register`:

| Register | Contents |
|---|---|
| R0 | control: [31:16] sequence number, [15:14] thread (for command 9), [11:8] command, flags [4] run the command interpreter, [3] interrupt enable, [2] completed, [1] started, [0] start |
| R1 | PC |
| R2 | IMEM index / register index |
| R3 | IMEM write data / timer high |
| R4 | IMEM read data / timer low |
| R5 | completion: [31] valid, [26] RAS error, [25] halt, [24] exception, [23:0] exception codes |
| R6 | register high / stop PC / RAS depth |
| R7 | register low / next PC / RAS top |

The host writes the arguments, then R0 with a command, `start` and `run
the command interpreter`; the unit sets `started`, carries the command
out, writes its results, and sets `completed`.

| Command | Does |
|---|---|
| 1 read IMEM | R4 := IMEM[R2] |
| 2 write IMEM | IMEM[R2] := R3 (IMEM is shared by the threads) |
| 3 reset | stop the thread: PC 0, RAS and ERROR cleared, registers kept |
| 4 run | start the thread at R1 |
| 5 read register | R6:R7 := register R2 (high:low) |
| 6 write register | register R2 := R6:R7 |
| 7 completion | once the thread has stopped: R5 := valid + its ERROR, R6 := its PC (each stop reported once); else R5 := 0. With interrupt enable, the command waits for the stop and then raises the engine interrupt |
| 8 step | run one bundle at R1, with local data only; R7 := the next PC |
| 9 RAS state | R6 := depth, R7 := top of thread R0[15:14]'s RAS |
| 10 timer | R3:R4 := the engine's cycle count |

Writing R0 with interrupt enable clear clears the interrupt.

## The DMA unit

Four channels of 8 registers at `0xFFFE_2000 + 32*channel + 4*register`:

| Register | Contents |
|---|---|
| R0 | control: [31:24] operation (1 load: system memory to DMEM; 2 store: DMEM to system memory), [23:20] and [19:16] the top 4 bits of the 36-bit source and destination, [15:8] sequence number, flags [4] error, [3] interrupt enable, [2] completed, [1] started, [0] scheduled |
| R1, R2 | source and destination base addresses |
| R3 | total bytes (for the record) |
| R4 | number of bursts |
| R5 | gap: the distance between bursts |
| R6 | bytes per burst; the stop cycle, once completed |
| R7 | the start cycle |

Writing R0 with `scheduled` starts the channel. A load **gathers**: burst
*i* comes from source + *i*·gap and lands at destination + *i*·(bytes per
burst); a store **scatters**, the reverse. The DMEM side's address may be
a DMEM offset or a window address. On completion: `completed`, and the
interrupt if enabled; writing R0 with interrupt enable clear clears it.
An unknown operation completes at once with `error`.

## Interrupts

The engine's interrupt (its control unit's or its DMA unit's) drives the
Interrupt Controller's external input, IRL 14. A handler for it, with
the AJIT dispatch scheme of `compiler/include/ajit_mt_irc.h`:

```c
void engine_handler(void)
{
	completion = apara_thread_completion(0);
	apara_clear_interrupt(0);
}
...
ajit_set_interrupt_handler(EXTERNAL_IRL, engine_handler);
writeInterruptControlRegister(0, 0, (1u << EXTERNAL_IRL) | 1u);
apara_start_thread(0, KERNEL_START);
apara_request_completion_interrupt(0);
```

## Software

`compiler/include/apara_access_routines.h` has the routines, in the style
of AJIT's access routines:

| Routine | Does |
|---|---|
| `apara_load_program(words, n)` | IMEM words 0..n-1 |
| `apara_write_thread_register(t, r, v)`, `apara_read_thread_register(t, r)` | a thread's 64-bit register |
| `apara_start_thread(t, pc)`, `apara_reset_thread(t)` | |
| `apara_poll_thread(t)`, `apara_wait_thread(t)` | the completion word |
| `apara_thread_stop_pc(t)` | where it stopped |
| `apara_request_completion_interrupt(t)`, `apara_thread_completion(t)`, `apara_clear_interrupt(t)` | completion by interrupt |
| `apara_dma_start(...)`, `apara_dma_wait(c)`, `apara_dma_load(c, dmem, src, n)`, `apara_dma_store(c, dst, dmem, n)` | DMA |
| `apara_dmem_write_word(o, v)`, `apara_dmem_read_word(o)` | DMEM directly, through the window |
| `apara_read_timer()` | |

An engine program travels inside the SPARC program as a C array:
`compiler/apara/apara_obj_to_c.py kernel.mcode` writes `kernel.mcode.h`
with `kernel_program[]`, `KERNEL_PROGRAM_WORDS`, and a `KERNEL_<LABEL>`
address for each label. A test's `.vprj` can name its kernels with
`MCODE = kernel.mcode` lines; `validation/build_hex.py` then writes the
headers before compiling.

A complete offload, from `validation/C/apara/dma_dot_product/`:

```c
apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
apara_dma_start(0, APARA_DMA_LOAD, (uint32_t) a, 0, 1, 0, N, 0);    // a -> DMEM 0
apara_dma_start(1, APARA_DMA_LOAD, (uint32_t) b, 256, 1, 0, N, 0);  // b -> DMEM 256
apara_dma_wait(0);
apara_dma_wait(1);
apara_write_thread_register(0, 9, APARA_DMEM_BASE);
apara_write_thread_register(0, 10, APARA_DMEM_BASE + 256);
apara_start_thread(0, KERNEL_START);
apara_wait_thread(0);
apara_dma_store(2, (uint32_t) result, 504, 8);                      // DMEM 504 -> result
```

## The models

**cpp_model.** `AparaSystemCore` (`model/cpp_common_code/apara/`) joins
the engine (`AparaCore`), `AparaControlCore` and `AparaDmaCore`. The
`SystemBus` routes the engine's windows to it; its off-island accesses and
DMA transfers go back through the same bus. After every core cycle the
engine runs one bundle and its DMA moves one piece (up to 8 bytes).

**sitar_model.** The engine's pipeline (`AparaEngine`, Ref [Timing
Model](timing_model.md)) and its host side (`AparaHost`: the control and
DMA units) are sibling modules of the core, on a `SystemInterconnect`
with two masters (the core and `AparaHost`, round robin):

| Module | Owns, does |
|---|---|
| `engine.exec` | the engine's state; serves `host`'s requests on its service port (DMEM, registers, IMEM, thread commands), one cycle each; sends a bundle's off-island transactions to `host` and holds the bundle until they are answered; tells `host` when a thread stops |
| `host` | the CCU and DMA registers and commands; the engine's slave port (the SPARC's accesses to the three windows) and master port (DMA transfers, off-island accesses) |
| `interconnect` | one transaction at a time, from the core or the host, to main memory, the devices or the host |

Every net crossing takes a cycle, so a SPARC access to a CCU register
crosses four nets, and to DMEM six (through EXEC).

## Tests

`validation/C/apara/`, run on `--config sparc_apara`, both models:

| Test | Checks |
|---|---|
| `imem_registers` | IMEM and register round trips, the timer |
| `run_poll` | run a program, poll its completion, its result in DMEM through the window (byte order) |
| `run_interrupt` | the completion interrupt, IRL 14, in a trap handler |
| `exception` | an engine exception's completion word, reset, and a second run |
| `four_threads` | four threads on one program, their own data |
| `off_island` | the engine reading and writing main memory |
| `dma_interrupt` | a gather load, its interrupt |
| `dma_dot_product` | a whole offload: DMA in, dot product, DMA out |
