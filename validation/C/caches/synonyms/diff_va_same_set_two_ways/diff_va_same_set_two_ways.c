// diff_va_same_set_two_ways.c
//
// Same physical page. Different virtual addresses in the same set of a 2-way cache, in one context.
// Two ways could hold both lines at once, so only the physical address keeps them apart.
// See check_one_direction() in alias_common.h for the twelve checks.

#include "../alias_common.h"

int main(void)
{
	alias_t a = { (volatile uint32_t*) VA(0), 0 };
	alias_t b = { (volatile uint32_t*) VA(4), 0 };

	build_tables();
	map_page(0, VA(0), frame, 1);
	map_page(0, VA(4), frame, 1);
	enable_mmu();

	report_and_halt(check_alias_pair(a, b), 12);
	return 0;
}
