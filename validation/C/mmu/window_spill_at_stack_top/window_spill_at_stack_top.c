// window_spill_at_stack_top.c
//
// Calls nested deeper than the register windows spill windows to the stack, and the first
// one spilled is the startup code's own, with its %sp at the very top of the stack. A
// spill writes 64 bytes at %sp and upward, so crt0_interrupts.s must leave room above its
// first stack pointer. Otherwise the spill writes past the end of memory, to VA 0x10000000
// here, which is unmapped. The core then stops with a trap inside a trap.
//
// The default crt0.s has no window trap handlers, so only this startup file can spill. With
// the MMU off the same write goes unnoticed, so this test turns the MMU on.
//
// %o0 = 1 if a call chain deeper than the register windows returns the right value.
#include "../mmu_common.h"
#include "ajit_mt_irc.h"

#define DEPTH 40

static unsigned int context_table[256] __attribute__((aligned(1024)));
static unsigned int l1_table[256]      __attribute__((aligned(1024)));

static unsigned int sum_down_to_zero(unsigned int n)
{
	if (n == 0)
		return 0;
	return n + sum_down_to_zero(n - 1);
}

int main(void)
{
	unsigned int pass;

	setup_safe_l1_table(l1_table, 0);
	enable_mmu_with_l1_table(context_table, l1_table);

	pass = (sum_down_to_zero(DEPTH) == DEPTH * (DEPTH + 1) / 2) ? 1 : 0;

	__asm__ __volatile__("mov %0, %%o0" : : "r"(pass));
	__asm__ __volatile__("ta 0");
	while (1) {}
	return 0;
}
