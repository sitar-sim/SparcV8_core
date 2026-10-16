// The language features: functions with parameters and return values,
// if/else, while, do/while, for with break and continue, && || !, the
// ternary operator, comparisons as values, % and shifts, narrow and
// unsigned types, and casts.
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

int64_t out[16];

int64_t gcd(int64_t a, int64_t b)
{
    while (b != 0) {
        int64_t t = a % b;
        a = b;
        b = t;
    }
    return a;
}

int64_t clamp(int64_t v, int64_t lo, int64_t hi)
{
    return v < lo ? lo : (v > hi ? hi : v);
}

void main(void)
{
    out[0] = gcd(1071, 462);                 // 21
    out[1] = clamp(-5, 0, 10) + clamp(50, 0, 10) * 100 + clamp(7, 0, 10) * 10000;
    int64_t n = 0;
    for (int64_t i = 0; i < 100; i++) {      // odd numbers below 30, skipping multiples of 3
        if (i >= 30)
            break;
        if (i % 2 == 0 || i % 3 == 0)
            continue;
        n++;
    }
    out[2] = n;                              // 1 5 7 11 13 17 19 23 25 29: 10
    int64_t k = 0;
    do { k += 3; } while (k < 10);
    out[3] = k;                              // 12
    out[4] = (3 < 5) + (5 < 3) * 2 + (4 == 4) * 4 + (4 != 4) * 8 + !(0) * 16;   // 1 + 4 + 16
    int8_t c = 100;
    c = c + 100;                             // wraps: -56
    out[5] = c;
    uint8_t u = 200;
    u = u + 100;                             // wraps: 44
    out[6] = u;
    out[7] = (-7) >> 1;                      // arithmetic: -4
    out[8] = (int64_t) 2.75 + (int64_t) (-2.75);   // 2 + -2
    double d = 1.5;
    out[9] = (int64_t) (d * 4.0);            // 6
    int32_t w = 0x7fffffff;
    w = w + 1;                               // wraps: -2^31
    out[10] = w;
    out[11] = (5 > 3 && 2 > 1) + (5 < 3 || 2 < 1) * 2;      // 1
}
