// diff_va_same_set.c
//
// Same physical page. Different virtual addresses in the same set of a direct-mapped cache, in one
// context, so a new line replaces the other anyway.
// See check_one_direction() in alias_common.h for the twelve checks.

#include "../alias_common.h"

int main(void)
{
	alias_t a = { (volatile uint32_t*) VA(0), 0 };
	alias_t b = { (volatile uint32_t*) VA(8), 0 };

	build_tables();
	map_page(0, VA(0), frame, 1);
	map_page(0, VA(8), frame, 1);
	enable_mmu();

	report_and_halt(check_alias_pair(a, b), 12);
	return 0;
}
