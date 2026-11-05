// ldstub_neighbour_bytes.c
//
// The four bytes of one word belong to one core each. Every core repeatedly
// does LDSTUB on its own byte, which must return 0 because only this core
// touches it, and then clears the byte with a byte store. At the end each
// core leaves its own number in its byte.
//
// This checks that an atomic instruction changes only the byte it names. The
// bus carries a whole doubleword with a byte mask, so a model that wrote
// back more than the masked byte would overwrite a neighbour, and that
// neighbour's next LDSTUB would not return 0.
//
// Every core checks:
//   0. its LDSTUB always returned 0, and always left 0xFF
//   1. every core finished, and the word holds all four numbers
#include "../../multicore_common.h"
#include "multicore_sync.h"

#define ROUNDS 100

#define BYTES ((volatile uint8_t*)  SHARED_BASE)
#define WORD  ((volatile uint32_t*) SHARED_BASE)
#define DONE  ((volatile uint32_t*) (SHARED_BASE + 0x10))

int main(void)
{
	uint32_t ok = 1 << 0, id = this_core_id(), i;
	for (i = 0; i < ROUNDS; i++)
	{
		if (atomic_ldstub(&BYTES[id]) != 0)
			ok &= ~(1u << 0);
		if (read_shared_byte(&BYTES[id]) != 0xFF)
			ok &= ~(1u << 0);
		BYTES[id] = 0;
	}
	BYTES[id] = (uint8_t) (id + 1);
	if (finish_and_wait_for_all(DONE) && read_shared(WORD) == 0x01020304u) ok |= 1 << 1;
	report_and_halt(ok, 2);
	return 0;
}
