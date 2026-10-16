# APARA: findings in the specification (validation, October 2026)

For the model's authors and the engine's designers. These came out of
the APARA validation suites (`validation/apara/`, `validation/sparc_apara/`):
places where the engine's documents are contradictory, ambiguous or
wrong, and properties of the specified design worth a decision. They are
not bugs of this model: where the documents leave a choice, the model's
choice is stated, and the model follows it consistently. The defects
found in the reference model are the deviations on the documentation's
APARA Deviations and Findings page (31 and 32 are new from this round).

Sources: the ISA document (`engine_isp/isa/isa.txt`), the
microarchitecture document (*APARA Engine: Microarchitecture and Timing*,
`engine_isp/docs/microarch`), and the reference model (McodeMachine,
`mcode_run`), in the APARA repository.

---

## 1. The ISA document

| # | Where | Finding | The model, and the reference |
|---|---|---|---|
| S1 | SET | "The two bytes of the constant are loaded into dest-byte-index and dest-byte-index+1 in rd" and the example "rd[31:16] := 256" read as an insert, keeping the other bytes. | The reference model and ours replace the whole register (the other bytes become 0). A 64-bit constant then takes four $set into four registers and three ORs; with an insert, four $set into one register. **Decide which the hardware does.** |
| S2 | PACK | "At most 2 rd registers can be used, at most 2 rs registers", legal combinations 64/64, 64/32, 32/32, 32/16. | The encoding (log2 fields) allows more, and the reference and ours pack up to 4 sources and 4 destinations (`$pack 64 $r8 16 $r2` reads $r2..$r5). **Decide the limit**, then the assembler can enforce it. |
| S3 | DOT | "DOT is supported only for source types with up to 16 bit fp and 16-bit integer", "the hardware will implement only vi4, vi8, vi16, vf4, vf8, vf16"; but also "defined for source element types which have up to 32 bits". The result: "dest-type of rd is i32 or f32", and elsewhere "maintained as a 64-bit unsigned integer". | Reference programs use `$dot` on 32-bit elements. The model accepts element widths up to 32 bits and gives a 64-bit (two's complement) integer result. **Decide the element widths and the result width.** |
| S4 | Instruction list | CMOV is described as "extract slice from source and insert into destination", SLICE's text. | Documentation error; CMOV's own section is right. |
| S5 | LOAD/STORE | The examples use `$i128`/`$i256`; the type table defines only `$u128`/`$u256`. | The model (and the reference assembler) accept `$u128`/`$u256`. |
| S6 | STORE | For `$u128`: "will fetch two 64-bit values starting from byte address rs1 + rs2, and keep it in rd, rd+1": the load's text. | Documentation error: a store writes rd, rd+1 to memory. |
| S7 | DOT syntax | Three spellings: `$dot ($i32) r7 ($v $i4) r5 r6` (isa.txt), `$dot ($i32) $r16 ($i8) $r4 $r5` (the reference's own test programs, with a scalar element type), `$dot $rd ($vi8) $rs1 $rs2` (this project's documentation). | The assembler accepts the reference programs' form; a scalar type names the element type. **Pick one spelling for the documentation.** |
| S8 | VALU types | "types can be up to 32-bits wide only" lists 4-bit elements implicitly ($vi4 is a vector type), but the reference model computes 0 for every element-wise operation on 4-bit elements (deviation 31), while its $dot ($vi4) works. | The model implements them; confirm 4-bit element-wise operations exist in the hardware. |
| S9 | Signed narrow operands | "r1 and r2 are i8" (for `($i8)`): operands are their type's width. The reference sign-extends negative narrow values but keeps the bits above the width of non-negative ones (deviation 32): `($i8)` 0x105 + 0 = 0x105. | The model reads only the type's width (5). |

## 2. The microarchitecture document

| # | Where | Finding | Consequence |
|---|---|---|---|
| M1 | Branch predictor: updates | The BTB is updated only by PC corrections (mispredicts). A correctly predicted taken branch never lowers its counter. | A loop-closing branch's counter rises by one at each loop exit and is never pulled back by the taken passes, so after three exits it predicts "not taken": from then on every instance of an inner loop mispredicts twice (entry and exit) instead of once. Measured: an inner loop of 4 passes run 5 times, 8 mispredicts instead of 6 (`predictor/nested_loops`). **Consider training on every resolved branch**, or counting only the exits. |
| M2 | Branch predictor: returns | Returns are predicted by the BTB alone: one target per `$return` instruction, the last one seen. | A function called from changing call sites mispredicts every return (`predictor/call_sites`: 3 calls from 3 sites, 6 mispredicts). A return-address stack predictor (the RAS is already in each thread's state) would predict them. |
| M3 | Branch predictor: sharing | The BTB is shared by the four threads, direct mapped by the low 8 PC bits (the document's own open question). | Branches 256 words apart evict each other: two loops in alternation mispredict at every entry and exit (`predictor/alias`: 14 instead of 10). Threads running the same code share (and help) each other's entries. |
| M4 | Mispredict recovery | A mispredict drops only what FETCH holds; the wrong-path bundles already in DECODE and REGFILE go through REGFILE and EXEC (skipped), each holding a REGFILE token. | The mispredict penalty depends on the tokens: with one token, `timing/t9_mispredict` takes 18 cycles instead of 12 (three wrong-path bundles, 2 cycles each). |
| M5 | REGFILE tokens | At most 2 bundles in EXEC (AVAILABLE_TOKENS = 2). | Bundles with memory accesses stay in EXEC 3 cycles or more, so 2 tokens cap the throughput of memory-heavy code, and more threads cannot hide it: an 8x8 matrix product on 4 threads takes 112 cycles against 122 on one, its register-lock stalls (45 cycles) replaced by token stalls (30) (`kernels/matmul_i8*`). Worth a study of 3 or 4 tokens. |
| M6 | Alignment padding | Bundles are aligned to their size; the assembler fills gaps with `$null` bundles, which are fetched and go through the whole pipeline. | A short bundle followed by an 8-slot one (any load, store, branch or divide) costs up to 3 extra bundles. Compilers should group to avoid it. |
| M7 | Atomicity | The instruction set has no atomic read-modify-write, and the four threads share DMEM. | Threads updating one DMEM word race and lose updates (`sparc_apara/interference/shared_counter`); software must give each thread its own data. If the engine's programs need to synchronize, an atomic operation (or a lock register) is needed. |
| M8 | Host access while running | The control unit lets the host write IMEM, registers and DMEM while threads run. | Writes to a running thread's registers, or to IMEM it is fetching, take effect at an undefined point. The model allows them; the documents should say whether the host must stop the threads first. |

## 3. Confirmed (no finding)

Checked against the documents and found consistent, now covered by the
suites: the bundle semantics (all reads before all writes; memory in
slot order), every instruction's semantics on every type (cross-checked
with the reference model where it has no known defect), the REGFILE
interlock (every dependence class, multi-register writes and
increments included; with the interlock removed the expected hazards
appear, `validation/apara/hazards/`), the branch predictor's documented
rules (counts derived from the rules match), the exception codes and
ERROR layout, the return-address stack depth (64), the control unit's
commands and completion protocol, and the DMA unit's gather/scatter.
