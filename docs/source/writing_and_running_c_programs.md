# Writing and Running C Programs

Hand-assembling an algorithm like a sort or an FFT one instruction at a
time, the way `validation/asm/`'s tests do, is tedious once the program
is more than a handful of instructions long (see
[Validation Suite](validation_suite.md)). `validation/C/` takes the
other approach: write the test as ordinary, freestanding C, compile it
with the bundled cross-toolchain, and run it the same way. This page
covers writing one, building and running it, and checking its result.

---

## No standard library, by design

This model has **no operating system**. There is nothing for a C
standard library to call into. `printf` has no console to write to.
`malloc` has no OS to request pages from. C programs for this model must
be **freestanding**: no `#include <stdio.h>`, no libc at all, just the C
language itself plus whatever you implement by hand against the flat
memory space `MemCore` provides.

In the configurations with devices (`core_mmu_devices` and up), the
[Serial Device](peripheral_devices_serial_device.md) is the console: a
program writes characters to it, and the simulator prints them. See
[Using the peripheral devices](#using-the-peripheral-devices) below.

---

## Structuring a test program

Write an ordinary, freestanding C `main()`. Every test in
`validation/C/` follows the same self-validating shape: compute
something, compare it against a golden value computed once on the host
machine and hardcoded right there in the source, and report pass(1)/
fail(0) in `%o0`. Here's a real one in full,
`validation/C/array_sum/array_sum.c`, summing a small array:

```c
--8<-- "docs/source/examples/array_sum/array_sum.c"
```

`main()` must never return, since there's nothing to return into. The way
to end a test is the same mechanism `validation/asm/` tests use, described
in full in
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md#the-pass-fail-convention):
a single line of inline assembly, `__asm__ volatile ("ta 0")`, at the end
of `main()`.

Unlike an assembly test, you don't write any of the surrounding setup by
hand. `compiler/crt0.s` is linked ahead of your compiled `.c` file (entry
point overridden to `crt0.s`'s own `_start`) and does it for you:

- enables traps and installs the same 256-entry trap table every
  `validation/asm/` test installs,
- sets up a working stack (needed for any C function using a local
  variable, which `%sp` starting at `0` does not provide on its own),
- initializes `%g1` as the pass/fail sentinel,
- then calls your `main()`.

It leaves the FPU off (the PSR's EF bit clear), so a program that
computes with `float` or `double` sets EF itself first, or its first
floating-point instruction traps. `validation/sparc_apara/apara_common.h`
has a small `enable_fpu()` that does this.

Here's what that looks like once linked, `array_sum`'s actual entry
point, before `main` even runs:

```
--8<-- "docs/source/examples/array_sum/array_sum.objdump:start-disasm"
```

Matching it up against the four steps above: the `mov 0xe0,%l0`/`wr
%l0,%psr` pair enables traps (see
[Writing and Running Assembly Programs](writing_and_running_assembly_programs.md)
for the `0xE0` encoding), `sethi`/`wr ...,%tbr` points `TBR` at the trap
table linked in right after it (`HW_trap_0x00` onward, the annotation on
that line), `sethi`/`or ...,%sp` sets up the stack, `mov 0xbad,%g1` is
the sentinel, and the final `call main` (with its delay-slot `nop`) is
the handoff into your code. See `crt0.s` itself for the full explanation
of each step.

The result is that a C test's `ta 0` halts exactly the same way an
assembly test's does, and an unexpected trap during your test is caught
the same way too.

Checking the result is then a single line. Its `.vprj` only ever has to
check that `%o0` is `1`:

```
--8<-- "validation/C/array_sum/array_sum.vprj"
```

!!! note "The alternative: checking memory directly"
    Writing a raw computed value to a global and checking it directly
    via a `.vprj` `MEM` line (the address found in the `.objdump`'s
    symbol table, or `readelf -s array_sum.elf` directly) still works.
    It's the same
    [`REG`/`MEM` format](validation_suite.md#the-vprj-expected-results-format)
    `validation/asm/` uses, but means the golden value is embedded in
    two places (the `.vprj` and, since the test already computes its own
    pass/fail, the source) instead of one. Doing the comparison in C and
    reporting a single pass/fail flag avoids that, and doubles as a
    self-contained mini-benchmark that also happens to check itself. See
    the rest of `validation/C/` for more worked examples.

---

## Building and running it

A minimal, freestanding C compiler (GCC 4.4.3) is bundled alongside the
existing `sparc-elf` assembler, linker, `readelf`, and `objdump`,
installed together by [Installation](installation.md) step 4, if you
haven't already. See [Cross Compiler](cross_compiler.md) for what's
bundled and why, and for building your own, more modern cross-toolchain
instead.

```sh
compiler/compile_c.sh your_program.c
```

This produces `your_program.hex`, the same kind of memory image
`compiler/assemble.sh` produces for assembly tests, loadable the same
way. It also produces `your_program.objdump`:
a readable disassembly of the linked program (useful for seeing what the
compiler actually generated, unlike a hand-written `.s` file, this isn't
something you wrote directly), followed by the full symbol table,
function and global-variable addresses included. See
[Examining Core State at Runtime Using GDB](examining_core_state_with_gdb.md#finding-addresses).

Run it directly against the model the same way as an assembly test, see
[Running a test program](writing_and_running_assembly_programs.md#running-a-test-program):

```sh
model/system_models/core_only/cpp_model/executable/sparc_sim_cpp_core_only your_program.hex
```

---

## Using the peripheral devices

`compiler/include/` holds header-only routines for the devices.
`compile_c.sh` puts that folder on the include path.

| Header | Provides |
|---|---|
| `device_addresses.h` | Every device register address (`ADDR_TIMER_CONTROL_REGISTER`, ...) and interrupt level (`TIMER_IRL`, ...). |
| `ajit_access_routines.h` | Physical (MMU-bypass) loads and stores, `ajit_get_core_and_thread_id()`, and the Timer and Serial routines, e.g. `__ajit_serial_putchar_via_bypass__()`, `__ajit_serial_getchar_via_bypass__()`, `__ajit_write_timer_control_register_via_bypass__()`. |
| `ajit_mt_irc.h` | Interrupt Controller routines (`enableInterruptController()`, `writeInterruptControlRegister()`, ...) and interrupt dispatch (`ajit_set_interrupt_handler()`). |
| `ajit_ipi.h` | Inter-processor interrupts (`__ajit_set_ipi_interrupt__()`, ...). |
| `apara_access_routines.h` | The APARA engine, in `sparc_apara`: loading its program, starting its threads, its DMA unit (`apara_load_program()`, `apara_start_thread()`, ...). See [The Engine in a System](apara/system.md#software). |
| `stdint.h` | `uint32_t` and friends, which the bundled compiler does not provide on its own. |

Printing a message:

```c
#include "ajit_access_routines.h"

int main(void)
{
    char message[] = "Hello from SPARC\n";
    __ajit_serial_configure_via_bypass__(1, 0, 0);   //enable the transmitter
    __ajit_serial_puts_via_bypass__(message, sizeof(message) - 1);
    __asm__ volatile ("ta 0");
    while (1) {}
}
```

### Taking interrupts

The default startup code, `crt0.s`, halts on every trap other than the
final `ta 0`. A program that takes interrupts links
`compiler/crt0_interrupts.s` instead, which also handles register
window overflow and underflow, and sends every interrupt to
`ajit_generic_interrupt_handler()` (in `ajit_mt_irc.h`). That function
disables the thread's Interrupt Controller slot, calls the handler
registered for the interrupt's level, and enables the slot again (the
sequence on the [Interrupt
Controller](peripheral_devices_interrupt_controller.md#handling-an-interrupt)
page). The handler itself only has to clear its source:

```c
#include "ajit_access_routines.h"
#include "ajit_mt_irc.h"

volatile int ticks = 0;

void timer_handler(void)
{
    ticks++;
    __ajit_write_timer_control_register_via_bypass__(0);   //clear the source
}

int main(void)
{
    ajit_initialize_interrupt_handlers_to_null();
    ajit_set_interrupt_handler(TIMER_IRL, timer_handler);
    writeInterruptControlRegister(0, 0, (1 << TIMER_IRL) | 1);   //slot 0: enable, timer level
    __ajit_write_timer_control_register_via_bypass__((1000 << 1) | 1);
    while (ticks == 0) {}
    __asm__ volatile ("ta 0");
    while (1) {}
}
```

Select the interrupt startup code with a `STARTUP` line in the test's
`.vprj` (see below), or with `CRT0=crt0_interrupts.s compile_c.sh ...`
on the command line. Handlers run with traps enabled but every
maskable interrupt masked, so they do not nest.

---

## Adding it to the validation suite

Same two-phase pipeline as `validation/asm/`, see
[Validation Suite](validation_suite.md#the-validation-script).
`build_hex.py` picks `compiler/assemble.sh` or `compiler/compile_c.sh`
automatically, based on whether a test's `SOURCES` line names a `.s` or
a `.c` file. See
[Validation Suite: Adding a C test](validation_suite.md#adding-a-c-test)
for the exact steps.
