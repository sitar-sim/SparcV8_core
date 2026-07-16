# SparcV8_core
Sitar model of a SparcV8 core

## Acknowledgments

Most of the functional validation suite under `validation/instruction_tests/`
(and the toolchain scripts that build/run it under `compiler/`) is adapted
from the **AJIT processor project** (IIT Bombay) -- specifically its `ajit32`
instruction-level verification suite. See `validation/README.md` for
details, per-file author credit, and the quad-precision tests that are this
project's own (AJIT's own suite assumes quad ops are unimplemented; this
project implements them). `compliance/README.md` documents three specific,
well-understood divergences between AJIT's expected test results and this
model's (accrued-inexact FSR tracking, PSR impl/ver field writability, and
quad-precision support), intended to be shared with AJIT's authors.
