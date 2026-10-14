# validation/C/devices/

Tests for the peripheral devices, run as SPARC programs on a
configuration that has them (`core_mmu_devices` and up). Each one uses
the AJIT-compatible routines in `compiler/include/`, and reports through
`devices_common.h`'s `report_and_halt()`: `%o0` = 1 if every check
passed, `%o1` = one bit per check, so a failure shows which one.

| Test | Checks |
|---|---|
| `core_thread_id` | `rd %asr29` reads core 0, thread 0, and ignores writes. |
| `timer_poll` | The timer fires after its count, seen through the Interrupt Controller's live source bits, and disabling it drops the interrupt. |
| `timer_interrupt` | A timer interrupt reaches a real trap handler once, through the generic dispatch, and the slot is re-enabled afterward. |
| `serial_tx` | A string sent with `__ajit_serial_puts_via_bypass__()` arrives byte for byte (`serial_out` check). |
| `serial_rx_poll` | Bytes from `serial_rx_poll.serial_in` are received by polling `Rx_full`, in order, and echoed back. |
| `serial_rx_interrupt` | Each received byte raises IRL 12 exactly once, and the handler reads them in order. |
| `irc_priority_and_mask` | A masked level is not delivered, the source bits still show it, and with two levels active the lower IRL goes first. |
| `ipi_to_self` | An IPI from this thread to itself, with its message, through `ajit_ipi.h`. |

The interrupt tests link `compiler/crt0_interrupts.s` (their `.vprj`'s
`STARTUP` line). Run them like any other suite:

```sh
validation/run_tests.py validation/C/devices --config core_mmu_devices
validation/run_tests.py validation/C/devices --config core_mmu_devices --sitar --max-cycles 5000000
```

On the sitar_model an instruction takes several cycles (every fetch
crosses four nets), hence the larger cycle limit.
