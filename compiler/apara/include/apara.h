// apara.h
// Original author: Madhav Desai, IITB
// Model Author: Claude Opus 5.5 (high)
// This model code was adapted from the APARA engine specification and
// reference C implementation developed by Prof. Madhav Desai, IITB
//
// The language extensions of apcc.py, the APARA engine's C compiler, and
// plain-C versions of them, so a program written for the engine also
// compiles with an ordinary C compiler (to check it on the host first).
// apcc.py itself knows the intrinsics, and ignores #include lines.
//
//   __entry          marks a thread's entry function: its parameters
//                    arrive in $r1, $r2, ..., and returning from it halts
//                    the thread (without any __entry, main is the entry)
//   __at(addr)       places a global at a fixed DMEM byte address:
//                    int8_t A[64] __at(0x100);
//
// The intrinsics work on 64-bit values holding packed vectors (as the
// engine's registers do); T names the element type as a string: "vi8",
// "vu16", "vf32", ... (vi/vu/vf, 4 to 32 bits).
//
//   __ld64(addr), __st64(addr, v)     a 64-bit load / store at a DMEM byte
//                                     address (&array[i]): 8 int8 elements
//                                     at once, for example
//   __dot(T, a, b)                    $dot: the sum of the element products
//   __dot_acc(T, acc, a, b)           acc + __dot(T, a, b) ($dot $accumulate)
//   __vadd/__vsub/__vmul(T, a, b)     element-wise $v + - *
//   __vadd_rep/... (T, a, s)          the same with s's lowest element for
//                                     every element of b ($replicate)
//   __vreduce(OP, T, a)               $vreduce: OP is "+", "*", "|", "&", "^"
//   __fsqrt(x)                        $fsqrt, x a float or a double
//   __slice(x, high, low)             bits [high:low] of x
//   __halt()                          $halt
//   __asm__("mcode")                  inline mcode; %name stands for a
//                                     variable's register
//
// On the host (below), integer elements are handled; __ld64/__st64 use
// the host's byte order, which keeps element-wise results and dot
// products the same as on the engine, but not their positions within a
// 64-bit value (so __slice of a loaded vector differs).

#ifndef APARA_H
#define APARA_H

#ifndef __APCC__

#include <stdint.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

#define __entry
#define __at(addr)

static inline int __apara_bits(const char* t) { return atoi(t + 2); }
static inline int __apara_signed(const char* t) { return t[1] == 'i'; }

static inline int64_t __apara_element(const char* t, int64_t v, int i)
{
	int w = __apara_bits(t);
	uint64_t e = ((uint64_t) v >> (w * i)) & ((w == 64) ? ~0ULL : ((1ULL << w) - 1));
	if (__apara_signed(t) && (e >> (w - 1)) & 1)
		e |= ~0ULL << w;
	return (int64_t) e;
}

static inline int64_t __apara_elementwise(const char* t, int64_t a, int64_t b, int op, int replicate)
{
	int w = __apara_bits(t), i;
	uint64_t out = 0, mask = (1ULL << w) - 1;
	for (i = 0; i < 64 / w; i++)
	{
		int64_t x = __apara_element(t, a, i), y = __apara_element(t, b, replicate ? 0 : i);
		int64_t r = op == 0 ? x + y : op == 1 ? x - y : x * y;
		out |= ((uint64_t) r & mask) << (w * i);
	}
	return (int64_t) out;
}

static inline int64_t __apara_ld64(const void* p) { int64_t v; memcpy(&v, p, 8); return v; }
static inline void __apara_st64(void* p, int64_t v) { memcpy(p, &v, 8); }
#define __ld64(addr)    __apara_ld64((const void*) (intptr_t) (addr))   // &A[i] or an integer address
#define __st64(addr, v) __apara_st64((void*) (intptr_t) (addr), (v))
static inline int64_t __dot(const char* t, int64_t a, int64_t b)
{
	int64_t s = 0;
	int i;
	for (i = 0; i < 64 / __apara_bits(t); i++)
		s += __apara_element(t, a, i) * __apara_element(t, b, i);
	return s;
}
static inline int64_t __dot_acc(const char* t, int64_t acc, int64_t a, int64_t b) { return acc + __dot(t, a, b); }
static inline int64_t __vadd(const char* t, int64_t a, int64_t b) { return __apara_elementwise(t, a, b, 0, 0); }
static inline int64_t __vsub(const char* t, int64_t a, int64_t b) { return __apara_elementwise(t, a, b, 1, 0); }
static inline int64_t __vmul(const char* t, int64_t a, int64_t b) { return __apara_elementwise(t, a, b, 2, 0); }
static inline int64_t __vadd_rep(const char* t, int64_t a, int64_t s) { return __apara_elementwise(t, a, s, 0, 1); }
static inline int64_t __vsub_rep(const char* t, int64_t a, int64_t s) { return __apara_elementwise(t, a, s, 1, 1); }
static inline int64_t __vmul_rep(const char* t, int64_t a, int64_t s) { return __apara_elementwise(t, a, s, 2, 1); }
static inline int64_t __vreduce(const char* op, const char* t, int64_t a)
{
	int i, n = 64 / __apara_bits(t);
	int64_t r = op[0] == '*' ? 1 : op[0] == '&' ? -1 : 0;
	for (i = 0; i < n; i++)
	{
		int64_t e = __apara_element(t, a, i);
		r = op[0] == '+' ? r + e : op[0] == '*' ? r * e : op[0] == '|' ? (r | e) : op[0] == '&' ? (r & e) : (r ^ e);
	}
	return r;
}
static inline double __fsqrt(double x) { return sqrt(x); }
static inline int64_t __slice(int64_t x, int high, int low)
{
	return (int64_t) (((uint64_t) x >> low) & ((high - low == 63) ? ~0ULL : ((1ULL << (high - low + 1)) - 1)));
}
static inline void __halt(void) {}

#endif
#endif
