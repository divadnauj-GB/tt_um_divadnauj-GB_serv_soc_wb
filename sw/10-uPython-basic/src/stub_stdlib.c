// #include <sys/stat.h>
// #include <errno.h>
// #include <stdio.h>
// #include "soc_uart.h"
// 
// #include <errno.h>
// #undef errno
// extern int errno;
// 
// 
// int _gettimeofday (struct timeval *__restrict tv, void *__restrict tz) {
//     return 0;
// }
// 
// pid_t _getpid(void) {
//     return 0;
// }
// 
// int _kill(__unused pid_t pid, __unused int sig) {
//     return -1;
// }
// 
// void __attribute__((noreturn)) _exit(__unused int status) {
//     while (1) {
//         //__breakpoint();
//     }
// }
// 
// #define STDIO_HANDLE_STDIN  0
// #define STDIO_HANDLE_STDOUT 1
// #define STDIO_HANDLE_STDERR 2
// 
// void uart_put_buffer(const char *buffer, int length) {
// 	for (int i = 0; i < length; ++i) {
// 		uart_putc(buffer[i]);
// 	}
// }
// 
// void debug_uart_put_buffer(const char *buffer, int length) {
// 	for (int i = 0; i < length; ++i) {
// 		uart_putc(buffer[i]);
// 	}
// }
// 
// int _read(int handle, char *buffer, int length) {
//     if (handle == STDIO_HANDLE_STDIN) {
//         for (int i = 0; i < length; ++i) {
//             while (!uart_tstc())
//                 ;
//             *buffer++ = uart_getc();
//         }
//         return length;
//     }
//     return -1;
// }
// 
// int _write(int handle, char *buffer, int length) {
//     if (handle == STDIO_HANDLE_STDOUT) {
//         uart_put_buffer(buffer, length);
//         return length;
//     }
//     else if (handle == STDIO_HANDLE_STDERR) {
//         debug_uart_put_buffer(buffer, length);
//         return length;
//     }
//     return -1;
// }
// 
// int _open(__unused const char *fn, __unused int oflag, ...) {
//     return -1;
// }
// 
// int _close(__unused int fd) {
//     return -1;
// }
// 
// off_t _lseek(__unused int fd, __unused off_t pos, __unused int whence) {
//     return -1;
// }
// 
// int __attribute__((weak)) _fstat(__unused int fd, __unused struct stat *buf) {
//     return -1;
// }
// 
// int __attribute__((weak)) _isatty(int fd) {
//     return fd == STDIO_HANDLE_STDIN || fd == STDIO_HANDLE_STDOUT || fd == STDIO_HANDLE_STDERR;
// }
//  
// /**
// * Adjust the brk pointer up or down as requested.
// *
// * The initial brk address is set to _end (the end of the BSS).
// * Any requests to adjust the brk will be performed without any
// * error checking.
// *
// * @param delta The number of bytes to raise or lower the brk.
// *
// * @return The address that brk was set to before adjusting it by
// *	delta.  Note that when delta is positive, this will return the 
// *	address of the newly allocated region of memory.
// *
// * @bug It is possible that an errant program could call this and
// *	reduce the brk such that it points below _end or increase the
// *	brk to the point that it overlaps the stack.
// *****************************************************************/
// char *_sbrk (int delta) 
// {
// 	extern char _end[];
// 	static char *end_of_data = _end;
// 
// 	char *ptr = end_of_data;
// 	end_of_data += delta;
// 	return ptr;
// }

#include <sys/stat.h>
#include <errno.h>


#include <errno.h>
#undef errno
extern int errno;


/**
* This will execute an ebreak instruction and assume that the
* CPU will halt or simulation environment will terminate.
*****************************************************************/
void _exit(int i)
{
	 __asm__ __volatile__ (" ebreak ");
}

/**
* It is assumed that there is exactly only process running and that
* it does not support signals.  Therefore calling this is effectively
* illegal and will therefore execute an ebreak instruction.
*****************************************************************/
void _kill(int pid) 
{
#if 1
	 __asm__ __volatile__ (" ebreak ");
#else
	return;						// arguably, this might also be acceptable
#endif
}

/**
* This returns the process ID of the runnung program.
* This library assumes that there is only process that
* can ever run.
*
* @return 1
*****************************************************************/
int _getpid(void) 
{
  return 1;
}
 

/**
* This library does not support any file I/O of any kind.
*
* @return -1 Indicating that file could not be closed.
*****************************************************************/
int _close(int file) 
{
	errno = EBADF;
	return -1; 
}
 
/**
* This library does not support any file I/O of any kind.
* This call will return a status indicating that the file
* in question is a character device.
*
* @return 0 Indicating that the call has succeeded.
*****************************************************************/
int _fstat(int file, struct stat *st) 
{
	st->st_mode = S_IFCHR;
	return 0;
}
 
/**
* This library does not support any file I/O of any kind.
*
* @return 1 Indicating that file is a tty device (a terminal.)
*****************************************************************/
int _isatty(int file) 
{
	return 1;
}
 
/**
* This library does not support any file I/O of any kind.
*
* @return 0 Indicating that the request has succeeded.
*****************************************************************/
int _lseek(int file, int ptr, int dir) 
{ 
	return 0; 
}
 
/**
* This library does not support any file I/O of any kind.
*
* @return -1 (error codition.)
*****************************************************************/
int _open(const char *name, int flags, int mode) 
{ 
	errno = ENFILE;		// The system-wide limit (0) on total open files has been reached.
	return -1; 
}
 
/**
* This library does not support any file I/O of any kind.
*
* @return EOF.
*****************************************************************/
int _read(int file, char *ptr, int len) 
{
	return 0;
}

/**
* This function should satify the caller by simply returning len
* indicating that the write has succeeded as requested in spite
* of the fact that the data is simply ignored/discarded.
*
* @return len
*****************************************************************/
int _write(int file, char *ptr, int len) 
{
	return len;
}
 
/**
* Adjust the brk pointer up or down as requested.
*
* The initial brk address is set to _end (the end of the BSS).
* Any requests to adjust the brk will be performed without any
* error checking.
*
* @param delta The number of bytes to raise or lower the brk.
*
* @return The address that brk was set to before adjusting it by
*	delta.  Note that when delta is positive, this will return the 
*	address of the newly allocated region of memory.
*
* @bug It is possible that an errant program could call this and
*	reduce the brk such that it points below _end or increase the
*	brk to the point that it overlaps the stack.
*****************************************************************/
char *_sbrk (int delta) 
{
	extern char _end[];
	static char *end_of_data = _end;

	char *ptr = end_of_data;
	end_of_data += delta;
	return ptr;
}

__attribute__((section(".patch")))
void patch_function(void) {
    __asm__ volatile("ebreak");
}