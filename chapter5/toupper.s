#PURPOSE:	This program converts and input file to an output file with all letters
#		converted to upper case.

#PROCESSING: 	1. Open the input file.
#		2. Open the output file.
#		3. Until end of input file is reached:
#		  (a) read part of file into memory buffer
#		  (b) iterate through each byte of memory; convert to upper case [if needed]
#		  (c) write memory buffer to output file

 .section .data

#######CONSTANTS#######

 #system call numbers
 .equ SYS_OPEN, 5
 .equ SYS_WRITE, 4
 .equ SYS_READ, 3
 .equ SYS_CLOSE, 6
 .equ SYS_EXIT, 1
 
 #options for open [see /usr/include/x86_64-linux-gnu/asm/fcntl.h for values]
 #values can be combined by adding them or ORing them
 
 .equ O_RDONLY, 0
 .equ O_CREAT_WRONLY_TRUNC, 03101
 
 #standard file descriptors
 .equ STDIN, 0
 .equ STDOUT, 1
 .equ STDERR, 2
 
 #system call interrupt
 .equ LINUX_SYSCALL, 0x80
 
 .equ END_OF_FILE, 0 #return value of read, i.e. EOF
 
 .equ NUMBER_ARGUMENTS, 2

.section .bss 
 #Buffer -	this is where the data is loaded from input data file and written to output file.
 #		Length should never exceed 16000.

 .equ BUFFER_SIZE, 500
 .lcomm BUFFER_DATA, BUFFER_SIZE

 .section .text

 #STACK POSITIONS
 .equ ST_SIZE_RESERVE, 8
 .equ ST_FD_IN, -4
 .equ ST_FD_OUT, -8
 .equ ST_ARGC, 0 	#number of arguments
 .equ ST_ARGV_0, 4	#name of program
 .equ ST_ARGV_1, 8	#input file name
 .equ ST_ARGV_2, 12	#output file name

 .globl _start
_start:
 ###INITIALIZE PROGRAM###
 #save the stack pointer
 movl %esp, %ebp

 #Allocate space for our file descriptors on the stack

 subl $ST_SIZE_RESERVE, %esp 

open_files:
open_fd_in:
 ###OPEN INPUT FILE###
 #open syscall
 movl $SYS_OPEN, %eax
 #input filename into %ebx
 movl ST_ARGV_1(%ebp), %ebx
 #read-only flag
 movl $O_RDONLY, %ecx
 #this doesn't really matter for reading [?]
 movl $0666, %edx
 #call Linux
 int $LINUX_SYSCALL

store_fd_in:
 #save the given file descriptor
 movl %eax, ST_FD_IN(%ebp)

open_fd_out:
 ###OPEN OUTPUT FILE###
 #open the file
 movl $SYS_OPEN, %eax
 #output filename into %ebx
 movl ST_ARGV_2(%ebp), %ebx
 #flags for writing to the file
 movl $O_CREAT_WRONLY_TRUNC, %ecx
 #permission set for new file (if it's created)
 movl $0666, %edx
 #call Linux

 int $LINUX_SYSCALL

store_fd_out:
 #store the file descriptor here
 movl %eax, ST_FD_OUT(%ebp)

 ###BEGIN MAIN LOOP###
read_loop_begin:
 ###READ IN BLOCK FROM THE INPUT FILE###
 movl $SYS_READ, %eax
 #get the input file descriptor
 movl ST_FD_IN(%ebp), %ebx
 #the location to read into
 movl $BUFFER_DATA, %ecx
 #the size of the buffer
 movl $BUFFER_SIZE, %edx
 #size of buffer is returned in %eax
 int $LINUX_SYSCALL

 ###EXIT IF END IS REACHED###
 #check for end of file marker
 cmpl $END_OF_FILE, %eax
 #if found or on error, go to the end
 jle end_loop

continue_read_loop:
 ###CONVERT THE BLOCK TO UPPER CASE###
 pushl $BUFFER_DATA	#location of buffer
 pushl %eax		#size of buffer
 call convert_to_upper
 popl %eax		#get the size back
 addl $4, %esp		#restore %esp

 ###WRITE THE BLOCK TO OUTPUT FILE###
 #size of the buffer
 movl %eax, %edx
 movl $SYS_WRITE, %eax
 #file to use
 movl ST_FD_OUT(%ebp), %ebx
 #location of buffer
 movl $BUFFER_DATA, %ecx
 int $LINUX_SYSCALL

 ###CONTINUE LOOP###
 jmp read_loop_begin

end_loop:
 ###CLOSE FILES###
 movl $SYS_CLOSE, %eax
 movl ST_FD_OUT(%ebp), %ebx
 int $LINUX_SYSCALL

 movl $SYS_CLOSE, %eax
 movl ST_FD_IN(%ebp), %ebx
 int $LINUX_SYSCALL

 ###EXIT###
 movl $SYS_EXIT, %eax
 movl $0, %ebx
 int $LINUX_SYSCALL

#PURPOSE: 	function to convert lowercase -> uppercase
#INPUT:	first parameter is length of the block of memory to convert
#		second paramter is starting address of that block in memory
#OUTPUT:	overwrites current buffer with uppercase
#VARIABLES:	%eax -  beginning of buffer
#		%ebx - length of buffer
# 		%edi - current buffer offset
#		%cl - current byte being examined (first part of %ecx)
 	
 ###CONSTANTS###
 #the lower boundary of our search
 .equ LOWERCASE_A, 'a'
 #the upper boundary of our search
 .equ LOWERCASE_Z, 'z'
 #conversion between upper and lower case
 .equ UPPER_CONVERSION, 'A' - 'a'

 ###STACK STUFF###
 .equ ST_BUFFER_LEN, 8 	#length of buffer
 .equ ST_BUFFER, 12	#actual buffer

convert_to_upper:
 pushl %ebp
 movl %esp, %ebp

 ###SET UP VARIABLES###
 movl ST_BUFFER(%ebp), %eax
 movl ST_BUFFER_LEN(%ebp), %ebx
 movl $0, %edi
 
 #if a buffer with zero length given, leave
 cmpl $0, %ebx
 je end_convert_loop

convert_loop:
 #get current byte
 movb (%eax,%edi,1), %cl

 #go to next byte unless between 'a' and 'z'
 cmpb $LOWERCASE_A, %cl
 jl next_byte
 cmpb $LOWERCASE_Z, %cl
 jg next_byte

 #otherwise convert byte to uppercase
 addb $UPPER_CONVERSION, %cl
 #and store it back
 movb %cl, (%eax,%edi,1)

next_byte:
 incl %edi		#next byte
 cmpl %edi, %ebx	#continue until end
 jne convert_loop

end_convert_loop:
 #no return value 
 movl %ebp, %esp
 popl %ebp
 ret
