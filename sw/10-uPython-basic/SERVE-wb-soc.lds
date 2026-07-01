ENTRY(_start)

SECTIONS {
    . = 0x01000000;
    __kernel_base = .;

    .text : ALIGN(4){
        KEEP(*(.text.init));
        *(.text.trap_vec); 
        *(.text.reset); 
        *(.text .text.*);
    }
    /*This region is used to allocate trampoline functions to patch SH instructions*/
    .patch : ALIGN(4){
        _spatch = .;
        KEEP(*(.patch))
        . += 1*1024; /* 5K */
        _epatch = .;
    }

    .rodata : ALIGN(4) {
        *(.rodata .rodata.*);
    }

    .init_array :
    {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
        KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
        PROVIDE_HIDDEN (__init_array_end = .);
    } 

    .fini_array :
    {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
        KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } 

    .ctors :
    {
        KEEP (*crtbegin.o(.ctors))
        KEEP (*crtbegin?.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*(.ctors))
    } 

    .dtors :
    {
        KEEP (*crtbegin.o(.dtors))
        KEEP (*crtbegin?.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*(.dtors))
    } 

    .data : ALIGN(4) {
        _data_start = .;
        __DATA_BEGIN__ = .;
        *(.data .data.*);
    }
    
    .sdata :  ALIGN(4)
    {
        __SDATA_BEGIN__ = .;
        *(.sdata .sdata.* .gnu.linkonce.s.*)
    }
    __bss_start = .;
    .sbss   :  ALIGN(4)
    {
        *(.dynsbss)
        *(.sbss .sbss.* .gnu.linkonce.sb.*)
        *(.scommon)
    }
    .bss : ALIGN(4) {
        *(.dynbss)
        *(.bss .bss.* .gnu.linkonce.b.*)
        *(COMMON)
    }

    . = ALIGN(4);
    __BSS_END__ = .;
    __global_pointer$ = MIN(__SDATA_BEGIN__ + 0x800,
                            MAX(__DATA_BEGIN__ + 0x800, __BSS_END__ - 0x800));
    _end = .; PROVIDE (end = .);

    .stack : ALIGN(4) {
    _sstack = .;
    . += 2*1024 * 1024; /* 1MB */
    __stack_top = .;
    _estack = .;
    }

}