# docs/source/examples/array_sum/

A frozen copy of `validation/C/array_sum/`'s source, built once with this
repository's own vendored toolchain and committed here alongside its
`.hex`/`.objdump`/`.expected`. Used by
[`docs/source/examining_core_state_with_gdb.md`](../../examining_core_state_with_gdb.md)'s
walkthrough -- kept separate from the validation copy so the specific
addresses that page cites stay correct regardless of which cross-compiler
version a reader has installed. Not part of the validation suite itself;
don't add this directory to `validation/run_tests.py`.
