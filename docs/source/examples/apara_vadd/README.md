# docs/source/examples/apara_vadd/

The example program of the walkthrough "Writing a new program" in
[Programming the System](../../apara/system_programming.md). The SPARC
program `my_vadd.c` offloads a vector addition of 32 `int16` elements
to the APARA engine, whose program is `vadd.mcode`, and checks the
engine's result. `my_vadd.vprj` turns it into a test for
`validation/run_tests.py --config sparc_apara`.

Only the sources are kept here. The walkthrough copies them into a
working folder of its own, and builds them there. This folder is not
part of the validation suite.
