// uncached_alias.c
//
// Same physical page. One alias is cacheable and the other is not, so a write through the uncached one
// never fills, and must remove the cached copy itself.
// See check_one_direction() in alias_common.h for the twelve checks.

#include "../alias_common.h"

int main(void)
{
	alias_t a = { (volatile uint32_t*) VA(0), 0 };
	alias_t b = { (volatile uint32_t*) VA(1), 0 };

	build_tables();
	map_page(0, VA(0), frame, 1);
	map_page(0, VA(1), frame, 0);
	enable_mmu();

	report_and_halt(check_alias_pair(a, b), 12);
	return 0;
}
