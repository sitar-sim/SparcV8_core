# TODO / Progress log

This file tracks overall project status and next steps. Update it as
milestones are reached rather than treating it as a historical log --
keep the "Current status" section accurate to the present state of the
repo, and move completed "Next steps" items into it.

## Current status (as of 2026-07-19)

**Milestone 1 -- standalone C++ core model: essentially done.**

- `model/cpp_common_code/`: `SparcCore` is a pure state + `execute_*()`
  library, with no structure/timing/sequencing of its own (that's the
  drivers' job). Closely follows the SPARC V8 manual, with section
  citations in comments.
- `model/cpp_model/`: `SparcStateMachine` drives `SparcCore` through a
  fetch-decode-execute-trap FSM loop (Ref Appendix C.5) against a plain
  `MemCore` array, for functional testing with no Sitar dependency at
  all. `build.sh` builds `sparc_cpp_sim` and `check_test`.
- 7 confirmed `SparcCore`/decoder bugs fixed (Div flags, Mul SMUL
  truncation, SWAP byte-mask, SDIV overflow clamp value, `FqTOd`
  result-flag bug, ASR off-by-one UB fix in `Registers.h`), plus two more
  found via the full validation pass -- a driver bug where an
  `execute_*` function (e.g. `execute_RETT`) setting `core.state = ERROR`
  directly, bypassing the normal trap-dispatch path, was never noticed by
  the halt-detection logic (`RETT4`/`RETT5`/`RETT6` hung instead of
  halting); and a `Decoder.cpp` op3 table bug that had
  `TADDcc`(`0x20`)/`TSUBcc`(`0x21`) swapped, so each executed as the other.
- Full IEEE-754 FP exception detection implemented for single/double
  (via host `<cfenv>`) and quad precision (via explicit bit-pattern
  checks in `FloatingPointFunctions.h` -- `fetestexcept` is unreliable
  for `__float128`, see the file-level comment there for why).
  Quad-precision arithmetic itself is fully supported (this project
  implements it "from scratch"/via libquadmath; AJIT's own suite assumes
  it's unimplemented -- see `README.md` Acknowledgments).
- `validation/`: self-built test harness (`run_tests.py` + `check_test.cpp`,
  folder-scoped, ajit-style `.vprj` REG/MEM expected-results format) plus
  223 instruction tests (adapted from AJIT's `ajit32` suite, plus new
  quad-precision tests written for this project). **Full suite run against
  the cpp model: 223/223 passing.**
- Test pipeline split into two phases so the suite can be run with no
  cross-compiler installed: `validation/build_hex.py` (phase 1, needs the
  sparc-elf toolchain, assembles `.s` -> `.hex`) and `validation/run_tests.py`
  (phase 2, only needs a checker binary built, runs the already-assembled
  `.hex` files -- see below for the `--sitar` flag). `.hex` files are
  committed to git for this reason; `.o`/`.elf`/`.expected` are not
  (`validation/clean.sh` removes them).
- `docs/compliance/` documents three independent, well-understood AJIT
  divergences (not bugs on either side, each with side-by-side
  original-vs-our_model `.vprj` evidence for AJIT's authors): (1) 10 tests,
  accrued-inexact FSR tracking; (2) 2 `RDPSR`/`WRPSR` tests, PSR
  `impl`/`ver` fields hardwired here vs. writable in AJIT (the corrected
  values were also folded back into `validation/`'s own copies of these
  two tests, now passing); (3) 14 of AJIT's own `unimplemented/`
  quad-precision tests, which this model actually executes for real
  instead of trapping (two incidental AJIT-corpus bugs also noted along
  the way: `fitoq.s`/`.vprj` never really tests `FITOQ`, and `fsubq.vprj`'s
  `SOURCES` points at `fmulq.s`).
- Repo-wide `.gitignore` pass done (top-level `.gitignore` created;
  `model/.gitignore` catches every extensionless build product across
  both `cpp_model/` and `sitar_model/`; `validation/.gitignore` tracks
  `.hex` deliberately, ignores `.o`/`.elf`/`.expected`).
- Filed in the separate `sitar` repo's `TODO.md`: `sitar compile --cflags`
  doesn't propagate to the link step (`LIBS`/`LINKFLAGS`), only to
  `CCFLAGS` -- worked around throughout this repo (both
  `model/sitar_model/build.py` and the earlier `--cflags` bug report) by
  manually re-invoking the final `g++` link command with `-lquadmath`
  appended. Not fixed yet (needs a `sitar` CLI change + doc update,
  deferred).

**Milestone 2 -- Sitar model: architecture redesigned, implemented, and
now fully validated (223/223) end to end.**

`model/` was reorganized:
```
model/
  cpp_common_code/   (was cpp_code/ -- shared by both drivers below)
  cpp_model/          (was cpp_standalone_model/; Runner renamed SparcStateMachine,
                        sparc_standalone_sim renamed sparc_cpp_sim)
  sitar_model/
    src/
      sitar_code/     Top.sitar, Core.sitar, SparcThread.sitar,
                       MemoryInterface.sitar, MainMemory.sitar
      cpp_code/        MemAccessInterface.h, OpcodeLatencies.h
      sitar_check_test.cpp
    executable/        (built, gitignored)
    build.py            (translate + compile + the -lquadmath re-link workaround)
```

Design changes made:
- **`MainMemory.sitar`** (new): the actual memory storage (`MemCore`)
  moved out of `Core.sitar` into a dedicated, *persistent* procedure --
  entered once via `run` as a branch of a parallel block alongside
  `SparcThread` (`Core.sitar`: `[ run sparcThread; ... || run mainMemory; ]`),
  not called per-access. Talks to its one requester through a single
  shared `MemAccessInterface` object (`model/sitar_model/src/cpp_code/MemAccessInterface.h`)
  via a request/response valid-bit handshake (see that file's header
  comment for the exact 4-step protocol). Because both sides are
  procedures running as branches of one parallel block -- not modules
  connected by nets -- the handshake can complete within a single phase,
  i.e. with 0 added cycles, the same mechanism the sitar repo's
  `pipelined_processor` example uses for inter-stage handoff.
- **`MemoryInterface.sitar`** (renamed from `MemoryInterfaceThread.sitar`,
  substantially slimmed down): lost `mem_core`/`DIRECT_INTERFACE_TO_MEM`
  and all byte-mask/word-assembly logic entirely (moved into
  `MainMemory.sitar`). Now just issues a request over the shared
  `MemAccessInterface` object and waits for the response. Gained a
  `delay` parameter (cycles, default 0) modeling access latency on the
  requester side, independent of whatever `MainMemory` (or later a
  cache) does on the other end. Still a "function-style" procedure --
  each `run` performs exactly one access and returns; the instance
  itself isn't destroyed and is reused for the next access.
- **`OpcodeLatencies.h`** (new, in `sitar_model/src/cpp_code/`, *not*
  `cpp_common_code/` -- the C++ core stays timing-agnostic by design):
  `DEFAULT_PER_OPCODE_DELAY` (1 cycle) plus a compile-time
  `OPCODE_LATENCY_OVERRIDES` map for exceptions, currently empty.
  `SparcThread`'s EXECUTE loop is simply `do { fetch-decode-execute;
  wait(opcode_delay, 0); } while(...)` -- opcode_delay is an ordinary
  `int >= 0`, no special-casing. For a memory instruction, the effective
  total latency is the sum of this opcode delay, `MemoryInterface.delay`,
  and `MainMemory.delay` (see below).
- **`MainMemory.sitar` also has its own `delay` parameter** (cycles,
  default 0), distinct from `MemoryInterface.delay`: it models the
  memory's own service time (between accepting a request and publishing
  the response), applied uniformly to every requester, whereas
  `MemoryInterface.delay` is per-channel (e.g. only `memReadThread`) and
  charged on the requester's side after the response is already
  available. The two are independent and additive.
- **All three latency knobs verified working (and independent of each
  other) via a logging-enabled build** (`build.py --logging`, plus
  `sitar_check_test.cpp` now sets up hierarchical log streaming, and
  every relevant log line gained a `[t=...]` timestamp): overriding
  `ADD`'s opcode latency to 4 cycles produced a clean 4-cycle gap between
  fetches for `ADD` only, every other opcode staying at the 1-cycle
  default; setting `MainMemory.delay` and `memReadThread.delay`
  simultaneously showed both apply additively and correctly (mem delay
  between "servicing" and "response ready" for every access type
  uniformly; interface delay between "response ready" and "Finished",
  only on the channel it's set on). With `DEFAULT_PER_OPCODE_DELAY=0`
  (and both other knobs at their 0 default), every instruction in the
  full 223-test suite executed at the exact same simulated timestamp --
  genuinely 0 elapsed cycles, running like a plain C model -- and the
  suite still passed 223/223. All temporary overrides used for this
  verification were reverted afterward; defaults are unchanged (opcode
  latency 1, both interface latencies 0).
- All 5 of `SparcThread`'s memory-interface threads (ifetch/read/write/
  atomic/flush) currently share the *one* `MainMemory` instance and the
  *one* `MemAccessInterface` object -- safe today because SparcThread's
  FSM never has more than one memory access in flight. Splitting to
  separate I/D caches later (see Next steps) means pointing individual
  `MemoryInterface`s at separate `MainMemory`-like procedures, not
  teaching one `MainMemory` to arbitrate multiple ports.
- Confirmed (not changed) that `SparcThread`/`MemoryInterface`/
  `MainMemory` are deliberately Sitar *procedures*, not modules
  connected by ports/nets, specifically to keep 0-delay same-cycle
  communication possible -- see the file-level comments in
  `SparcThread.sitar` and `MainMemory.sitar`.
- **Bug found and fixed along the way**: `SparcThread.sitar`'s trap
  dispatch only called `core.executeTraps()` (i.e. actually entered the
  trap table) for `reset_trap`/`window_overflow`/`window_underflow`;
  every other trap type -- including the ordinary software `ta 0` that
  literally every test in the suite ends with -- fell straight into
  `core.state = ERROR`, skipping the trap handler entirely. Confirmed
  pre-existing (present before this session's changes, via a bisection
  build against the original file). `model/cpp_model/SparcStateMachine.cpp`
  already had this right (Ref Section C.5: "if (trap = 1) then
  execute_trap" -- unconditional, no special-casing by trap type);
  `SparcThread.sitar` now matches it.
- `model/sitar_model/src/sitar_check_test.cpp` (new) + `validation/run_tests.py --sitar`
  (new flag): a Sitar-driven counterpart to `check_test.cpp` with the
  identical CLI/expected-file/output format, so the exact same 223-test
  suite runs against either model unchanged. **Full suite run against the
  Sitar-driven model: 223/223 passing** (confirmed via a from-scratch
  clean rebuild of both models, not just incrementally).
- Every `.sitar` file now has a consistent header (procedure/module name,
  `Author: Neha Karanjkar`, and a description) and was reviewed for
  comments/formatting.

## Next steps

1. **Opcode-wise test-coverage analysis.** Full validation passes
   (223/223) are done for both models -- still open: systematically
   compare the SPARC V8 instruction set against `validation/asm/`
   to find opcodes with no test at all (not just currently-failing ones).

2. **Documentation.** Write it up properly (architecture, how the C++
   core / Sitar model / standalone driver relate, how to build and run
   tests, how to add a new test). To be reviewed and iterated on
   together over a few passes rather than written once and left.

3. **Repo hygiene pass.** Systematically go through the repo and add:
   an install script, a top-level `README.md` rewrite (currently a
   two-line stub), `AUTHORS` (crediting the AJIT project sources
   explicitly, alongside this project's own authors), `LICENCE.md`.

4. **Remaining two testbench configurations for the full Sitar model**
   (configuration 1, tightly coupled via `MainMemory` with 0-delay
   handshake, is now the current/default -- see Milestone 2 above):
   1. **Loosely coupled via ports**: a variant wrapping `MemCore` behind
      real module ports/nets instead of the parallel-block handshake,
      adding >=1 cycle of communication latency each way (as opposed to
      `MemoryInterface.delay`, which approximates latency without an
      actual port connection).
   2. **Core with split I/D caches**: core + separate instruction and
      data caches, each a `MainMemory`-like persistent procedure,
      connected via `MemoryInterface` the same way `MainMemory` is
      today, which in turn talk to an external memory over ports/nets.
      A model along these lines already exists in an older/v1 version of
      Sitar -- reuse/adapt the cache models from there rather than
      writing new ones from scratch.

5. File the `SparcThread.sitar` trap-dispatch bug fix (see Milestone 2)
   nowhere else -- it's a bug in *this* repo's code, not AJIT's, so no
   `docs/compliance/` entry is needed; noted here for the record only.
