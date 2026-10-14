# compiler/apara/

Our tools for the APARA engine's assembly language, mcode (Python 3,
standard library only). For every program the APARA reference assembler
accepts, they write the same object file, word for word.

- **`mcode.py`** -- the library: lexer, parser, checks, bundle closing,
  placement and lane arrangement, labels, encoding, decoding, disassembly.
- **`apara_as.py`** -- the assembler: `apara_as.py prog.mcode [-o prog.obj]
  [--aligned file] [--listing file]`.
- **`apara_dis.py`** -- the disassembler: `apara_dis.py prog.obj [-o file]`.
- **`test_mcode.py`** -- the library's unit tests.
- **`vim/mcode.vim`** -- vim syntax highlighting.

See the documentation's "APARA Assembly Language and Tools" page.
