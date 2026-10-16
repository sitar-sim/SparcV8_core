# validation/sparc_apara/setup/

How a SPARC program brings up the engine, one thread at a time: the
engine's state at power-up, loading and reading back its memories, and
complete offloads (load the program and the data, start a thread, learn
that it stopped by polling or by interrupt, collect the results), with
engine programs written in mcode or compiled from C (apcc.py).
