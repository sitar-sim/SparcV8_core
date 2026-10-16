// threads_4.c
//
// The dot product on 4 engine threads (Ref ../threads_common.h for
// what is checked).

#include "../threads_common.h"

int main(void)
{
	run_threads(4);
	return 0;
}
