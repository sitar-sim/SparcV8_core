// Insertion sort of 16 int32 values, in place.
//
// Compiled with compiler/apara/apcc.py. The program and its data are
// in the engine's IMEM and DMEM before the run; the expected results
// (the .vprj) were computed independently, in Python.

int32_t v[16] = {396, 244, -813, 915, 265, 362, 724, 529, 709, 299, 54, -928, 292, -244, -104, 81};

void main(void)
{
    for (int64_t i = 1; i < 16; i++) {
        int32_t key = v[i];
        int64_t j = i - 1;
        while (j >= 0 && v[j] > key) {
            v[j + 1] = v[j];
            j--;
        }
        v[j + 1] = key;
    }
}
