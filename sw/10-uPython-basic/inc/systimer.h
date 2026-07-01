#ifndef __SYSTIMER_H__
#define __SYSTIMER_H__
#include <stdint.h>
#include "SERVE.h"


#define MTIME_TICK_PERIOD (CPU_CLK_FREQ / US_PER_SECOND)

typedef struct
{
    volatile uint32_t mtimel;
    volatile uint32_t mtimeh;
    volatile uint32_t mtimecmpl;
    volatile uint32_t mtimecmph;
}systimer_dev_t;

//extern volatile systimer_dev_t *SYSTMR_DEV;


#define SYSTMR_DEV ((volatile systimer_dev_t *)MTIME_BASE_ADDRESS)



void mtime_updated(unsigned int time_from_now);
void update_mtimecmp(uint64_t next_mtime);
uint64_t update_mtime_period(unsigned int time_from_now);


uint64_t get_time(void);
void delay_us(uint32_t us);

#endif /*__SYSTIMER_H__*/