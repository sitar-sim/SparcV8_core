// openmp_common.h
//
// Shared by the OpenMP tests. Each one reports like the rest of validation/multicore:
// %o0 = 1 if every check passed, and %o1 = a bit per check, on core 0. The same source also
// builds with the host's gcc -fopenmp, where it prints those two values instead, so that
// check_on_host.py can compare the bare-metal runtime with a real one.
//
// A test must use only what both have, or keep the rest under __sparc__.

#ifndef OPENMP_COMMON_H
#define OPENMP_COMMON_H

#include <omp.h>

#define TEAM 4

#ifndef __sparc__
#include <stdio.h>
#include <stdlib.h>
#endif

static void report(unsigned checks_passed_bits, unsigned number_of_checks)
{
	unsigned all  = (number_of_checks >= 32) ? 0xffffffffu : ((1u << number_of_checks) - 1);
	unsigned pass = (checks_passed_bits == all) ? 1 : 0;
#ifdef __sparc__
	omp_end_program(pass, checks_passed_bits);
#else
	printf("o0=0x%08x\no1=0x%08x\n", pass, checks_passed_bits);
	exit(0);
#endif
}

#endif
