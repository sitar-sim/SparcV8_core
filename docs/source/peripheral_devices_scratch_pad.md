# Scratch-pad

A small block of 32 words of read/write storage in the device window,
shared by every core. It has no signal pins and no interrupt, and
communicates with the cores over the shared address/data bus only. See
[Peripheral Devices](peripheral_devices.md) for the connection diagram
and the full address map.

## Address range and layout

The scratch-pad occupies `0xFFFF2C00` to `0xFFFF2FFF`. Only address
bits `[6:2]` select a word, so the 32 words repeat every 128 bytes
across that 1 KB range. Word 0 is at `0xFFFF2C00` and also at
`0xFFFF2C80`, `0xFFFF2D00`, and so on. All words read 0 after reset.

Word, byte, halfword and doubleword loads and stores all work. A byte
or halfword store changes only the bytes it selects, and a doubleword
store writes two consecutive words, the first at the lower address.
Reads have no side effects.

## Why a scratch-pad

Like every device, the scratch-pad is never cached. A value written
to it by one core is therefore seen by every other core on its next
load, even before any core has set up its MMU or caches. This makes it
a natural place for flags that cores exchange during startup, such as
"page tables are ready" or "initialization is done". AJIT's CORTOS
runtime uses its first two words for exactly these two flags.

## Example

```sparc
set 0xFFFF2C00, %g1
set 1, %g2
sta %g2, [%g1] 0x20     ! word 0 = 1, through the MMU bypass ASI
lda [%g1] 0x20, %g3     ! %g3 = 1
```
