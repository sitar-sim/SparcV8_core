// apara_common.h
//
// Shared by every test in validation/C/apara/ (the APARA engine, from the
// SPARC side, on the sparc_apara configuration). The engine routines come
// from compiler/include/apara_access_routines.h. Each test reports as the
// device tests do (Ref ../devices/devices_common.h): %o0 = 1 if every
// check passed, %o1 = a bit per check.

#ifndef APARA_COMMON_H
#define APARA_COMMON_H

#include "../devices/devices_common.h"
#include "apara_access_routines.h"

// A main-memory word read straight from memory (not from the data
// cache), for data the engine has written there.
static inline uint32_t physical_word(const volatile uint32_t* p)
{
	return __ajit_load_word_mmu_bypass__((uint32_t) p);
}

#endif
