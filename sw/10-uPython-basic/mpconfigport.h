#include <stdint.h>

#define MICROPY_CONFIG_ROM_LEVEL (MICROPY_CONFIG_ROM_LEVEL_BASIC_FEATURES)

#define MICROPY_ENABLE_COMPILER     (1)


#define MICROPY_QSTR_EXTRA_POOL           mp_qstr_frozen_const_pool
#define MICROPY_ENABLE_GC                 (1)
#define MICROPY_HELPER_REPL               (1)
#define MICROPY_MODULE_FROZEN_MPY         (1)
#define MICROPY_ENABLE_EXTERNAL_IMPORT    (1)

//#define MICROPY_DEBUG_NLR        (1)
//#define MICROPY_DEBUG_PRINTERS   (1)
//#define MICROPY_DEBUG_VERBOSE    (1)

#define MICROPY_ALLOC_PATH_MAX            (256)

// Use the minimum headroom in the chunk allocator for parse nodes.
#define MICROPY_ALLOC_PARSE_CHUNK_INIT    (16)

// Disable all optional sys module features.
#define MICROPY_PY_SYS_MODULES            (0)
#define MICROPY_PY_SYS_EXIT               (0)
#define MICROPY_PY_SYS_PATH               (0)
#define MICROPY_PY_SYS_ARGV               (0)

typedef long mp_off_t;
typedef intptr_t mp_int_t; // must be pointer size
typedef uintptr_t mp_uint_t; // must be pointer size
//#define MP_SSIZE_MAX (0x7fffffff)

// We need to provide a declaration/definition of alloca().
#include <alloca.h>

// Define the port's name and hardware.
#define MICROPY_HW_BOARD_NAME "serv-soc-wb"
#define MICROPY_HW_MCU_NAME   "SERV-E"

#define MICROPY_HEAP_SIZE      (1*1024*1024) // heap size 1MB kilobytes


#define MP_STATE_PORT MP_STATE_VM

#define MICROPY_PY_TIME (0)
#define MICROPY_VFS              (0)
#define MICROPY_READER_VFS       (0)
#define MICROPY_PY_IO            (0)
#define MICROPY_PY_OS         (1)