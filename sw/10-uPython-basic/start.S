
//#include "SERVE.h"

.global main

.section .text.init
.option norvc
.global _start
.type   _start, @function
_start:
.option push
.option norelax
	csrci mstatus, 8
	/* zero-initialize all registers */
	addi x1, zero, 0
	addi x2, zero, 0
	addi x3, zero, 0
	addi x4, zero, 0
	addi x5, zero, 0
	addi x6, zero, 0
	addi x7, zero, 0
	addi x8, zero, 0
	addi x9, zero, 0
	addi x10, zero, 0
	addi x11, zero, 0
	addi x12, zero, 0
	addi x13, zero, 0
	addi x14, zero, 0
	addi x15, zero, 0
	la		gp,__global_pointer$
.option pop
	# Clear the bss segment
	la      a0,__bss_start
	la      a1,__BSS_END__

clear_bss:
	bgeu	a0,a1,finish_bss
	sb		x0,0(a0)
	addi	a0,a0,1
	beq		x0,x0,clear_bss
finish_bss:
	la sp, __stack_top

	call    __libc_init_array       # Run global initialization functions

	la sp, __stack_top
	
	call 	_entry_point
	//call    main

	# abort execution here
	ebreak			

	.size  _start, .-_start


