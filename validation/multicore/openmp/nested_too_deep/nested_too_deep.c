// nested_too_deep.c
//
// The runtime keeps a fixed amount of state for each nested region, for OMP_MAX_SERIAL_DEPTH
// of them. Going deeper ends the run with an error code in %o0, rather than overwriting
// memory, and the workers still halt.
#include <omp.h>

static int descend(int depth)
{
	int result = depth;
#pragma omp parallel num_threads(1)
	{
		if (depth < OMP_MAX_SERIAL_DEPTH)
			result = descend(depth + 1);
	}
	return result;
}

int main(void)
{
	descend(0);
	return 1;
}
