#include "soc_uart.h"


//extern volatile soc_uart_dev_t *UART0_DEV =(soc_uart_dev_t *)UART_BASE;


void uart_init(uint32_t baudrate) {
    UART0_DEV->uart_reg3.RW_uart_LCR|=0x80;
    UART0_DEV->uart_reg3.RW_uart_LCR|=0x03;
    UART0_DEV->uart_reg3.RW_uart_LCR|=0x04;

    uint64_t uart_divisor=(UART_CLK/baudrate);
    UART0_DEV->uart_reg0.RW_uart_DLL=uart_divisor & 0xFF;
    UART0_DEV->uart_reg1.RW_uart_DLH=(uart_divisor>>8) & 0xFF;

    UART0_DEV->uart_reg2.W_uart_FCR = 0x07;

    UART0_DEV->uart_reg3.RW_uart_LCR&=0x7F;
}


void uart_putc(char c) {
    while((UART0_DEV->uart_reg5.R_uart_LSR&TF)==0);
    UART0_DEV->uart_reg0.W_uart_THR=c;
}


char uart_getc(void) {
    return((char)(UART0_DEV->uart_reg0.R_uart_RBR & 0xFF));
}


int uart_tstc(void) {
    return((UART0_DEV->uart_reg5.R_uart_LSR&DR)!=0);
}

void uart_puts(const char *s) {
    while (*s) {
        if (*s == '\n') {
            uart_putc('\r'); // Carriage return before newline
        }
        uart_putc(*s++);
    }
}
