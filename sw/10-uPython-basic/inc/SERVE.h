#ifndef SERVE_H
#define SERVE_H
#include "SERVE_regs.h"
#include "soc_regs.h"
#include "riscv-csr.h"


#ifdef QEMU
    #define CPU_CLK_FREQ  10000000 /*10 MHz*/

    #define PUSH_CUSTOM_TRAP_REGS
    #define POP_CUSTOM_TRAP_REGS 

#elif SPIKE
    #define CPU_CLK_FREQ  10000000 /*10 MHz*/

    #define PUSH_CUSTOM_TRAP_REGS
    #define POP_CUSTOM_TRAP_REGS 
    
#else
    #define CPU_CLK_FREQ 25000000 /*50 MHz*/
    
    #define PUSH_CUSTOM_TRAP_REGS
    #define POP_CUSTOM_TRAP_REGS
    
#endif

#define US_PER_SECOND 1000000

void risc_v_trap_handler(void) __attribute__((interrupt));


#endif // SERVE_H