#include "systimer.h"

static inline void mp_hal_delay_us(mp_uint_t us) {
    delay_us(us);
}

static inline void mp_hal_delay_ms(mp_uint_t ms) {
    delay_us(ms * 1000);
}

static inline mp_uint_t mp_hal_ticks_us(void) {
    return get_time();
}

static inline mp_uint_t mp_hal_ticks_ms(void) {
    return get_time() / 1000;
}

static inline mp_uint_t mp_hal_ticks_cpu(void) {
   return get_time();
}

static inline void mp_hal_set_interrupt_char(char c) {
}
