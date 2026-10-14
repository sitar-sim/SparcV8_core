# apara/

One APARA engine on its own: no SPARC core. The program and data are
placed straight into the engine's IMEM and DMEM (and its registers set)
before the run, which ends when every started thread has stopped.

- **`cpp_model/`** -- the functional model, `apara_sim_cpp`.
- **`sitar_model/`** -- the timing model, `apara_sim_sitar`.

Both take the APARA reference simulator's (`mcode_run`'s) options and
files. See the documentation's "The APARA Engine" pages
(`docs/source/apara/`), in particular "Writing and Running Programs".
