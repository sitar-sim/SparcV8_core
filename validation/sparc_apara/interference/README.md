# validation/sparc_apara/interference/

Whether engine threads, the SPARC, and the DMA unit can disturb one
another. They share DMEM, and the APARA instruction set has no atomic
read-modify-write, so threads that update the same word race
(shared_counter shows the lost updates); everything else here must be
undisturbed: threads on their own DMEM regions, the SPARC and the DMA
unit working on DMEM while threads run, and a thread's exception.
