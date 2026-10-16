# validation/sparc_apara/basic/

Tests of each part of an APARA engine's interface from the SPARC side,
run on a configuration that has one (`sparc_apara`). Each is a C program using
`compiler/include/apara_access_routines.h`, most with an engine program
(`kernel.mcode`, named by an `MCODE =` line of the test's `.vprj`;
`validation/build_hex.py` turns it into `kernel.mcode.h`, Ref
`compiler/apara/apara_obj_to_c.py`). Reporting is the same as
`validation/C/devices/` (`../apara_common.h`). See `../README.md`.

| Test | Checks |
|---|---|
| `imem_registers` | IMEM and thread-register round trips through the control unit, the engine's timer. |
| `run_poll` | Load a program, run it, poll its completion; its result through the DMEM window, in the right byte order. |
| `run_interrupt` | The completion interrupt (IRL 14) taken by a trap handler. |
| `exception` | An engine exception's completion word (slot, code), reset, a second run. |
| `four_threads` | Four engine threads on one program and their own data. |
| `off_island` | The engine reading and writing main memory itself. |
| `dma_interrupt` | A DMA gather load, with its interrupt. |
| `dma_dot_product` | A whole offload: two vectors in by DMA, the engine's dot product, the result out by DMA. |

Engine programs address DMEM by its window address (`APARA_DMEM_BASE`,
passed in a register): in a system, the engine's other addresses go to
the system. See the documentation's "The Engine in a System" page.
