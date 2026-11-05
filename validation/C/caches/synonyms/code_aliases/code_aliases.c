// code_aliases.c
//
// One physical page of code at two virtual addresses. The instruction cache also holds
// at most one copy. The program changes the code through a data alias, with no flush,
// and calls it through the other code alias each time. That alias's copy was removed
// when the first one was fetched, so it misses and runs the new code. If both copies
// stayed cached, the call would run the old code.
//
//   0. both aliases run the first version
//   1. after a change, the first alias runs the new code
//   2. after another change, the second alias runs the new code

#include "../alias_common.h"

#define RETL      0x81C3E008u
#define MOV_TO_O0 0x90102000u

typedef uint32_t (*function_t)(void);

int main(void)
{
	function_t first = (function_t) VA(0), second = (function_t) VA(1);
	volatile uint32_t* code = (volatile uint32_t*) frame;  //identity mapped, as data
	uint32_t ok = 0;

	code[0] = RETL;
	code[1] = MOV_TO_O0 | 1;
	build_tables();
	map_page(0, VA(0), frame, 1);
	map_page(0, VA(1), frame, 1);
	enable_mmu();

	if (first() == 1 && second() == 1) ok |= 1 << 0;  //the second call removes the first copy

	code[1] = MOV_TO_O0 | 2;
	if (first() == 2) ok |= 1 << 1;                   //which removes the second copy

	code[1] = MOV_TO_O0 | 3;
	if (second() == 3) ok |= 1 << 2;

	report_and_halt(ok, 3);
	return 0;
}
