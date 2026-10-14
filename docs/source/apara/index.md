# The APARA Engine

APARA is a compute engine designed to sit next to a SPARC (AJIT)
processor as an accelerator: a four-threaded VLIW engine with its own
instruction and data memories, built for small-integer and low-precision
float vector work (dot products, reductions, element-wise arithmetic on 4-
to 64-bit elements). The processor loads its programs, starts its threads
and moves data in and out of it. The engine was designed at IIT Bombay
(Prof. Madhav Desai); this project models it from its documents and its
reference model.

The engine's main traits, which these pages explain:

- **Bundles.** Up to 8 instructions run in parallel each step, in a
  thread's program order.
- **Four hardware threads**, each with 32 64-bit registers, sharing one
  five-stage pipeline: when one thread waits, the others keep it busy.
- **Types in every instruction.** One register is a 64-bit integer, or 8
  `$i8` elements, or 16 `$f4` floats, chosen by each instruction.
- **Local memories**: 16 KB of instructions and 64 KB of data in two banks.

## In this project

| Configuration | What it is | Status |
|---|---|---|
| `apara` | one engine on its own; programs and data placed in its memories before the run | functional and timing models, tests, tools |
| `sparc_apara` | a SPARC core (with caches, MMU and peripheral devices) and one engine | next |

The pages:

- [Instruction Set](isa.md): state, types, bundles, every instruction, encodings.
- [Assembly Language and Tools](assembly_and_tools.md): mcode, our
  assembler and disassembler, the file formats.
- [Writing and Running Programs](running.md): the simulators, the tests.
- [Timing Model](timing_model.md): the pipeline and its timing rules.
- [Deviations and Findings](deviations.md): where the model differs from
  the reference model, and the open questions.

## The code

| Where | What |
|---|---|
| `model/cpp_common_code/apara/` | the engine in plain C++: `AparaCore` (state and execution), `AparaInstruction` (decoding), `AparaOperations` (the arithmetic), `AparaTypes` (number formats), `AparaFiles` and `AparaRun` (files and simulator runs), `AparaTiming` (latency table, BTB, pipeline tokens) |
| `model/sitar_component_models/Apara*.sitar` | the pipeline: `AparaEngine` and its five stage modules |
| `model/system_models/apara/` | the configuration: `cpp_model/` (`apara_sim_cpp`) and `sitar_model/` (`apara_sim_sitar`) |
| `compiler/apara/` | the assembler, disassembler, their library `mcode.py`, vim syntax |
| `validation/apara/` | the tests and their runner |
