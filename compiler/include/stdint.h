/* stdint.h
 *
 * Fixed-width integer types for bare-metal programs built with this
 * repository's bundled sparc-elf-gcc (4.4.3), which predates GCC
 * shipping its own freestanding <stdint.h>. Only the exact-width types
 * and their limits are defined, for 32-bit SPARC V8 (int and long are
 * 32 bits, long long is 64). Found ahead of any system header because
 * compiler/compile_c.sh puts compiler/include/ on the include path.
 */

#ifndef BAREMETAL_STDINT_H
#define BAREMETAL_STDINT_H

typedef signed char        int8_t;
typedef unsigned char      uint8_t;
typedef short              int16_t;
typedef unsigned short     uint16_t;
typedef int                int32_t;
typedef unsigned int       uint32_t;
typedef long long          int64_t;
typedef unsigned long long uint64_t;

typedef int                intptr_t;
typedef unsigned int       uintptr_t;

#define INT8_MAX   127
#define UINT8_MAX  255
#define INT16_MAX  32767
#define UINT16_MAX 65535
#define INT32_MAX  2147483647
#define UINT32_MAX 4294967295U

#endif
