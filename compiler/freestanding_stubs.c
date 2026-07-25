// freestanding_stubs.c
//
// Minimal libc replacements needed only because GCC's own -O0 codegen
// sometimes emits a call to memcpy() -- e.g. to initialize a large
// aggregate (a 2D array literal, or a big enough 1D one) from a
// read-only template, instead of a sequence of individual stores. This
// is not something a test's own source ever calls directly; it's a
// -nostdlib build (see compile_c.sh), so without this, linking a test
// that happens to trigger that codegen path fails with "undefined
// reference to `memcpy'".

void *memcpy(void *dst, const void *src, unsigned int n)
{
	unsigned char *d = (unsigned char *)dst;
	const unsigned char *s = (const unsigned char *)src;
	unsigned int i;

	for (i = 0; i < n; i++)
		d[i] = s[i];

	return dst;
}
