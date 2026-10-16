# validation/sparc_apara/threads/

The same engine program (dot_kernel.mcode, a dot product of int8
vectors with $dot) on 1, 2, 3 and 4 engine threads, each on its own
slice of the data, and threads started and restarted at different
times. Each SPARC program computes the expected results itself.
