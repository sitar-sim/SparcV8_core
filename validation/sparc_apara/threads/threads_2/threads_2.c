// threads_2.c
//
// The dot product on 2 engine threads (Ref ../threads_common.h for
// what is checked).

#include "../threads_common.h"

int main(void)
{
	run_threads(2);
	return 0;
}
