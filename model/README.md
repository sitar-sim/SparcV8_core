# model/

- `cpp_common_code/` -- `SparcCore`: the SPARC V8 core as a pure state +
  `execute_*()` library, with no notion of cycles/timing of its own.
  Shared by both drivers below.
- `cpp_model/` -- `SparcStateMachine`, a plain C++ fetch-decode-execute
  driver for `SparcCore` (0-delay, functional-only, no Sitar dependency).
  `build.sh` builds `sparc_cpp_sim` and `check_test`.
- `sitar_model/` -- the Sitar-driven model (`Top`/`Core`/`SparcThread`/
  `MemoryInterface`/`MainMemory`), which actually assigns timing to
  `SparcCore`'s execution. `build.py` builds `sitar_check_test` into
  `executable/`.

A proper architecture write-up is still on the TODO list; this is just a
map of what lives where for now.
