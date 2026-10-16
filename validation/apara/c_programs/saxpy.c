// y = a*x + y on 8 floats (exact values), then the sum of y.
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

float x[8] = {1.5f, -2.0f, 0.25f, 4.0f, 3.0f, -0.5f, 8.0f, 0.125f};
float y[8] = {10.0f, 20.0f, -30.0f, 0.5f, 1.0f, 2.0f, -4.0f, 6.0f};
float total;

void main(void)
{
    float a = 2.5f;
    float s = 0.0f;
    for (int64_t i = 0; i < 8; i++) {
        y[i] = a * x[i] + y[i];
        s += y[i];
    }
    total = s;
}
