# validation/multicore/devices/

The devices, shared by every core. `../interrupts/` has the tests of the Interrupt Controller and
the Timer across cores.

| Test | Checks |
|---|---|
| `console_under_lock` | Every core prints lines at once, through `console_puts()`. They come out whole, in any order, which the `.vprj`'s `serial_lines` line checks. |
| `scratch_pad_across_cores` | A write by one core is seen by the others, also through the alias, and byte stores by different cores to one word all take effect. |
