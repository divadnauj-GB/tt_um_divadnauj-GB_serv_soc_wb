#ifndef __SOC_UART__
#define __SOC_UART__

#include "SERVE.h"

#define UART_CLK	(CPU_CLK_FREQ / 16)


#define RDAvail      ( 1u<<0 )
#define THRempty     ( 1u<<1 )
#define RLSatusInt   ( 1u<<2 )
#define MStatInt     ( 1u<<3 )
#define reserved47   ( 16u<<4 )


#define IP             ( 1u<<0 )
#define Priority       ( 7u<<1 )
#define Reserved47     ( 16u<<4 )

#define en           ( 1u<<0 )
#define clear_R      ( 1u<<1 )
#define clear_T      ( 1u<<2 )
#define reserved35   ( 7u<<3 )
#define IntLevel     ( 3u<<6 )

#define N           ( 3u<<0 )
#define S           ( 1u<<2 )
#define PE          ( 1u<<3 )
#define PS          ( 1u<<4 )
#define SP          ( 1u<<5 )
#define BC          ( 1u<<6 )
#define DLA         ( 1u<<7 )


#define DTR           ( 1u<<0 )
#define RTS           ( 1u<<1 )
#define RI            ( 1u<<2 )
#define DCD           ( 1u<<3 )
#define loopback      ( 1u<<4 )
#define reserved57    ( 7u<<5 )


#define DR           ( 1u<<0 )
#define OE           ( 1u<<1 )
#define PE5          ( 1u<<2 )
#define FE           ( 1u<<3 )
#define BI           ( 1u<<4 )
#define TF           ( 1u<<5 )
#define TE           ( 1u<<6 )
#define P            ( 1u<<7 )


#define DCTS         ( 1u<<0 )
#define DDSR         ( 1u<<1 )
#define TERI         ( 1u<<2 )
#define DDCD         ( 1u<<3 )
#define CTS          ( 1u<<4 )
#define DSR          ( 1u<<5 )
#define RI6          ( 1u<<6 )
#define DCD6         ( 1u<<7 )

typedef struct
{
    union
    {
        volatile uint8_t R_uart_RBR;
        volatile uint8_t W_uart_THR;
        volatile uint8_t RW_uart_DLL;
    } uart_reg0;
    union 
    {
       volatile uint8_t RW_uart_DLH;
       volatile uint8_t RW_uart_IER;
    } uart_reg1;
    union 
    {
       volatile uint8_t R_uart_IIR;
       volatile uint8_t W_uart_FCR;
    } uart_reg2;
    union 
    {
       volatile uint8_t RW_uart_LCR;
    } uart_reg3;
    union 
    {
       volatile uint8_t W_uart_MCR;
    } uart_reg4;
    union 
    {
       volatile uint8_t R_uart_LSR;
    } uart_reg5;
    union 
    {
       volatile uint8_t R_uart_MSR;
    } uart_reg6;
}soc_uart_dev_t;

//extern volatile soc_uart_dev_t *UART0_DEV;

#define UART0_DEV ((volatile soc_uart_dev_t *)UART_BASE)

void uart_init( uint32_t baudrate);
void uart_putc( char c);
char uart_getc(void);
int uart_tstc(void);
void uart_puts(const char *s);

#endif