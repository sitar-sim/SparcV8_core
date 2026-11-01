# performance_evaluation/

Models and programs for measuring the simulator itself, rather than
the SPARC systems it simulates. They are built from the configurations
in `model/system_models/` but are not configurations themselves, and
the validation suites do not run them.

- **`parallel_speedup/`** runs 16 independent copies of the `multicore`
  system in one simulation, enough work per simulated cycle for a
  parallel Sitar run to be faster than a serial one. See its README and
  the [Parallel Simulation](https://sitar-sim.github.io/SparcV8_core/multicore/parallel_simulation.html)
  page.
