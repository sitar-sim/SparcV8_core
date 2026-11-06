# Reference Documents

These documents are the sources this project's models follow. Copies are kept in this
repository, so that the pages here can link directly to a section of each.

| Document | Used for |
|---|---|
| [*The SPARC Architecture Manual, Version 8*](sparcv8_Architecture_reference_Manual.pdf) | The instruction set, traps and the Reference MMU. See the [guide to the manual](sparcv8_architecture.md). |
| [*The AJIT Processor*](references/ajit_processor_description.pdf), Madhav P. Desai, IIT Bombay, May 4, 2024 | The [cache coherence](references/ajit_processor_description.pdf#page=43) scheme, [multi-core processors](references/ajit_processor_description.pdf#page=47), and the [peripheral devices](references/ajit_processor_description.pdf#page=59). |
| [*APARA Engine: Microarchitecture and Timing*](references/APARA_engine_microarch_and_timing.pdf), Madhav Desai, IIT Bombay, scribe Neha Karanjkar, IIT Goa, June 10, 2026 | The APARA engine's structure and [instruction latencies](references/APARA_engine_microarch_and_timing.pdf#page=31). |

Where a model differs from one of these documents, the difference is listed on one of the
following pages.

- [Deviations from the AJIT Processor](peripheral_devices.md#deviations-from-the-ajit-processor), for the devices.
- [Assumptions](multicore/structure.md#assumptions), for the multicore system.
- [APARA: Deviations and Findings](apara/deviations.md), for the APARA engine.
