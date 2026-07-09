
  .section .text.init
  .global _start
  .type   _start, @function

_start:

  # Initialize global pointer
.option push
.option norelax
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

	la      a0,_sdata
	la      a1,_edata
	la      a2,_sidata
copy_data:
	bgeu	a0,a1,finish_data
	lbu		a3,0(a2)
	sb		a3,0(a0)
	addi	a0,a0,1
	addi	a2,a2,1
	beq		x0,x0,copy_data
finish_data:
	la sp, __stack_top
	call    __libc_init_array       # Run global initialization functions

	call    main

	# abort execution here
	ebreak			

	.size  _start, .-_start