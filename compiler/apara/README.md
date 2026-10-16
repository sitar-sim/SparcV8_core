# compiler/apara/

Our tools for the APARA engine (Python 3, standard library only): an
assembler and disassembler for its assembly language, mcode, and a small
C compiler.

- **`mcode.py`** -- the library: lexer, parser, checks, bundle closing,
  placement and lane arrangement, labels, encoding, decoding, disassembly.
- **`apara_as.py`** -- the assembler: `apara_as.py prog.mcode [-o prog.obj]
  [--aligned file] [--listing file]`.
- **`apara_dis.py`** -- the disassembler: `apara_dis.py prog.obj [-o file]`.
- **`apcc.py`** -- a small C compiler for the engine: `apcc.py prog.c
  [-o prog.mcode] [--data prog.data] [--symbols prog.sym] [-O0]
  [--dmem-base addr]`. A C subset (integer and float scalars, global
  arrays in DMEM, loops, functions without recursion, `__entry` thread
  entry points), intrinsics for the vector instructions
  (`include/apara.h`), and inline mcode (`__asm__`). It writes mcode for
  `apara_as.py`, and the DMEM contents and addresses of the globals.
  With `-O1` (the default) it packs independent instructions into
  bundles.
- **`apara_obj_to_c.py`** -- an engine program as a C header, for a SPARC
  program that loads it into the engine (`sparc_apara`):
  `apara_obj_to_c.py kernel.mcode [-o kernel.mcode.h] [--name kernel]`,
  or `kernel.c` (compiled with `apcc.py` for DMEM's window address, and
  the header then also gives each global's DMEM offset and initial data).
  `validation/build_hex.py` runs it for each `MCODE = <file>` line of a
  test's `.vprj`.
- **`test_mcode.py`**, **`test_apcc.py`** -- the tools' unit tests.
- **`vim/mcode.vim`** -- vim syntax highlighting.

See [APARA Assembly Language and
Tools](https://sitar-sim.github.io/SparcV8_core/apara/assembly_and_tools.html).
