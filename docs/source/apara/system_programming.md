# Programming the System (sparc_apara)

This page describes the software side of the `sparc_apara` system,
which consists of one SPARC core and one APARA engine. It first explains
what a program for the system consists of. It then walks through an
existing program that offloads a dot product to the engine, and lists
the ready-made routines that a SPARC program uses to drive the engine.
After the rules for setting up and running the engine, it builds a new
program step by step, which can serve as the starting point for further
programs. The hardware that these programs use is described in [The
Engine in a System](system.md).

The commands on this page use `$SPARC_HOME`, the repository's folder,
as set in step 2 of [Installation](../installation.md).

---

## The parts of a program

A program for the system has two parts:

- **A SPARC program**, a bare-metal C program like those in [Writing
  and Running C Programs](../writing_and_running_c_programs.md). It is
  the main program. It prepares the data, hands the work to the engine,
  and collects the results.
- **One or more engine programs**, written in mcode (see [APARA Assembly
  Language and Tools](assembly_and_tools.md)) or in C (see [The C
  Compiler](compiler.md)). Each one is the work that the engine does.

The system has no disk, so the engine program travels inside the SPARC
program, as a C array. The tool `compiler/apara/apara_obj_to_c.py`
assembles an engine program and writes it as a C header. The SPARC
program includes this header, and at run time copies the array into the
engine's IMEM. A program is therefore built in two steps:

1. `apara_obj_to_c.py kernel.mcode` writes `kernel.mcode.h`, the engine
   program as a C array.
2. `compile_c.sh main.c` compiles the SPARC program, which includes
   `kernel.mcode.h`, into a memory image, `main.hex`.

The memory image is then run on either model of the `sparc_apara`
configuration, in the same way as any other SPARC program.

---

## An example: offloading a dot product

The test `validation/sparc_apara/basic/dma_dot_product/` offloads a dot
product of two 32-element `int8_t` vectors to the engine. Its memory
image is already built, so it runs without a cross-toolchain.

### Run it

The following commands build the C++ model of `sparc_apara`, and run the
test's memory image on it:

```sh
cd $SPARC_HOME/model/system_models/sparc_apara/cpp_model
./build.sh
./executable/sparc_sim_cpp_sparc_apara $SPARC_HOME/validation/sparc_apara/basic/dma_dot_product/dma_dot_product.hex
```

The run ends with the processor's final state. The lines that matter
are the following:

```
PROCESSOR STATE: ERROR
...
o0 0x1
o1 0xf
...
Simulation halted after 9793 cycles.
```

The test reports in the same way as the device tests. `%o0` is 1 if
every check passed, and `%o1` has one bit per check. Here all four
checks passed, so `%o1` is `0xf`. The state `ERROR` is how every program
in this repository halts.

The Sitar model is built and run in the same way, in its own folder.
With `--stats`, it also prints the engine's pipeline counters:

```sh
cd $SPARC_HOME/model/system_models/sparc_apara/sitar_model
./build.sh
./executable/sparc_sim_sitar_sparc_apara $SPARC_HOME/validation/sparc_apara/basic/dma_dot_product/dma_dot_product.hex --stats
```

```
...
APARA engine:
bundles fetched          15
bundles executed         8
bundles skipped          7  (wrong path or stopped thread)
...
register-lock stalls     11 cycles
REGFILE token stalls     2 cycles
DMEM bank conflicts      6
...
Simulation halted after 62470 cycles.
```

The Sitar model counts clock cycles of the modeled hardware, including
every bus transaction of the SPARC's commands and of the DMA copies. The
C++ model counts SPARC instructions, so its count is much smaller.

### The engine program

The engine program, `kernel.mcode`, loads both vectors from DMEM,
computes four 8-element dot products in one bundle, adds them up, and
stores the 64-bit result back in DMEM:

```mcode
--8<-- "validation/sparc_apara/basic/dma_dot_product/kernel.mcode"
```

Each line that starts with `||` is one bundle, whose instructions run
together.

1. The first two bundles each load four 64-bit words, which is 32 bytes.
   The first loads vector `a` from `$r9` into `$r1` to `$r4`, and the
   second loads vector `b` from `$r10` into `$r5` to `$r8`.
2. The third bundle computes four dot products at once. Each `$dot`
   treats its two registers as eight `$i8` elements (the type `($vi8)`),
   and adds up their eight products.
3. The next two bundles add the four partial sums into one.
4. The sixth bundle stores the result at `$r9 + 504`, and the last one
   stops the thread with `$halt`.

The program never names a fixed address. The SPARC program passes the
addresses of the two vectors in `$r9` and `$r10`. These addresses are
in DMEM's window, so the engine's loads and stores stay local (see [The
engine's own view](system.md#the-engines-own-view)).

### The SPARC program

The SPARC program, `dma_dot_product.c`, is the following:

```c
--8<-- "validation/sparc_apara/basic/dma_dot_product/dma_dot_product.c"
```

It follows the five steps that every offload takes:

1. **Load the engine program.** `apara_load_program` copies
   `kernel_program[]`, from the generated header `kernel.mcode.h`, into
   IMEM.
2. **Move the input data into DMEM.** Two DMA channels copy the two
   vectors from main memory at the same time. Channel 0 copies `a` to
   DMEM offset 0, and channel 1 copies `b` to offset 256.
   `apara_dma_wait` waits for each channel, and returns its status.
3. **Set the thread's registers, and start it.** `$r9` and `$r10` get
   the window addresses of the two vectors. `apara_start_thread` starts
   thread 0 at `KERNEL_START`, the address of the label `start`, which
   the header defines.
4. **Wait for the thread to stop.** `apara_wait_thread` polls the
   control unit until the thread stops, and returns its completion word.
   A thread that ended with `$halt` reports `APARA_COMPLETION_VALID |
   APARA_ERROR_HALT`.
5. **Move the results back.** A third DMA channel copies the 8-byte
   result from DMEM offset 504 to `result[]` in main memory.

The SPARC program computes the expected dot product itself, and
compares it with the engine's. The SPARC has no 64-bit multiply, so it
checks the result as two 32-bit halves. It reads them with
`physical_word`, an MMU-bypass load, because the DMA unit's write to
main memory does not reach the SPARC's data cache (see [The SPARC's data
cache](#the-sparcs-data-cache)). Two helpers come from the suite's
shared header, `validation/sparc_apara/apara_common.h`. These are
`physical_word`, and `report_and_halt`, which writes the result to `%o0`
and `%o1` and halts.

---

## The routines

`compiler/include/apara_access_routines.h` provides C routines for every
step of an offload, in the same style as the device routines of
`ajit_access_routines.h` (see [Writing and Running C
Programs](../writing_and_running_c_programs.md#using-the-peripheral-devices)).
The header is on the compiler's include path, so a SPARC program
includes it by name:

```c
#include "apara_access_routines.h"
```

Every routine uses MMU-bypass accesses. A routine therefore works
whether or not the MMU is enabled, and never goes through the caches.

| Routine | Does |
|---|---|
| `apara_load_program(words, n)` | Writes words 0 to n-1 of IMEM. |
| `apara_write_imem(i, w)`, `apara_read_imem(i)` | Write or read one IMEM word. |
| `apara_write_thread_register(t, r, v)`, `apara_read_thread_register(t, r)` | Write or read a thread's 64-bit register. |
| `apara_start_thread(t, pc)` | Starts thread `t` at `pc`, a label's address from the program's header. |
| `apara_reset_thread(t)` | Stops thread `t`, and clears its PC, return-address stack, and ERROR. Its registers are kept. |
| `apara_poll_thread(t)` | Returns the thread's completion word. This is 0 while it is running, or valid plus its ERROR once it has stopped. Each stop is reported once. |
| `apara_wait_thread(t)` | Polls until the thread stops, and returns its completion word. |
| `apara_thread_stop_pc(t)` | Returns where the thread stopped. |
| `apara_request_completion_interrupt(t)`, `apara_thread_completion(t)`, `apara_clear_interrupt(t)` | Learn of a stop by interrupt instead (see [Polling or an interrupt](#polling-or-an-interrupt)). |
| `apara_dma_start(c, op, src, dst, bursts, gap, bytes_per_burst, irq)` | Starts DMA channel `c` (see [The DMA unit](system.md#the-dma-unit)). |
| `apara_dma_done(c)`, `apara_dma_wait(c)` | Whether channel `c` has finished, and waiting for it. |
| `apara_dma_load(c, dmem, src, n)`, `apara_dma_store(c, dst, dmem, n)` | One contiguous copy of `n` bytes into or out of DMEM, waiting for it to finish. |
| `apara_dma_clear_interrupt(c)` | Clears channel `c`'s interrupt. |
| `apara_dmem_write_word(o, v)`, `apara_dmem_read_word(o)` | Write or read a 32-bit word of DMEM at byte offset `o`, directly. |
| `apara_dmem_read_dword(o)` | Reads a 64-bit word of DMEM. The high half is at the lower address. |
| `apara_load_dmem_image(pairs, n)` | Writes a C engine program's initialized globals into DMEM (see [Carrying the engine's program](#carrying-the-engines-program)). |
| `apara_read_timer()` | Returns the engine's cycle counter. |

The bits of the completion word have names. These are
`APARA_COMPLETION_VALID`, `APARA_ERROR_HALT`, `APARA_ERROR_EXCEPTION`,
`APARA_ERROR_RAS`, and `APARA_ERROR_CODE(word, slot)` for a slot's
exception code. A thread that ended with `$halt` reports
`APARA_COMPLETION_VALID | APARA_ERROR_HALT`. The header also defines
`APARA_DMEM_BASE`, the address of DMEM's window.

---

## Setting up and running the engine

This section gives the protocol that a SPARC program follows to use the
engine, and what is allowed at each step. Each step has a test in
`validation/sparc_apara/`, named in brackets. The tests are described in
[APARA Validation Suite](validation.md).

### At power-up

No engine thread runs, and IMEM, DMEM and every register of every thread
are zero (`setup/cold_state`). The engine's cycle counter runs from
power-up. Nothing needs to be initialized before the first command.

### The steps

1. **Load the program** into IMEM, one word at a time, through the
   control unit, with `apara_load_program(words, n)`. IMEM is shared by
   the four threads, so one program image serves all of them, and each
   thread starts at its own label. `apara_read_imem` reads a word back
   (`setup/load_verify` checks a whole image).
2. **Put the input data in DMEM**, in one of two ways:
    - Directly, through the DMEM window, one 32-bit word at a time, with
      `apara_dmem_write_word`. This is simple, but each word is a bus
      access by the SPARC.
    - By DMA, which copies from main memory while the SPARC goes on with
      other work. `apara_dma_load` copies and waits. `apara_dma_start`
      and `apara_dma_wait` let the SPARC overlap several copies, or do
      its own work in the meantime. A copy can also gather strided data.

    An engine program compiled from C may also need its initialized
    globals, which `apara_load_dmem_image` writes (see [Carrying the
    engine's program](#carrying-the-engines-program)).

3. **Set each thread's registers**, its arguments, with
   `apara_write_thread_register`, and **start it** at an IMEM address,
   with `apara_start_thread`. Threads may be started one after another,
   or at different times (`threads/staggered`).
4. **Learn that the thread has stopped**, by polling or by an interrupt
   (see [Polling or an interrupt](#polling-or-an-interrupt)). The
   completion word says how the thread stopped. A thread that ended with
   `$halt` reports `APARA_COMPLETION_VALID | APARA_ERROR_HALT`. After an
   exception, the word has `APARA_ERROR_EXCEPTION` and each slot's
   exception code (`APARA_ERROR_CODE(word, slot)`), and
   `apara_thread_stop_pc` gives the bundle that failed.
5. **Collect the results** from DMEM, either directly, with
   `apara_dmem_read_word` and `apara_dmem_read_dword`, or by DMA to main
   memory, with `apara_dma_store`.
6. **Start again**, for the next piece of work. A thread that stopped
   with `$halt` can be started again at once, with new registers. A
   thread stopped by an exception must first be reset with
   `apara_reset_thread`, which clears its PC, return-address stack and
   ERROR, and keeps its registers (`interference/fault_isolation`). A
   new program may be loaded over the old one between runs
   (`setup/reload_program`).

`setup/offload_poll` and `setup/offload_interrupt` carry out all six
steps for an engine program compiled from C.

### Polling or an interrupt

- **Polling.** `apara_poll_thread(t)` returns 0 while the thread runs,
  and its completion word once it has stopped. `apara_wait_thread(t)`
  polls until then. Each poll is a control-unit command, which takes
  several bus accesses. Polling is the simplest choice for a SPARC
  program that has nothing else to do while it waits.
- **An interrupt.** `apara_request_completion_interrupt(t)` asks the
  control unit to raise the engine's interrupt when thread `t` stops.
  The SPARC goes on with its own work. Its interrupt handler reads the
  completion word with `apara_thread_completion`, and clears the
  interrupt with `apara_clear_interrupt`.

A program that takes interrupts is linked with the interrupt startup
code, `compiler/crt0_interrupts.s`. It registers its handler with the
dispatch routines of `compiler/include/ajit_mt_irc.h` (see [Taking
interrupts](../writing_and_running_c_programs.md#taking-interrupts)), and
enables IRL 14 in the Interrupt Controller. The following lines are from
`validation/sparc_apara/basic/run_interrupt/`:

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

In the validation suite, the line `STARTUP = crt0_interrupts.s` in the
test's `.vprj` selects the interrupt startup code. Outside the suite,
the environment variable `CRT0` does the same:

```sh
CRT0=crt0_interrupts.s $SPARC_HOME/compiler/compile_c.sh my_program.c
```

Either way, **each stop is reported exactly once**. After a poll has
returned a thread's stop, the next poll returns 0 until the thread has
been started and has stopped again (`threads/staggered`). A program that
polls several threads can therefore poll them in any order, and never
counts one stop twice.

### What may happen while threads run

- **Each thread on its own data.** Threads do not disturb one another
  as long as each writes only its own part of DMEM
  (`interference/disjoint_regions`). One thread's exception stops only
  that thread (`interference/fault_isolation`).
- **The SPARC and the DMA unit** may read and write other parts of DMEM
  while threads run, and may watch a running thread's progress word
  (`interference/host_while_running`, `interference/dma_while_running`).
- **Not while running.** Loading IMEM, or writing a running thread's
  registers, is not allowed while the thread runs. The control unit
  carries out such commands, but when they take effect in the running
  thread is undefined. The SPARC program should wait for the thread to
  stop first, or stop it with `apara_reset_thread`.

### Threads sharing data

The engine's instruction set has no atomic read-modify-write. Threads
that update the same DMEM word with a load, an add and a store
therefore race. Another thread's update can fall between one thread's
load and its store, and is then lost. The test
`interference/shared_counter` shows this. In it, four threads each add 1
to one word, 1000 times, and the word ends below 4000. Threads should
therefore work on their own data, and leave the SPARC to combine their
results, as `linalg/dot_threads` does with four partial dot products.

### The SPARC's data cache

The engine's windows are never cached, and the routines reach them with
MMU-bypass accesses. Main memory may be cached, in the pages that the
MMU marks cacheable, and the caches do not see the engine's writes.
After the DMA unit, or an engine program, writes main memory, the SPARC
should read that data straight from memory with an MMU-bypass load (the
tests' `physical_word`), or flush its data cache first (see [Model
Components](../model_components.md#caches)).

### Floating point on the SPARC side

The SPARC's startup code (`compiler/crt0.s`) leaves the FPU off. A SPARC
program that computes with floats, for example to check an engine's
float results, turns the FPU on first, by setting the PSR's EF bit. The
helper `enable_fpu` in `validation/sparc_apara/apara_common.h` does this
(`linalg/saxpy`).

---

## Carrying the engine's program

`compiler/apara/apara_obj_to_c.py` assembles an engine program and
writes it as a C header:

```sh
python3 $SPARC_HOME/compiler/apara/apara_obj_to_c.py kernel.mcode      # writes kernel.mcode.h
```

```c
static const uint32_t kernel_program[] = { ... };   // IMEM words 0, 1, ...
#define KERNEL_PROGRAM_WORDS 33
#define KERNEL_START 0x0                             // each label's address
```

The names come from the file name, and the option `--name` chooses
another.

An engine program written in C (see [The C Compiler](compiler.md)) is
handled in the same way. `apara_obj_to_c.py kernel.c` compiles it for
the system, with DMEM at its window address, and writes `kernel.c.h`.
That header also gives each global variable's DMEM byte offset, and the
DMEM words that its initializers set:

```c
#define KERNEL_DMEM_DATA 0x0                              // each global's DMEM offset
static const uint32_t kernel_dmem_image[] = { ... };     // (offset, value) pairs
#define KERNEL_DMEM_IMAGE_WORDS 6
```

The SPARC program then loads the program and the initial data, puts its
input at the globals' offsets, and reads the results from them:

```c
apara_load_program(kernel_program, KERNEL_PROGRAM_WORDS);
apara_load_dmem_image(kernel_dmem_image, KERNEL_DMEM_IMAGE_WORDS);
apara_dma_load(0, KERNEL_DMEM_DATA, (uint32_t) data, sizeof(data));
```

The parameters of an `__entry` function arrive in `$r1`, `$r2`, and so
on, which are set with `apara_write_thread_register` before the thread
starts. The image holds only the non-zero words. DMEM keeps whatever an
earlier program left in it, so the SPARC program clears any globals that
must start at zero, unless this is the first program since power-up.
The test `setup/offload_poll` is a complete example. Its engine program,
`vector_stats.c`, computes the sum, minimum and maximum of 64 values.

---

## Writing a new program

*This section needs the cross-toolchain (step 4 of
[Installation](../installation.md)), and the `sparc_apara` models built
as in [Run it](#run-it).*

This section builds a new program from scratch. The SPARC program
offloads a vector addition, Z = X + Y on 32 `int16` elements, to the
engine, and checks the engine's result. Its two source files are in
`$SPARC_HOME/docs/source/examples/apara_vadd/`. They can be typed in from
this page, or copied from there.

### 1. Make a working folder

The following commands create a working folder outside the repository,
and copy the two source files into it:

```sh
mkdir -p ~/apara_programs/my_vadd
cd ~/apara_programs/my_vadd
cp $SPARC_HOME/docs/source/examples/apara_vadd/vadd.mcode .
cp $SPARC_HOME/docs/source/examples/apara_vadd/my_vadd.c .
```

### 2. Write the engine program

The engine program, `vadd.mcode`, is the following:

```mcode
--8<-- "docs/source/examples/apara_vadd/vadd.mcode"
```

The SPARC program places X at DMEM offset 0 and Y at offset 64, and
passes DMEM's window address in `$r9`. The program works as follows:

1. The first bundle sets `$r20` to the start of the arrays, and the loop
   counter `$r22` to 1, for two passes.
2. In each pass, the first bundle of the loop loads 16 elements of X
   into `$r1` to `$r4`, and 16 elements of Y into `$r5` to `$r8`. Each
   `($u256)` load reads 256 bits, which is four registers.
3. The next bundle adds them with four vector adds. Each `$v +` with
   the type `($vi16)` adds four pairs of 16-bit elements.
4. The third bundle stores the 16 sums at `$r20 + 128`, in Z, and moves
   `$r20` on by 32 bytes. Both instructions read the old value of
   `$r20`, because all instructions of a bundle read their registers
   before any of them writes.
5. The branch counts `$r22` down, and goes back to `loop` while it is
   above zero. After two passes the thread reaches `$halt`.

### 3. Turn it into a C header

The following command assembles the engine program, and writes it as a
C header:

```sh
python3 $SPARC_HOME/compiler/apara/apara_obj_to_c.py vadd.mcode
```

The header, `vadd.mcode.h`, holds the program as the array
`vadd_program[]`, its size, and the address of each label:

```c
#define VADD_PROGRAM_WORDS 41

#define VADD_START 0x0
#define VADD_LOOP 0x8
```

The header must be written again after every change to `vadd.mcode`.

### 4. Write the SPARC program

The SPARC program, `my_vadd.c`, is the following:

```c
--8<-- "docs/source/examples/apara_vadd/my_vadd.c"
```

It takes the same steps as the dot product example. It loads the
program, copies X and Y into DMEM by DMA, passes DMEM's window address
in `$r9`, starts thread 0 at `VADD_START`, and waits for the thread to
stop. This time it reads the results directly from DMEM, with
`apara_dmem_read_word`. Each 32-bit word of DMEM holds two `int16`
elements, and the first element is in the upper half, because DMEM is
big-endian like the SPARC. The program then reports pass (1) or fail
(0) in `%o0`, and halts with `ta 0`.

### 5. Compile it

The following command compiles the SPARC program into a memory image:

```sh
$SPARC_HOME/compiler/compile_c.sh my_vadd.c
```

It writes `my_vadd.hex`, and the disassembly `my_vadd.objdump`. It may
warn that the section `.data` does not exist. The warning is expected,
because the program has no initialized data.

### 6. Run it

The following command runs the memory image on the C++ model:

```sh
$SPARC_HOME/model/system_models/sparc_apara/cpp_model/executable/sparc_sim_cpp_sparc_apara my_vadd.hex
```

```
PROCESSOR STATE: ERROR
...
o0 0x1
...
Simulation halted after 11587 cycles.
```

`%o0` is 1, so every element of Z was right. The Sitar model gives the
same result, in 73590 clock cycles:

```sh
$SPARC_HOME/model/system_models/sparc_apara/sitar_model/executable/sparc_sim_sitar_sparc_apara my_vadd.hex
```

As in [Getting Started](../getting_started.md#check-the-result-automatically),
an expected-results file makes the simulator check the result itself.
The following commands write one, with the single line `REG o0 0x1
0xffffffff`, and run the check:

```sh
echo "REG o0 0x1 0xffffffff" > my_vadd.expected
$SPARC_HOME/model/system_models/sparc_apara/cpp_model/executable/sparc_sim_cpp_sparc_apara my_vadd.hex my_vadd.expected
```

```
PASS: o0 = 0x1
OVERALL: PASS (1 checks)
```

### 7. Try a change

To see a failure, change the first `$v +` in `vadd.mcode` to `$v -`,
so that four of the 32 elements are subtracted instead of added. Then
write the header again, compile, and run:

```sh
python3 $SPARC_HOME/compiler/apara/apara_obj_to_c.py vadd.mcode
$SPARC_HOME/compiler/compile_c.sh my_vadd.c
$SPARC_HOME/model/system_models/sparc_apara/cpp_model/executable/sparc_sim_cpp_sparc_apara my_vadd.hex my_vadd.expected
```

The SPARC program's check now fails, so `%o0` is 0, and the run
reports the failure:

```
FAIL: o0 expected 0x1 (mask 0xffffffff) got 0x0
OVERALL: FAIL (1 checks)
```

Change the instruction back, and write the header again, before going
on.

### 8. Make it a test

A `.vprj` file turns the program into a test, which the validation
runner builds and runs. The file `my_vadd.vprj` names the SPARC program
and its engine program, and the expected result:

```text
--8<-- "docs/source/examples/apara_vadd/my_vadd.vprj"
```

The line `MCODE = vadd.mcode` makes the build script write
`vadd.mcode.h` before it compiles the SPARC program. The following
commands copy the file, build the test, and run it on the C++ model of
`sparc_apara`:

```sh
cp $SPARC_HOME/docs/source/examples/apara_vadd/my_vadd.vprj .
cd $SPARC_HOME
python3 validation/build_hex.py ~/apara_programs/my_vadd
python3 validation/run_tests.py ~/apara_programs/my_vadd --config sparc_apara
```

```
[PASS] .../my_vadd/my_vadd.vprj

1/1 tests passed
```

The option `--sitar` runs it on the Sitar model instead. [APARA
Validation Suite](validation.md) describes the format of the tests, and
how to add a test to the suite itself.

### Going further

The tests in `validation/sparc_apara/` are worked examples of the next
steps. Each one is a SPARC program with its engine programs, and can be
copied and changed in the same way as `my_vadd`.

| To learn | Start from |
|---|---|
| Running one program on four threads, each on its own part of the data | `threads/threads_4` |
| Writing the engine program in C | `setup/offload_poll`, with `vector_stats.c` |
| Learning of a stop by interrupt | `basic/run_interrupt`, and `setup/offload_interrupt` |
| Gathering strided data with one DMA copy | `basic/dma_interrupt` |
| An exception in an engine thread, and recovering from it | `basic/exception`, and `interference/fault_isolation` |
| A larger kernel, a matrix product on four threads | `linalg/matmul` |

On the Sitar model, `--stats` shows where the engine's time went, for
example in register-lock stalls or DMEM bank conflicts. The counters
are described in [APARA Timing Model](timing_model.md#knobs).
