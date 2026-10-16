// threads_3.c
//
// The dot product on 3 engine threads (Ref ../threads_common.h for
// what is checked).

#include "../threads_common.h"

int main(void)
{
	run_threads(3);
	return 0;
}
