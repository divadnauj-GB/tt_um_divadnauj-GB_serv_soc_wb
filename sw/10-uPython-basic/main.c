#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#include "py/builtin.h"
#include "py/compile.h"
#include "py/runtime.h"
#include "py/repl.h"
#include "py/gc.h"
#include "py/mperrno.h"
#include "uPython/gchelper.h"
#include "shared/runtime/pyexec.h"
#include "shared/readline/readline.h"


#include "soc_gpio.h"
#include "soc_uart.h"



#if MICROPY_ENABLE_COMPILER
void do_str(const char *src, mp_parse_input_kind_t input_kind) {
    nlr_buf_t nlr;
    if (nlr_push(&nlr) == 0) {
        mp_lexer_t *lex = mp_lexer_new_from_str_len(MP_QSTR__lt_stdin_gt_, src, strlen(src), 0);
        qstr source_name = lex->source_name;
        mp_parse_tree_t parse_tree = mp_parse(lex, input_kind);
        mp_obj_t module_fun = mp_compile(&parse_tree, source_name, true);
        mp_call_function_0(module_fun);
        nlr_pop();
    } else {
        // uncaught exception
        mp_obj_print_exception(&mp_plat_print, (mp_obj_t)nlr.ret_val);
    }
}
#endif
// Allocate memory for the MicroPython GC heap.
char msg[256] = "";

void  __attribute__((interrupt ("machine") ))  risc_v_trap_handler(void) {
    PUSH_CUSTOM_TRAP_REGS;
    unsigned int mcause = csr_read_mcause();
    unsigned int mepc = csr_read_mepc();
    // Unexpected trap, just hang here
    sprintf(msg, "Unexpected trap: mcause=0x%08x, mepc=0x%08x\n", mcause, mepc);
    uart_puts(msg);
    while (1);
    
    POP_CUSTOM_TRAP_REGS;
}

#if MICROPY_ENABLE_GC
static char heap[MICROPY_HEAP_SIZE];
#endif

extern char __stack_top;

int main(int argc, char **argv) {
    // Initialise the MicroPython runtime.
    MP_STATE_THREAD(stack_top) = (char *)(&__stack_top);

    //mp_cstack_init_with_sp_here(4096);
    gc_init(heap, heap + sizeof(heap));
    for (;;) {
        mp_init();

        for (;;) {
            if (pyexec_mode_kind == PYEXEC_MODE_RAW_REPL) {
                if (pyexec_raw_repl() != 0) {
                    break;
                }
            } else {
                if (pyexec_friendly_repl() != 0) {
                    break;
                }
            }
        }

        mp_printf(&mp_plat_print, "MPY: soft reboot\n");

        gc_sweep_all();
        mp_deinit();
    }
}

void _entry_point(void) __attribute__((naked));
void _entry_point(void) {

    // Initialise the MicroPython runtime.
    csr_write_mtvec((uint32_t )risc_v_trap_handler);
    csr_set_bits_mstatus(MSTATUS_MIE_BIT_MASK);

    gpio_init();
    uart_init(115200);

    main(0, NULL);

    while (1) {
        // Loop forever after main() exits.
    }
}



// Handle uncaught exceptions (should never be reached in a correct C implementation).
void nlr_jump_fail(void *val) {
    mp_printf(&mp_plat_print, "uncaught NLR\n");
    exit(1);
}

#if MICROPY_ENABLE_GC
void gc_collect(void) {
    gc_collect_start();
    gc_helper_collect_regs_and_stack();
    gc_collect_end();
}
#endif

#if !MICROPY_VFS
mp_lexer_t *mp_lexer_new_from_file(qstr filename) {
    mp_raise_OSError(MP_ENOENT);
}

mp_import_stat_t mp_import_stat(const char *path) {
    return MP_IMPORT_STAT_NO_EXIST;
}
#endif

void MP_NORETURN __fatal_error(const char *msg) {
    printf("Fatal error: %s\n", msg);
    __asm__ volatile("ebreak");
    while (1) {
        ;
    }
}

#ifndef NDEBUG
void MP_WEAK __assert_func(const char *file, int line, const char *func, const char *expr) {
    printf("Assertion '%s' failed, at file %s:%d\n", expr, file, line);
    __fatal_error("Assertion failed");
}
#endif
