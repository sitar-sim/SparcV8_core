# validation/apara/timing/

Microbenchmarks for the APARA engine's timing model (the `apara`
configuration's sitar_model). Each `.vprj` gives the exact number of
cycles its program must take (`CYCLES`), derived by hand in the program's
header comment from the timing rules (see the documentation's APARA
Timing Model page).

```bash
python3 validation/apara/run_tests.py validation/apara/timing --sitar
```

## The counts hold for the default timing knobs only

The engine's timing knobs are Sitar fields, set in one place for each
configuration, and compiled into the model:

| Knob | Default | Set in |
|---|---|---|
| `engine.fetch.imemDelay` | 0 | `model/system_models/apara/sitar_model/src/Top.sitar` |
| `engine.exec.pipelined` | true | (the same file) |
| `engine.exec.latency.bankConflictCycles` | 1 | |
| `engine.regfile.tokens` | 2 | |
| `engine.regfile.interlock` | true | |

(`sparc_apara` sets the same knobs in its own `System.sitar`.) The
per-instruction latencies are the latency table's defaults
(`AparaTiming.h`), unless a run gives `--latency-file`.

To try other values, edit `Top.sitar` and rebuild:

```bash
model/system_models/apara/sitar_model/build.sh
```

The `CYCLES` lines (and the predictor tests' `MISPREDICTS`) then no
longer hold, and those tests fail: that is expected. **To make the tests
pass again, set the knobs in `Top.sitar` back to the defaults above and
rebuild.** The runner checks only the hazard counts when the interlock is
off (Ref `../hazards/`).

## What the knobs were checked against

Each knob was set to several values in its allowed range, one knob at a
time (the others at their defaults), the model rebuilt, and every test
here run. The counts below were predicted by hand first, from the timing
rules, then measured; they all agree.

| Setting | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 |
|---|---|---|---|---|---|---|---|---|---|---|
| defaults | 6 | 22 | 9 | 12 | 10 | 26 | 10 | 9 | 12 | 10 |
| `imemDelay = 1` | 7 | 25 | 10 | 13 | 11 | 27 | 11 | 10 | 14 | 12 |
| `imemDelay = 2` | 8 | 28 | 11 | 14 | 12 | 28 | 12 | 11 | 16 | 14 |
| `imemDelay = 5` | 11 | 37 | 14 | 17 | 15 | 31 | 17 | 17 | 22 | 20 |
| `pipelined = false` | 6 | 22 | 9 | 12 | 11 | 26 | 10 | 9 | 12 | 10 |
| `bankConflictCycles = 0` | 6 | 22 | 9 | 12 | 10 | 26 | 9 | 9 | 12 | 10 |
| `bankConflictCycles = 2` | 6 | 22 | 9 | 12 | 10 | 26 | 11 | 9 | 12 | 10 |
| `bankConflictCycles = 4` | 6 | 22 | 9 | 12 | 10 | 26 | 13 | 9 | 12 | 10 |
| `tokens = 1` | 6 | 38 | 10 | 13 | 13 | 28 | 11 | 10 | 18 | 10 |
| `tokens = 3` | 6 | 22 | 9 | 12 | 10 | 26 | 10 | 9 | 12 | 10 |
| `tokens = 4` | 6 | 22 | 9 | 12 | 10 | 26 | 10 | 9 | 12 | 10 |

How each knob shows:

- **`imemDelay = d`** adds `d` cycles each time FETCH starts a new IMEM
  line. `t2` reads three lines (`22 + 3d`); `t9` and `t10` start a second
  line after a mispredict or for the second thread (`+ 2d`). In `t7` and
  `t8` the `$halt` is on a second line (the 8-slot load bundle fills the
  first), so its delay shows once it exceeds the load's latency: at
  `d = 5` both take 17.
- **`pipelined = false`** makes EXEC hold one bundle for its whole
  latency. Only `t5` changes (11): its second bundle can no longer
  overlap the 3-cycle add. In the others, results already leave EXEC
  one at a time behind a long one.
- **`bankConflictCycles = b`** is the cost of each extra access to the
  same DMEM bank in a bundle: only `t7` has one (`9 + b`).
- **`tokens = k`** limits how many bundles are in EXEC at once. With one
  token each bundle waits for the previous one's result: `t2` streams at
  half rate (38), and `t9` pays for the three wrong-path bundles that
  follow the mispredicted branch through REGFILE and EXEC, each holding
  the only token for 2 cycles (18). More than 2 tokens changes nothing
  here: these programs never have 3 bundles ready to issue.
- **`interlock = false`** is checked by the hazard tests instead (Ref
  `../hazards/`).
