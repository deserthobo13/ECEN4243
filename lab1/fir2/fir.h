#ifndef FIR_H
#define FIR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
    #endif

    void fir(const int32_t *x, const int32_t *c, int32_t *y, uint32_t n, uint32_t m);

    #ifdef __cplusplus
}
#endif

#endif //FIR_H