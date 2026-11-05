// same_va_diff_context.c
//
// Same physical page. The same virtual address in two contexts. Their tags differ, so without the
// physical address they would look like two different lines.
// See check_one_direction() in alias_common.h for the twelve checks.

#include "../alias_common.h"

int main(void)
{
	alias_t a = { (volatile uint32_t*) VA(0), 0 };
	alias_t b = { (volatile uint32_t*) VA(0), 1 };

	build_tables();
	map_page(0, VA(0), frame, 1);
	map_page(1, VA(0), frame, 1);
	enable_mmu();

	report_and_halt(check_alias_pair(a, b), 12);
	return 0;
}
