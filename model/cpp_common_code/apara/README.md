# cpp_common_code/apara/

The APARA engine, as plain C++ classes with no notion of timing, shared
unchanged by both drivers of the `apara` and `sparc_apara`
configurations (like `SparcCore` for the SPARC core). See [The APARA
Engine](https://sitar-sim.github.io/SparcV8_core/apara/index.html) for
the engine itself.

| File | What |
|---|---|
| `AparaTypes.h` / `.cpp` | The data types (element width, signed/unsigned, float, vector) and the narrow float formats (f4, f8, f16). |
| `AparaInstruction.h` / `.cpp` | One decoded instruction, and the decoder from a 32-bit instruction word. |
| `AparaOperations.h` / `.cpp` | The value computations of every instruction, as pure functions of operand values. |
| `AparaCore.h` / `.cpp` | The engine: four threads' state, IMEM, DMEM, and the execution of a bundle. Its off-island mode chooses the standalone behavior (every address aliases into DMEM) or the system behavior (only the engine's own DMEM window is local). |
| `AparaFiles.h` / `.cpp` | The reference tools' file formats: object, data, register, and results files. |
| `AparaRun.h` / `.cpp` | What the `apara` configuration's two simulators share: the command line, loading the files, the end-of-run report and the results check. |
| `AparaControlCore.h` / `.cpp` | `sparc_apara`: the engine's control unit (CCU), its registers and command sequencing. Carrying a command out is left to the caller, so each model can do it its own way. |
| `AparaDmaCore.h` / `.cpp` | `sparc_apara`: the engine's DMA unit, its four channels and the progress of each copy. Moving the data is left to the caller, a piece at a time. |
| `AparaSystemCore.h` / `.cpp` | `sparc_apara`'s cpp_model: the engine, its control unit, and its DMA unit joined together on the system bus. |
| `AparaTiming.h` / `.cpp` | Used only by the timing model: the instruction latency table, the branch target buffer, the tokens passed between the pipeline stages, and the pipeline's statistics. |

`tests/test_apara_system.cpp` is a standalone unit test of
`AparaSystemCore`, driving the engine only through bus accesses, as a
SPARC program does (the build line is in its header comment).
