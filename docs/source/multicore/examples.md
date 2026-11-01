# Example Programs

Two complete programs show the patterns of [Programming the Multicore
System](programming.md) at work. Both are bare-metal C programs, with
no operating system and no runtime library beyond the startup file.
Both are also tests in the validation suite, in
`validation/multicore/examples/`, so they are known to run on both
models, under every cpp scheduling strategy, with the caches in use or
not.

---

## Parallel array sum

[`parallel_sum.c`](https://github.com/sitar-sim/SparcV8_core/blob/main/validation/multicore/examples/parallel_sum/parallel_sum.c)
sums an array of 4096 words on four cores. The array is split into four
slices of 1024 words, and core `i` fills and sums slice `i`. Each core
then publishes its partial sum, and core 0 adds the four partial sums
together.

```c
#define N         4096
#define SLICE     (N / NUM_CORES)

int data[N];
volatile uint32_t partial_sum[NUM_CORES];
volatile uint32_t done[NUM_CORES];

int main(void)
{
	uint32_t id = this_core_id();
	int first = id * SLICE;
	uint32_t sum = 0;
	...
	for (i = first; i < first + SLICE; i++)
		data[i] = value_at(i);
	for (i = first; i < first + SLICE; i++)
		sum += data[i];

	partial_sum[id] = sum;
	done[id] = 1;

	if (id == 0)
	{
		uint32_t total = 0;
		for (k = 0; k < NUM_CORES; k++)
		{
			while (read_shared(&done[k]) == 0)
				;
			total += read_shared(&partial_sum[k]);
		}
		*(volatile uint32_t*) TOTAL_ADDR = total;
		...
	}
	report_and_halt(ok, 1);
}
```

The program shows three points.

- **Work divided by core ID.** Every core runs the same code, and its
  ID alone picks its slice.
- **One writer for every shared word.** `partial_sum[k]` and `done[k]`
  are written by core `k` only, so no lock is needed.
- **A join.** Core 0 waits for each core's `done` flag before reading
  its partial sum. A core's stores reach memory in program order, so
  once `done[k]` reads 1, `partial_sum[k]` holds core `k`'s sum.
  `read_shared()` reads both words with uncached loads, so core 0 never
  reads an old copy from its own cache.

The `.vprj` checks every core's result and the total that core 0 stores
at `0x00100000`.

```
RESULTS =
o0=0x00000001
o1=0x00000001
core1.o0=0x00000001
...
m[0x100000]=0x037ff800
```

---

## Parallel matrix multiply

[`parallel_matmul.c`](https://github.com/sitar-sim/SparcV8_core/blob/main/validation/multicore/examples/parallel_matmul/parallel_matmul.c)
computes `C = A x B` for 16 x 16 integer matrices. Here the cores share
real data. Core 0 produces both input matrices, every core reads them,
and core 0 reads every core's part of the result.

```c
int A[N][N], B[N][N], C[N][N];
volatile uint32_t inputs_ready;
volatile uint32_t done[NUM_CORES];

	//1. Core 0 produces the inputs, the others wait for them.
	if (id == 0)
	{
		... fill A and B ...
		inputs_ready = 1;
	}
	else
	{
		wait_for(&inputs_ready);
		flush_caches();
	}

	//2. Every core computes its own block of rows.
	for (i = id * ROWS_PER_CORE; i < (id + 1) * ROWS_PER_CORE; i++)
		for (j = 0; j < N; j++)
		{
			int sum = 0;
			for (k = 0; k < N; k++)
				sum += A[i][k] * B[k][j];
			C[i][j] = sum;
		}
	done[id] = 1;

	//3. Core 0 gathers and checks the result.
	if (id == 0)
	{
		for (k = 0; k < NUM_CORES; k++)
			wait_for(&done[k]);
		flush_caches();
		... check every element of C, store a checksum ...
	}
```

Two flags order the three steps. `inputs_ready` tells the other cores
that A and B are complete, and `done[k]` tells core 0 that core `k`'s
rows of C are complete.

The flags alone are not enough when the caches are in use, because a
core reads A, B and C with ordinary loads, which can hit its own cache.
The program flushes its caches each time it starts to read data another
core has produced.

- **Core 0's flush, before it reads C, is needed.** Core 0 cleared
  `.bss` at startup, C included, so its cache can hold zeros for every
  row of C. Without the flush, core 0 reads those zeros instead of the
  other cores' rows. With caching on, the program then fails on both
  models.
- **The other cores' flush, before they read A and B, is a safeguard.**
  Their caches have never held A or B in this program, so they cannot
  hold an old copy. A core that had read A before core 0 filled it in
  would need the flush.

Once the caches are coherent (a later stage), the flushes will no longer
be needed, and the program will still be correct.

---

## Building and running the examples

Both examples build and run like any other test in the suite.

```sh
source compiler/toolchain_env.sh
validation/build_hex.py validation/multicore/examples
validation/run_tests.py validation/multicore/examples --config multicore
validation/run_tests.py validation/multicore/examples --config multicore --sitar
```

A single program can also be run directly, with its expected results.

```sh
cd model/system_models/multicore/sitar_model
SPARC_ALWAYS_CACHEABLE=1 ./executable/sparc_sim_sitar_multicore \
    ../../../../validation/multicore/examples/parallel_matmul/parallel_matmul.hex \
    ../../../../validation/multicore/examples/parallel_matmul/parallel_matmul.expected 5000000
```

On the sitar_model the caches make a large difference, because without
them every instruction fetch of every core crosses the shared bus.

| Program | Cycles, nothing cached | Cycles, `SPARC_ALWAYS_CACHEABLE=1` |
|---|---|---|
| `parallel_sum` | about 3,086,000 | about 467,000 |
| `parallel_matmul` | about 2,470,000 | about 447,000 |

`--stats` prints, among the other counters, the number of bus
transactions each core made. For `parallel_matmul` with caching on,
cores 1 to 3 make about 8,400 each, and core 0, which also produces the
inputs and checks the result, about 34,000.
