// threads_1.c
//
// The dot product on 1 engine thread (Ref ../threads_common.h for
// what is checked).

#include "../threads_common.h"

int main(void)
{
	run_threads(1);
	return 0;
}
