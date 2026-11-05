// diff_pa_same_va.c
//
// Different physical pages at the same virtual address in two contexts: not synonyms,
// and the opposite of the other tests here. The two lines must stay apart, with no
// false hit, and a write in one context must not reach the other.
//
//   0. each context reads its own page
//   1. a store in one context changes only its own page
//   2. back in the first context, the first page still has its value

#include "../alias_common.h"

int main(void)
{
	alias_t a = { (volatile uint32_t*) VA(0), 0 };
	alias_t b = { (volatile uint32_t*) VA(0), 1 };
	uint32_t ok = 0;

	frame[0] = 0x11;
	other_frame[0] = 0x22;
	build_tables();
	map_page(0, VA(0), frame, 1);
	map_page(1, VA(0), other_frame, 1);
	enable_mmu();

	if (read_alias(a) == 0x11 && read_alias(b) == 0x22) ok |= 1 << 0;

	*b.word = 0x33;  //still in context 1
	if (read_alias(b) == 0x33 && read_alias(a) == 0x11) ok |= 1 << 1;

	if (read_alias(a) == 0x11 && frame[0] == 0x11 && other_frame[0] == 0x33) ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}
