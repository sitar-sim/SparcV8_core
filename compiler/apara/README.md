# compiler/apara/

Our tools for the APARA engine's assembly language, mcode (Python 3,
standard library only). For every program the APARA reference assembler
accepts, they write the same object file, word for word.

- **`mcode.py`** -- the library: lexer, parser, checks, bundle closing,
  placement and lane arrangement, labels, encoding, decoding, disassembly.
- **`apara_as.py`** -- the assembler: `apara_as.py prog.mcode [-o prog.obj]
  [--aligned file] [--listing file]`.
- **`apara_dis.py`** -- the disassembler: `apara_dis.py prog.obj [-o file]`.
- **`apara_obj_to_c.py`** -- an engine program as a C header, for a SPARC
  program that loads it into the engine (`sparc_apara`):
  `apara_obj_to_c.py kernel.mcode [-o kernel.mcode.h] [--name kernel]`.
  `validation/build_hex.py` runs it for each `MCODE = <file>` line of a
  test's `.vprj`.
- **`test_mcode.py`** -- the library's unit tests.
- **`vim/mcode.vim`** -- vim syntax highlighting.

See [APARA Assembly Language and
Tools](https://sitar-sim.github.io/SparcV8_core/apara/assembly_and_tools.html).
