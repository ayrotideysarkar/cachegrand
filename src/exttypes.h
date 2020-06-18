#ifndef CACHEGRAND_MISC_ATOMIC_H
#define CACHEGRAND_MISC_ATOMIC_H

#ifdef __cplusplus
extern "C" {
#endif

#define _Volatile(T)    volatile T

typedef _Volatile(uint8_t)  uint8_volatile_t;

#ifdef __cplusplus
}
#endif

#endif //CACHEGRAND_MISC_ATOMIC_H
