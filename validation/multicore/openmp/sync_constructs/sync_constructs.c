// sync_constructs.c
//
// The constructs that order threads. Each counter below is read and written in separate
// steps, so a broken lock loses updates.
//   0. critical protects a counter
//   1. two differently named critical sections protect their own counters
//   2. two differently named critical sections do not exclude each other
//   3. atomic protects a counter, with each operator
//   4. reduction with +, *, &, |, ^, && and ||
//   5. master runs only on thread 0
//   6. a barrier holds every thread until all have arrived
//   7. flush lets one thread see another's write, in the classic flag handshake
#include "../openmp_common.h"

#define ROUNDS 50

static volatile int critical_counter, name_a, name_b;

static void slow_increment(volatile int* p)
{
	int v = *p, d;
	for (d = 0; d < 3; d++)
		v = v + 0;
	*p = v + 1;
}

int main(void)
{
	unsigned ok = 0;

#pragma omp parallel
	{
		int i;
		for (i = 0; i < ROUNDS; i++)
		{
#pragma omp critical
			slow_increment(&critical_counter);
		}
	}
	if (critical_counter == ROUNDS * TEAM) ok |= 1 << 0;

#pragma omp parallel
	{
		int i;
		for (i = 0; i < ROUNDS; i++)
		{
#pragma omp critical (a)
			slow_increment(&name_a);
#pragma omp critical (b)
			slow_increment(&name_b);
		}
	}
	if (name_a == ROUNDS * TEAM && name_b == ROUNDS * TEAM) ok |= 1 << 1;

	{
		// Thread 0 holds section (a) until thread 1 has been through section (b). Were the
		// two the same lock, this would never end.
		volatile int passed = 0;
#pragma omp parallel num_threads(2)
		{
			if (omp_get_thread_num() == 0)
			{
#pragma omp critical (a)
				while (!passed)
				{
#pragma omp flush
				}
			}
			else
			{
#pragma omp critical (b)
				passed = 1;
#pragma omp flush
			}
		}
		if (passed) ok |= 1 << 2;
	}

	{
		int add = 0, sub = 1000, mul = 1, ior = 0, xor_word = 0, and_word = 0xff, div_word = 1 << 20;
#pragma omp parallel
		{
			int i, me = omp_get_thread_num();
			for (i = 0; i < ROUNDS; i++)
			{
#pragma omp atomic
				add += 2;
#pragma omp atomic
				sub -= 1;
#pragma omp atomic
				xor_word ^= 1;
			}
#pragma omp atomic
			mul *= 2;
#pragma omp atomic
			ior |= 1 << me;
#pragma omp atomic
			and_word &= ~(1 << me);
#pragma omp atomic
			div_word /= 2;
		}
		if (add == 2 * ROUNDS * TEAM && sub == 1000 - ROUNDS * TEAM && mul == 16 && ior == 0xf
		    && xor_word == 0 && and_word == 0xf0 && div_word == 1 << 16)
			ok |= 1 << 3;
	}

	{
		int plus = 1, times = 1, band = 0xff, bor = 0, bxor = 0, land = 1, lor = 0;
#pragma omp parallel reduction(+:plus) reduction(*:times) reduction(&:band) reduction(|:bor) reduction(^:bxor) reduction(&&:land) reduction(||:lor)
		{
			int me = omp_get_thread_num();
			plus += me + 1;
			times *= 2;
			band &= ~(1 << me);
			bor |= 1 << me;
			bxor ^= 3;
			land = land && (me < TEAM);
			lor = lor || (me == 2);
		}
		if (plus == 11 && times == 16 && band == 0xf0 && bor == 0xf && bxor == 0 && land == 1 && lor == 1)
			ok |= 1 << 4;
	}

	{
		volatile int ran = 0, who = -1;
#pragma omp parallel
		{
#pragma omp master
			{
				ran++;
				who = omp_get_thread_num();
			}
		}
		if (ran == 1 && who == 0) ok |= 1 << 5;
	}

	{
		// Each round, a thread adds itself in and waits. After the barrier, all must have.
		volatile int arrived = 0;
		int right = 1;
#pragma omp parallel
		{
			int round;
			for (round = 1; round <= 10; round++)
			{
#pragma omp atomic
				arrived += 1;
#pragma omp barrier
				if (arrived < round * TEAM) right = 0;
#pragma omp barrier
			}
		}
		if (right && arrived == 10 * TEAM) ok |= 1 << 6;
	}

	{
		volatile int data = 0, flag = 0;
		int got = 0;
#pragma omp parallel num_threads(2)
		{
			if (omp_get_thread_num() == 0)
			{
				data = 42;
#pragma omp flush
				flag = 1;
#pragma omp flush
			}
			else
			{
				while (!flag)
				{
#pragma omp flush
				}
				got = data;
			}
		}
		if (got == 42) ok |= 1 << 7;
	}

	report(ok, 8);
	return 0;
}
