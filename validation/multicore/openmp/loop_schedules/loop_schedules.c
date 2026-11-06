// loop_schedules.c
//
// Every schedule runs every iteration exactly once, whatever the loop's bounds and step.
// Each schedule is checked on these loops: 0 to N by 1, 0 to N by 3, N down to 0 by 2,
// fewer iterations than threads, one iteration, and none.
//   0. schedule(static)      1. schedule(static, 3)
//   2. schedule(dynamic)     3. schedule(dynamic, 5)
//   4. schedule(guided)      5. schedule(guided, 2)
//   6. schedule(runtime), set to each kind with omp_set_schedule()
//   7. `parallel for` as one construct, with each kind and several team sizes
//   8. a static loop gives each thread iterations in the order OpenMP says it must
//   9. reduction(+) over a dynamic loop
//  10. a loop with no iterations runs none, for each kind and direction
//  11. the first chunk of a guided loop is a share of the whole loop
//  12. collapse(2) with each kind of schedule
#include "../openmp_common.h"

#define PRAGMA(x) _Pragma(#x)

#define N 64
static volatile int count[N + 1];

static void clear_count(void)
{
	int i;
	for (i = 0; i <= N; i++)
		count[i] = 0;
}

// 1 if the iterations from..to by step ran once each, and no others ran.
static int ran_once(int from, int to, int step)
{
	int i, right = 1;
	for (i = 0; i <= N; i++)
	{
		int expected = 0;
		if (step > 0 && i >= from && i < to && (i - from) % step == 0) expected = 1;
		if (step < 0 && i <= from && i > to && (from - i) % -step == 0) expected = 1;
		if (count[i] != expected) right = 0;
	}
	return right;
}

#define BUMP(i) do { int j_; \
	_Pragma("omp critical") { j_ = count[i]; count[i] = j_ + 1; } } while (0)

#define CHECK_SCHEDULE(sched, result) do { int i_; result = 1; \
	clear_count(); \
	PRAGMA(omp parallel for sched) \
	for (i_ = 0; i_ < N; i_++) BUMP(i_); \
	if (!ran_once(0, N, 1)) result = 0; \
	clear_count(); \
	_Pragma("omp parallel") { \
		PRAGMA(omp for sched) \
		for (i_ = 0; i_ < N; i_ += 3) BUMP(i_); } \
	if (!ran_once(0, N, 3)) result = 0; \
	clear_count(); \
	_Pragma("omp parallel") { \
		PRAGMA(omp for sched) \
		for (i_ = N; i_ > 0; i_ -= 2) BUMP(i_); } \
	if (!ran_once(N, 0, -2)) result = 0; \
	clear_count(); \
	_Pragma("omp parallel") { \
		PRAGMA(omp for sched) \
		for (i_ = 10; i_ < 13; i_++) BUMP(i_); } \
	if (!ran_once(10, 13, 1)) result = 0; \
	clear_count(); \
	_Pragma("omp parallel") { \
		PRAGMA(omp for sched) \
		for (i_ = 7; i_ < 8; i_++) BUMP(i_); } \
	if (!ran_once(7, 8, 1)) result = 0; \
	clear_count(); \
	_Pragma("omp parallel") { \
		PRAGMA(omp for sched) \
		for (i_ = 8; i_ < 8; i_++) BUMP(i_); } \
	if (!ran_once(8, 8, 1)) result = 0; \
} while (0)

int main(void)
{
	unsigned ok = 0;
	int r, i;

	CHECK_SCHEDULE(schedule(static), r);     if (r) ok |= 1 << 0;
	CHECK_SCHEDULE(schedule(static, 3), r);  if (r) ok |= 1 << 1;
	CHECK_SCHEDULE(schedule(dynamic), r);    if (r) ok |= 1 << 2;
	CHECK_SCHEDULE(schedule(dynamic, 5), r); if (r) ok |= 1 << 3;
	CHECK_SCHEDULE(schedule(guided), r);     if (r) ok |= 1 << 4;
	CHECK_SCHEDULE(schedule(guided, 2), r);  if (r) ok |= 1 << 5;

	{
		int right = 1;
		omp_sched_t kind;
		int modifier;
		omp_set_schedule(omp_sched_static, 4);
		omp_get_schedule(&kind, &modifier);
		if (kind != omp_sched_static || modifier != 4) right = 0;
		CHECK_SCHEDULE(schedule(runtime), r);   if (!r) right = 0;
		omp_set_schedule(omp_sched_static, 0);
		CHECK_SCHEDULE(schedule(runtime), r);   if (!r) right = 0;
		omp_set_schedule(omp_sched_dynamic, 3);
		CHECK_SCHEDULE(schedule(runtime), r);   if (!r) right = 0;
		omp_set_schedule(omp_sched_guided, 2);
		CHECK_SCHEDULE(schedule(runtime), r);   if (!r) right = 0;
		if (right) ok |= 1 << 6;
	}

	{
		// A combined construct with every kind that goes through the runtime.
		int right = 1;
		clear_count();
#pragma omp parallel for schedule(dynamic, 2)
		for (i = 0; i < N; i++) BUMP(i);
		if (!ran_once(0, N, 1)) right = 0;
		clear_count();
#pragma omp parallel for schedule(guided)
		for (i = 0; i < N; i++) BUMP(i);
		if (!ran_once(0, N, 1)) right = 0;
		omp_set_schedule(omp_sched_static, 2);
		clear_count();
#pragma omp parallel for schedule(runtime)
		for (i = 0; i < N; i++) BUMP(i);
		if (!ran_once(0, N, 1)) right = 0;
		clear_count();
#pragma omp parallel for schedule(dynamic) num_threads(2)
		for (i = 0; i < N; i++) BUMP(i);
		if (!ran_once(0, N, 1)) right = 0;
		clear_count();
#pragma omp parallel for schedule(guided, 3) num_threads(3)
		for (i = 0; i < N; i++) BUMP(i);
		if (!ran_once(0, N, 1)) right = 0;
		clear_count();
#pragma omp parallel for schedule(dynamic) num_threads(1)
		for (i = 0; i < N; i++) BUMP(i);
		if (!ran_once(0, N, 1)) right = 0;
		if (right) ok |= 1 << 7;
	}

	{
		// With no chunk size, the iterations are divided into blocks of about equal size, in
		// thread order. OpenMP leaves their exact sizes open, and gcc 4.4 and 11 differ, so
		// this checks the order and the largest size. A chunk of 2 deals them out in turn,
		// which OpenMP does fix.
		static volatile int owner[10];
		int right = 1;
#pragma omp parallel for schedule(static)
		for (i = 0; i < 10; i++) owner[i] = omp_get_thread_num();
		{
			int block = 0, previous = 0;
			if (owner[0] != 0) right = 0;
			for (i = 0; i < 10; i++)
			{
				if (owner[i] == previous)
					block++;
				else
				{
					if (owner[i] != previous + 1) right = 0;
					previous = owner[i];
					block = 1;
				}
				if (block > 3) right = 0;
			}
		}
#pragma omp parallel for schedule(static, 2)
		for (i = 0; i < 10; i++) owner[i] = omp_get_thread_num();
		for (i = 0; i < 10; i++) if (owner[i] != (i / 2) % TEAM) right = 0;
		if (right) ok |= 1 << 8;
	}

	{
		int sum = 0;
#pragma omp parallel for schedule(dynamic, 3) reduction(+:sum)
		for (i = 1; i <= 100; i++) sum += i;
		if (sum == 5050) ok |= 1 << 9;
	}

	{
		// Loops with no iterations, whichever way their bounds are the wrong way round.
		volatile int low = 5, high = 2, ran = 0;
#pragma omp parallel private(i)
		{
#pragma omp for schedule(static)
			for (i = low; i < high; i++) ran = 1;
#pragma omp for schedule(static, 2)
			for (i = low; i < high; i++) ran = 1;
#pragma omp for schedule(dynamic)
			for (i = low; i < high; i++) ran = 1;
#pragma omp for schedule(guided)
			for (i = low; i < high; i++) ran = 1;
#pragma omp for schedule(static, 2)
			for (i = high; i > low; i--) ran = 1;
#pragma omp for schedule(dynamic)
			for (i = high; i > low; i--) ran = 1;
#pragma omp for schedule(dynamic)
			for (i = low; i < low; i++) ran = 1;
		}
		if (!ran) ok |= 1 << 10;
	}

	{
		// Guided gives out a share of what is left, so the first chunk of 40 iterations over
		// four threads is ten. Iteration 0 lingers, so that the others have time to ask.
		static volatile int owner[40];
		int right = 1;
#pragma omp parallel for schedule(guided)
		for (i = 0; i < 40; i++)
		{
			if (i == 0)
			{
				volatile int d;
				for (d = 0; d < 500; d++)
					;
			}
			owner[i] = omp_get_thread_num();
		}
		for (i = 1; i < 10; i++) if (owner[i] != owner[0]) right = 0;
		if (right) ok |= 1 << 11;
	}

	{
		// collapse(2) makes one loop of two, for each kind of schedule.
		static volatile int cell[6][5];
		int j, k, right = 1;
#pragma omp parallel for collapse(2) schedule(static) private(j)
		for (i = 0; i < 6; i++)
			for (j = 0; j < 5; j++) cell[i][j] = 1;
#pragma omp parallel for collapse(2) schedule(dynamic, 2) private(j)
		for (i = 0; i < 6; i++)
			for (j = 0; j < 5; j++) cell[i][j] = cell[i][j] + 1;
#pragma omp parallel for collapse(2) schedule(guided) private(j)
		for (i = 0; i < 6; i++)
			for (j = 0; j < 5; j++) cell[i][j] = cell[i][j] + 1;
		for (i = 0; i < 6; i++)
			for (k = 0; k < 5; k++) if (cell[i][k] != 3) right = 0;
		if (right) ok |= 1 << 12;
	}

	report(ok, 13);
	return 0;
}
