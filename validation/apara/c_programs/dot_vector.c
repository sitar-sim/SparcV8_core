// A 64-element int8 dot product with the engine's $dot: each __ld64
// loads 8 elements as one 64-bit value, and __dot_acc multiplies and
// adds all 8 at once.
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

#define N 64
int8_t A[N] = {-43, -9, 13, 117, -33, 36, 118, 99, 16, -92, 26, 83, 30, 126, -102, 90, 15, 35, -3, -68, -100, 35, 17, -19, -95, 59, -65, 36, -4, 11, 35, -125, 53, 27, 73, 71, -34, -72, -112, 58, -65, -96, -52, -81, -67, 34, -127, -99, 81, 13, 50, -25, -30, 70, 106, 114, 55, 104, 29, 120, -93, -124, 118, 66};
int8_t B[N] = {54, -114, -11, -113, 71, 58, -95, 89, 28, 46, -80, -49, -79, 12, 49, -128, -49, -84, -97, 61, 2, -98, 70, -43, 30, 21, 67, 32, -20, -23, 103, -37, -61, 72, 89, -8, -1, -71, -90, 99, 15, 84, -69, 16, -27, -39, 79, 47, 102, -82, 114, 87, 108, 57, -61, 99, 12, -57, -9, -48, 23, 31, -93, 25};
int64_t result;

void main(void)
{
    int64_t sum = 0;
    for (int64_t i = 0; i < N; i += 8)
        sum = __dot_acc("vi8", sum, __ld64(&A[i]), __ld64(&B[i]));
    result = sum;
}
