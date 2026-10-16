# validation/apara/

The APARA engine's own test suites, on the standalone `apara`
configuration (the engine alone: the program and its data are placed in
IMEM and DMEM before the run). They have their own runner, since they
are engine programs, not SPARC programs.

```bash
python3 validation/apara/run_tests.py                          # every suite, on the cpp_model
python3 validation/apara/run_tests.py --sitar                  # on the sitar_model: also cycles, mispredicts, hazards
python3 validation/apara/run_tests.py validation/apara/isa     # one suite (or one .vprj)
python3 validation/apara/run_tests.py --reference --mcode-run <mcode_run>   # cross-check (for the model's authors)
```

| Folder | What it checks |
|---|---|
| `isa/` | Every instruction, one folder per class (`alu_int`, `alu_float`, `vector`, `cast`, `bits`, `cmov`, `memory`, `control`): each operation on each type, edge values (wraparound, sign extension, rounding, saturation), immediates and increments at their limits, and every exception. |
| `sequences/` | Instructions working together: full 8-slot bundles (every lane, bundle semantics), loops, a Fibonacci recurrence in one bundle per step, a block copy with auto-increments, threads sharing DMEM byte by byte, one thread's fault not stopping the others. |
| `hazards/` | The REGFILE interlock: every kind of read-after-write dependence (scalar, chains, multi-register writes, increments, accumulations, store data, long latencies), and what is not a dependence (WAR, WAW, other threads, memory order). See below. |
| `predictor/` | The branch predictor (BTB): loops, nested loops, aliasing entries, calls and returns. `MISPREDICTS` counts derived from the predictor's rules. |
| `asm_errors/` | Programs the assembler must reject: two writes to one register in a bundle (also through multi-register writes and increments), too many controls, divides or memory operations in a bundle, values out of range, invalid types. |
| `timing/` | Microbenchmarks with exact cycle counts (Ref `timing/README.md`, also for the timing knobs). |
| `kernels/` | Larger programs in hand-scheduled mcode: dot product, vector add, SAXPY, reduction, matrix multiply on one and four threads. |
| `c_programs/` | Programs compiled from C with `compiler/apara/apcc.py`: the language's features (functions, loops, types, inline mcode), sorting, a prime sieve, and linear algebra (dot products, matrix multiply on three threads, SAXPY, vector add with intrinsics). |
| `deviations/` | Where the model departs from the engine's reference model on purpose (see the documentation's APARA Deviations and Findings page). |

`build/` (gitignored) holds each test's generated files: object, data,
register and results files, and the compiled mcode of a C test.

## A test

A test is a source file and a `.vprj` of the same name, in the same
spirit as the SPARC tests' `.vprj` (Ref `apara_vprj.py` for every key):

```
SOURCES = cmov.mcode           an mcode program, a C program (.c), or an object file (.obj)
THREADS = 0x0 worker           start a thread at each PC or label (default: one at 0x0)
CYCLES = 12                    the exact cycle count on the timing model (default knobs)

INIT =                         the state before the run
r3 = 0x10                      thread 0's $r3 (t1.r3: thread 1's)
m[0x80] = 0x0102030405060708   the DMEM dword at byte address 0x80

RESULTS =                      the expected state after the run
r5 = 0x7                       a register (with an optional mask after the value)
t1.pc = 0x9                    a thread's PC (pc), or its ERROR register (error)
m[0x80] = 0x2a                 a DMEM dword; in a C test also m[symbol+offset]
```

Other keys: `MISPREDICTS`, `BTB_PREDICTIONS` (timing model),
`HAZARDS_UNLOCKED` (below), `ASM_ERROR` (the source must not assemble:
the error message must contain this text), `DEVIATION` (the test depends
on one of the model's deviations, so `--reference` does not replay it),
`MAX_CYCLES`, `APCC_FLAGS` (`-O0` for a C test).

To add a test, write the two files in a suite's folder and run the
suite: the runner finds every `.vprj`.

## Hazards

The engine resolves read-after-write dependences in hardware: a bundle
waits in REGFILE until every register it reads has been written back.
The functional model runs each thread's bundles in order, so its results
are right regardless; the timing model checks the interlock two ways,
on every run:

- **the lock masks**: the registers each bundle actually reads and
  writes must be within the masks DECODE gave REGFILE (otherwise the
  model prints an internal error and counts a lock-mask violation, and
  the runner fails the test: the interlock would miss a dependence);
- **a hazard count**, kept apart from the locks: a bundle issued while a
  register it reads still has an older write outstanding. It must be 0.

Built with `engine.regfile.interlock = false` (in
`model/system_models/apara/sitar_model/src/Top.sitar`), REGFILE ignores
its locks, and each test in `hazards/` must report exactly its
`HAZARDS_UNLOCKED` hazards: the reads real hardware would get wrong
without the interlock. (Set it back to `true` and rebuild afterwards.)

The hazards the hardware does not resolve are in a single bundle (two
instructions writing one register), and the assembler rejects those
(`asm_errors/`).
