// Z = X + Y on 32 int16 elements, 4 at a time with __vadd("vi16")
// (each 16-bit sum wraps).
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

int16_t X[32] = {11189, -15503, 11857, -12577, 4706, 23819, 281, -24667, 3160, 15285, -20092, 14980, -31639, -31291, -20098, 32148, 16324, -29463, 11918, 32266, -26008, -29705, -2012, 9828, -22458, -12184, 11898, -11254, -23120, 29945, 14578, -21882};
int16_t Y[32] = {10315, -25118, -30036, 4519, -22467, -32716, -9640, -309, 2544, 23906, 15009, 2370, -22578, 20689, 31458, 18344, 12523, 19088, -877, 18621, -10793, -16587, 32425, -6090, 5808, -8590, 31682, 9769, -10684, -32354, 17756, 32058};
int16_t Z[32];

void main(void)
{
    for (int64_t i = 0; i < 32; i += 4)
        __st64(&Z[i], __vadd("vi16", __ld64(&X[i]), __ld64(&Y[i])));
}
