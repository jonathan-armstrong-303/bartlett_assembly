#PURPOSE: Simple program that exists and returns a status code back to Linux kernel.

#INPUT: none

#OUTPUT: returns a status code.  Can be viewed by typing echo $?

#VARIABLES
#   %eax holds the system call number
#   %ebx holds the return status

.section .data

.section .text
.globl _start

_start:

 movl $1, %eax # linux kernel command number for exiting a program

 movl $5, %ebx # status number we will return to the OS.
              # Change this around and it will return different things to echo $?

 int $0x80     #this wakes up the kernel to run the exit command
