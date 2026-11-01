# Execution Model

Real cores run at the same time. A simulator has to decide how to run
them, and the two models in this project decide differently. The
difference matters when reading results. It decides what a "cycle"
means in each model, how the peripheral devices keep time, and why a
program can produce different results on the two models.

---

## The cpp_model: cores take turns

The cpp_model has no clock. It runs on one host thread, and executes
one core's instruction at a time, to completion, before the next one
starts. The cores therefore take turns, and a **scheduler** decides the
order.

Execution proceeds in **rounds**. In each round, every running core
gets one **turn**, in an order the scheduler picks, and executes some
number of instructions in a row during it. The cores are thought of as
running side by side during a round, so a round lasts as many **model
cycles** as its longest turn. At the end of the round the peripheral
devices tick once per model cycle of the round, and then every core's
interrupt input takes the level the Interrupt Controller now presents
for it.

Three scheduling strategies are available, chosen with `--schedule`
(or the `SPARC_SCHEDULE` environment variable).

| Strategy | Order within a round | Turn length |
|---|---|---|
| `rr:K` (the default is `rr:1`) | Round-robin. The core that goes first moves on by one every round, so no core is always first. | `K` instructions |
| `rr-fixed:K` | Round-robin, with core 0 always first. | `K` instructions |
| `random:S[:M]` | A random order of the running cores, each round. | Random, 1 to `M` instructions (default `M` = 8) |

The random strategy draws from a generator seeded with `S`, so the same
seed always gives the same interleaving, on any host.

With one core and `rr:1`, a round is one instruction followed by one
device tick, which is exactly how the single-core configurations run.
The `multicore` cpp_model with one core running therefore reproduces
`core_l1cache_mmu_devices` cycle for cycle.

Because each instruction runs to completion before any other starts,
every instruction is atomic in the cpp_model. An `LDSTUB` or `SWAP`
reads and writes memory with no other core able to come in between.

---

## The sitar_model: cores run side by side

In the sitar_model each core is its own Sitar module. All cores advance
together, cycle by cycle, each executing at most one instruction per
cycle. The cores meet only at the shared bus (see [Model Structure and
Assumptions](structure.md#the-shared-bus)), which serves one request at a time and grants
the cores in round-robin order. A core whose request is waiting for the
bus waits, while the others go on.

Every crossing of a net costs at least one cycle, so an access that
leaves a core takes several cycles, and longer still when other cores
are using the bus. A cache hit stays inside the core and costs no bus
time at all. The peripheral devices tick once per cycle, and each core
receives its interrupt level over its own net, one cycle after the
Interrupt Controller changes it.

The effect of the shared bus can be seen directly. In the validation
test `multicore/boot/staggered_halt`, core `i` counts to
`(i + 1) * 3000`. With the MMU off nothing is cached, so every
instruction fetch of every core goes through the bus.

| Cores running | Cycles until every core halts (no caching) |
|---|---|
| 1 | about 171,000 |
| 2 | about 388,000 |
| 3 | about 714,000 |
| 4 | about 1,148,000 |

With caching turned on (`SPARC_ALWAYS_CACHEABLE=1`), four cores finish
in about 147,000 cycles, because nearly every fetch then hits in each
core's own cache.

---

## Why the two models can give different results

Each model interleaves the cores' memory accesses in its own way. In
the cpp_model the scheduler alone decides the interleaving. In the
sitar_model it follows from every instruction's latency and every wait
at the bus. Even with every Sitar latency knob at 0, crossing a net
still costs a cycle, so the two models never interleave the cores in
exactly the same way.

- A program whose result does not depend on the order in which the
  cores' accesses happen, such as one where each core works on its own
  data and the cores synchronize correctly, gives the same result on
  both models, and under every cpp scheduling strategy.
- A program whose result does depend on that order, a program with a
  data race, can give different results on the two models, and on the
  cpp_model under different strategies or seeds. This is the behavior
  of real hardware too. The random strategy exists to expose such
  programs, by trying many interleavings.

A program's result can therefore be trusted only if it is the same
under every interleaving. Running a test under several schedules is a
quick way to check that.

---

## Devices and time in the cpp_model

The single-core cpp_models have the same question to answer for the
Timer, which counts time although the cpp_model has none. There, the
devices tick once after every instruction, so one instruction is one
model cycle and the timer counts instructions. The multicore cpp_model
keeps that meaning for each core. A round lasts as long as its longest
turn, so a timer set to fire after `n` cycles fires after each core has
executed about `n` instructions, whatever the number of cores.
