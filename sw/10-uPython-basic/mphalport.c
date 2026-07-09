#include <unistd.h>
#include "py/mpconfig.h"
#include "soc_uart.h"
#include "systimer.h"
#include "lib/oofatfs/ff.h"

// Receive single character, blocking until one is available.
int mp_hal_stdin_rx_chr(void) {
    unsigned char c = 0;
    //int r = read(STDIN_FILENO, &c, 1);
    //(void)r;
    while (!uart_tstc()) {
        // wait for character to arrive
    }
    c=uart_getc();
    return c;
}

// Send the string of given length.
void mp_hal_stdout_tx_strn(const char *str, mp_uint_t len) {
    //int r = write(STDOUT_FILENO, str, len);
    //(void)r;
    while (len--) {
        uart_putc(*str++);
    }
}

uint64_t mp_hal_time_ns(void) {
    uint64_t start_time = get_time();
    uint64_t elapsed_time = get_time()-start_time;
    return (elapsed_time*40);
}

DWORD get_fattime(void) {
    // TODO: Implement this function. For now, fake it.
    return ((2025 - 1980) << 25) | ((1) << 21) | ((26) << 16) | ((00) << 11) | ((18) << 5) | (23 / 2);
}