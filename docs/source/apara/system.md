# The APARA Engine in a System (sparc_apara)

The `sparc_apara` configuration puts one APARA engine next to the SPARC
core of `core_l1cache_mmu_devices` (with its L1 caches, MMU, and
peripheral devices), the way the APARA hardware attaches to an AJIT
processor. A SPARC program uses the engine as an accelerator:

1. It **loads the engine's program** into the engine's instruction
   memory (IMEM).
2. It **moves the input data** into the engine's data memory (DMEM),
   either by writing it directly or by asking the engine's DMA unit to
   copy it from main memory.
3. It **starts one or more engine threads**, and sets their registers
   first if they need arguments.
4. It **learns when the threads have stopped**, by polling or by an
   interrupt, and how (a `$halt`, or an exception).
5. It **moves the results back**, the same two ways.

All of this goes through memory-mapped registers: the engine's
**control unit** (CCU), which carries out commands for each thread, and
its **DMA unit**, which copies data between main memory and DMEM. The
engine can also read and write main memory itself, with its ordinary
loads and stores.

This page describes the SPARC program's side: the C routines first,
then the address map and registers they use, then how the two models
implement it.

---

## An offload, step by step

The test `validation/C/apara/dma_dot_product/` offloads a dot product of
two 32-element `int8_t` vectors to the engine. The engine's program,
`kernel.mcode`, loads both vectors from DMEM, computes four 8-element
dot products in one bundle, adds them up, and stores the 64-bit result
back in DMEM:

```mcode
// The dot product of two 32-element $i8 vectors in DMEM (at $r9 and
// $r10), stored as a 64-bit word at $r9 + 504. ($r9: DMEM's window
// address.)
start:
    ||
        $ld ($i64) $r1 [$r9 + 0]   $ld ($i64) $r2 [$r9 + 8]
        $ld ($i64) $r3 [$r9 + 16]  $ld ($i64) $r4 [$r9 + 24]
    ;
    ||
        $ld ($i64) $r5 [$r10 + 0]   $ld ($i64) $r6 [$r10 + 8]
        $ld ($i64) $r7 [$r10 + 16]  $ld ($i64) $r8 [$r10 + 24]
    ;
    ||
        $dot $r20 ($vi8) $r1 $r5   $dot $r21 ($vi8) $r2 $r6
        $dot $r22 ($vi8) $r3 $r7   $dot $r23 ($vi8) $r4 $r8
    ;
    || + $r24 ($i64) $r20 $r21   + $r25 ($i64) $r22 $r23 ;
    || + $r26 ($i64) $r24 $r25 ;
    || $st ($i64) [$r9 + 504] $r26 ;
    || $halt ;
```

The SPARC program's side, from `dma_dot_product.c`:

```c
#include "kernel.mcode.h"   // kernel_program[], KERNEL_PROGRAM_WORDS, KERNEL_START

apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);             // 1. the program
apara_dma_start(0, APARA_DMA_LOAD, (uint32_t) a, 0, 1, 0, N, 0);      // 2. a -> DMEM 0
apara_dma_start(1, APARA_DMA_LOAD, (uint32_t) b, 256, 1, 0, N, 0);    //    b -> DMEM 256
apara_dma_wait(0);
apara_dma_wait(1);
apara_write_thread_register(0, 9, APARA_DMEM_BASE);                  // 3. arguments,
apara_write_thread_register(0, 10, APARA_DMEM_BASE + 256);
apara_start_thread(0, KERNEL_START);                                  //    and start
apara_wait_thread(0);                                                 // 4. wait
apara_dma_store(2, (uint32_t) result, 504, 8);                       // 5. DMEM 504 -> result
```

Two DMA channels copy the two vectors at the same time. The engine's
thread 0 gets the two vectors' DMEM addresses in `$r9` and `$r10`, and
runs from the label `start`. The SPARC program then waits for the
thread to stop, and copies the result back to main memory with a third
DMA channel.

---

## Software

### The routines

`compiler/include/apara_access_routines.h` has C routines for all of
the steps above, in the style of AJIT's own access routines (AJIT
itself has no engine routines, so these are this project's design).
Every routine uses MMU-bypass accesses, so it works whether or not the
MMU is enabled, and never goes through the caches.

| Routine | Does |
|---|---|
| `apara_load_program(words, n)` | Write words 0 to n-1 of IMEM. |
| `apara_write_imem(i, w)`, `apara_read_imem(i)` | One IMEM word. |
| `apara_write_thread_register(t, r, v)`, `apara_read_thread_register(t, r)` | A thread's 64-bit register. |
| `apara_start_thread(t, pc)` | Start thread `t` at `pc` (a label's address, from the program's header). |
| `apara_reset_thread(t)` | Stop thread `t`, and clear its PC, return-address stack, and ERROR. Its registers are kept. |
| `apara_poll_thread(t)` | The thread's completion word: 0 while it is running, or valid plus its ERROR once it has stopped. Each stop is reported once. |
| `apara_wait_thread(t)` | Poll until the thread stops, and return its completion word. |
| `apara_thread_stop_pc(t)` | Where the thread stopped. |
| `apara_request_completion_interrupt(t)`, `apara_thread_completion(t)`, `apara_clear_interrupt(t)` | Learn of the stop by interrupt instead, see [Interrupts](#interrupts). |
| `apara_dma_start(c, op, src, dst, bursts, gap, bytes_per_burst, irq)` | Start DMA channel `c`, see [The DMA unit](#the-dma-unit). |
| `apara_dma_done(c)`, `apara_dma_wait(c)` | Whether channel `c` has finished, and waiting for it. |
| `apara_dma_load(c, dmem, src, n)`, `apara_dma_store(c, dst, dmem, n)` | One contiguous copy of `n` bytes into or out of DMEM, waiting for it. |
| `apara_dma_clear_interrupt(c)` | Clear channel `c`'s interrupt. |
| `apara_dmem_write_word(o, v)`, `apara_dmem_read_word(o)` | A 32-bit word of DMEM, at byte offset `o`, directly. |
| `apara_read_timer()` | The engine's cycle counter. |

The completion word's bits have names: `APARA_COMPLETION_VALID`,
`APARA_ERROR_HALT`, `APARA_ERROR_EXCEPTION`, `APARA_ERROR_RAS`, and
`APARA_ERROR_CODE(word, slot)` for a slot's exception code. A thread
that ended with `$halt` reports `APARA_COMPLETION_VALID |
APARA_ERROR_HALT`.

### Carrying the engine's program

An engine program travels inside the SPARC program as a C array.
`compiler/apara/apara_obj_to_c.py` assembles it and writes a header:

```bash
python3 compiler/apara/apara_obj_to_c.py kernel.mcode       # writes kernel.mcode.h
```

```c
static const uint32_t kernel_program[] = { ... };   // IMEM words 0, 1, ...
#define KERNEL_PROGRAM_WORDS 33
#define KERNEL_START 0x0                             // each label's address
```

The names come from the file name (`--name` chooses another). A test in
the validation suite names its engine programs in its `.vprj`, with an
`MCODE = kernel.mcode` line, and `validation/build_hex.py` writes the
headers before compiling (see [Validation
Suite](../validation_suite.md#the-vprj-expected-results-format)).

---

## Address map

The system's physical addresses follow the AJIT_APARA layout, with the
addresses APARA's parameter template gives engine 0 of cluster 0:

| Range | What |
|---|---|
| `0x0000_0000` .. | Main memory (256 MB), except: |
| `0x0100_0000` .. `0x0100_FFFF` | The engine's DMEM, 64 KB. |
| `0xFFFE_0000` .. `0xFFFE_007F` | The engine's control unit (CCU) registers. |
| `0xFFFE_2000` .. `0xFFFE_207F` | The engine's DMA registers. |
| `0xFFFF_0000` .. `0xFFFF_FFFF` | The peripheral devices. |

Only main memory is ever cached, the engine's windows never are. A SPARC
program should reach them with MMU-bypass accesses (ASI `0x20`), as the
routines above do. A program's own code and data must stay clear of the
DMEM window, which lies inside main memory's range.

### The engine's own view

Inside the engine, an address in its own DMEM window is local, and
every other address goes **off island**, out to the system, as in the
hardware. So in a system, an engine program addresses its DMEM by the
window's address. Usually the SPARC program passes that address in a
register, as `dma_dot_product` does in `$r9`:

```mcode
// $r9 = 0x01000000 (set by the SPARC): DMEM byte 0x100 is $r9 + 256.
    || $st ($i64) [$r9 + 256] $r3 ;
```

An engine load or store to any other address reaches main memory (or a
device) through the system bus, which takes much longer than a DMEM
access. The standalone `apara` configuration instead aliases every
address into DMEM, as the APARA reference model does.

---

## The control unit

The control unit has a block of 8 32-bit registers for each of the
engine's four threads, at `0xFFFE_0000 + 32*thread + 4*register`.
Commands for a thread go through its block.

| Register | Contents |
|---|---|
| R0 | Control: [31:16] sequence number, [15:14] a thread number (for command 9), [11:8] the command, and the flags [4] run the command interpreter, [3] interrupt enable, [2] completed, [1] started, [0] start. (Bits [7:5], "init done" and "cpu mode" in the hardware, are kept but have no effect in the model.) |
| R1 | PC |
| R2 | IMEM index, or register number |
| R3 | IMEM write data, or timer high |
| R4 | IMEM read data, or timer low |
| R5 | Completion: [31] valid, [26] RAS error, [25] halt, [24] exception, [23:0] exception codes |
| R6 | Register high, or stop PC, or RAS depth |
| R7 | Register low, or next PC, or RAS top |

To give a command, the host writes its arguments into R1 to R7, then
writes R0 with the command and the flags *start* and *run the command
interpreter*. The unit sets *started*, carries the command out, writes
its results into the registers, and sets *completed*. The host polls
R0 for *completed* before reading the results or giving the next
command.

| Command | Does |
|---|---|
| 1 read IMEM | R4 := IMEM[R2] |
| 2 write IMEM | IMEM[R2] := R3. IMEM is shared by the threads, so any thread's block will do. |
| 3 reset | Stop the thread: PC 0, RAS and ERROR cleared, registers kept. |
| 4 run | Start the thread at R1. |
| 5 read register | R6:R7 := register R2 (high:low) |
| 6 write register | register R2 := R6:R7 |
| 7 completion | Once the thread has stopped: R5 := valid plus its ERROR, and R6 := its PC (each stop is reported once). Before that, R5 := 0. With *interrupt enable* set, the command instead waits for the stop, and then raises the engine interrupt. |
| 8 step | Run one bundle at R1, with local data only. R7 := the next PC. |
| 9 RAS state | R6 := depth, R7 := top of the RAS of the thread named in R0[15:14]. |
| 10 timer | R3:R4 := the engine's cycle count. |

Writing R0 with *interrupt enable* clear clears the interrupt.

---

## The DMA unit

The DMA unit copies data between main memory and DMEM, while the SPARC
and the engine both go on working. It has four independent channels,
each with 8 registers at `0xFFFE_2000 + 32*channel + 4*register`:

| Register | Contents |
|---|---|
| R0 | Control: [31:24] operation (1 load: main memory to DMEM, 2 store: DMEM to main memory), [23:20] and [19:16] the top 4 bits of the 36-bit source and destination addresses, [15:8] sequence number, and the flags [4] error, [3] interrupt enable, [2] completed, [1] started, [0] scheduled. |
| R1, R2 | Source and destination base addresses. |
| R3 | Total bytes (for the record only). |
| R4 | Number of bursts. |
| R5 | Gap: the distance between bursts. |
| R6 | Bytes per burst. Once completed: the stop cycle. |
| R7 | The start cycle. |

The host writes R1 to R6, then writes R0 with the operation and
*scheduled*, which starts the channel. A copy is a number of **bursts**,
so one command can also collect or spread out strided data:

- A **load gathers**: burst *i* comes from source + *i*·gap, and lands
  at destination + *i*·(bytes per burst), so the bursts end up packed
  together in DMEM.
- A **store scatters**, the reverse: packed in DMEM, spread out in main
  memory.

For one contiguous copy, use a single burst. The DMEM-side address may
be a DMEM byte offset or a window address. When the copy is done, the
channel sets *completed*, and raises the engine interrupt if *interrupt
enable* was set. Writing R0 with *interrupt enable* clear clears it. An
unknown operation completes at once, with *error* set.

---

## Interrupts

Both units can interrupt the SPARC when something finishes: the
control unit when a thread stops (command 7 with *interrupt enable*),
and the DMA unit when a channel completes. Either one drives the
Interrupt Controller's external input, IRL 14 (`EXTERNAL_IRL`).

A program that takes interrupts links the interrupt startup code (a
`STARTUP = crt0_interrupts.s` line in its `.vprj`), and registers a
handler with the AJIT dispatch routines of `compiler/include/ajit_mt_irc.h`
(see [Taking interrupts](../writing_and_running_c_programs.md#taking-interrupts)).
From `validation/C/apara/run_interrupt/`:

```c
void engine_handler(void)
{
    completion = apara_thread_completion(0);   // the stop, as apara_poll_thread() would report it
    apara_clear_interrupt(0);                  // clear the source
}

int main(void)
{
    ajit_initialize_interrupt_handlers_to_null();
    ajit_set_interrupt_handler(EXTERNAL_IRL, engine_handler);
    writeInterruptControlRegister(0, 0, (1u << EXTERNAL_IRL) | 1u);   // slot 0: enable, IRL 14

    apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
    apara_start_thread(0, KERNEL_LOOP);
    apara_request_completion_interrupt(0);
    ...                                        // the SPARC goes on with its own work
}
```

---

## The models

Both models carry out the same commands with the same C++ classes:
`AparaControlCore` (the control unit), `AparaDmaCore` (the DMA unit),
and the engine itself, `AparaCore`. They differ, as in every
configuration, in timing.

- **cpp_model**  
    The bus routes the engine's three windows to the engine, and the
    engine's off-island accesses and DMA transfers go back through the
    same bus. After every SPARC instruction, the engine runs one bundle,
    and the DMA unit moves one piece of a copy (up to 8 bytes).
- **sitar_model**  
    The engine's pipeline (`AparaEngine`, see [APARA Timing
    Model](timing_model.md)) and its host side (`AparaHost`: the control
    and DMA units) are modules beside the core. The bus becomes an
    interconnect with two masters, the core and the host side, taken
    round robin. See [Model
    Configurations](../model_configurations.md#configuration-sparc_apara)
    for the diagram.

In the sitar_model, the parts divide the work like this:

| Module | Owns, does |
|---|---|
| `engine.exec` | The engine's state. Serves the host side's requests (DMEM, registers, IMEM, thread commands), one per cycle. Sends a bundle's off-island loads and stores to the host side, and holds the bundle until they are answered. Tells the host side when a thread stops. |
| `host` | The control unit's and DMA unit's registers and commands. Answers the SPARC's accesses to the engine's three windows, and sends DMA transfers and off-island accesses onto the bus. |
| `interconnect` | One transaction at a time, from the core or from the host side, to main memory, the devices, or the host side. |

Every net crossing takes a cycle, so a SPARC access to a control-unit
register crosses four nets (core to interconnect to host, and back),
and one to DMEM six, since it also goes on to `engine.exec`, which owns
DMEM.

---

## Tests

`validation/C/apara/` holds the SPARC-side tests. Run them on `--config
sparc_apara`, on both models (with `--max-cycles 5000000` on the
sitar_model):

| Test | Checks |
|---|---|
| `imem_registers` | IMEM and register round trips, and the timer. |
| `run_poll` | Running a program and polling its completion, and its result in DMEM, read through the window (byte order included). |
| `run_interrupt` | The completion interrupt, IRL 14, taken in a trap handler. |
| `exception` | An engine exception's completion word, a reset, and a second run. |
| `four_threads` | Four threads running one program on their own data. |
| `off_island` | The engine reading and writing main memory. |
| `dma_interrupt` | A gather load, and its interrupt. |
| `dma_dot_product` | A whole offload: DMA in, the dot product, DMA out. |
