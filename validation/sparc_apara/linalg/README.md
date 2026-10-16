# validation/sparc_apara/linalg/

Linear algebra offloaded to the engine by a SPARC program: the inputs go
in by DMA, the engine computes, the results come back by DMA (or are read
through the window), and the SPARC checks them against its own
computation. Engine programs in mcode (hand-scheduled VLIW) and in C
(compiled with apcc.py).
