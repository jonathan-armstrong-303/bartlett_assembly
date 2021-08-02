 .include "linux.s"
 .include "record-def.s"

#PURPOSE: This function reads a record from the file descriptor
#
#INPUT:   file descriptor and buffer
#
#OUTPUT:  This function writes the data to the buffer and returns a status code.
#
#STACK LOCAL VARIABLES

 .equ ST_READ_BUFFER, 8
 .equ ST_FILEDES, 12
 .section .text
 .globl read_record
 .type read_record, @function

read_record:
 pushl %ebp
 movl %esp, %ebp

 pushl %ebx
 movl ST_FILEDES(%ebp), %ebx
 movl ST_READ_BUFFER(%ebp), %ecx
 movl $RECORD_SIZE, %edx
 movl $SYS_READ, %eax
 int $LINUX_SYSCALL

 #NOTE - %eax has the return value which we will give back to calling program

 popl %ebx

 movl %ebp, %esp
 popl %ebp
 ret

#PURPOSE: This function writes a record to the given file descriptor
#
#INPUT:   File descriptor and buffer
#
#OUTPUT:  Status code
#
#STACK LOCAL VARIABLES
 .equ ST_WRITE_BUFFER, 8
 .equ ST_FILEDES, 12
 .section .text
 .globl write_record
 .type write_record, @function

write_record:
 pushl %ebp
 movl %esp, %ebp

 pushl %ebx
 movl $SYS_WRITE, %eax
 movl ST_FILEDES(%ebp), %ebx
 movl ST_WRITE_BUFFER(%ebp), %ecx
 movl $RECORD_SIZE, %edx
 int $LINUX_SYSCALL

 #NOTE - %eax has the return value, which we will give back to our calling program

 popl %ebx
 movl %ebp, %esp
 popl %ebp
 ret

 .section .data

#Constant data of the records to write
#Each text data item is padded to proper length with null bytes
#.rept is used to pad each item. .rept tells as to repeat the
#section between .rept and .endr the number of times specified.
#This is used in this program to add extra null characters at 
#the end of each field to fill it up

record1:
 .ascii "Fredrick\0"
 .rept 31 #padding to 40 bytes
 .byte 0
 .endr

 .ascii "Bartlett\0"
 .rept 31 #padding to 40 bytes
 .byte 0
 .endr

 .ascii "4242 S Prairie\nTulsa, OK 55555\0"
 .rept 209 #padding to 240 bytes
 .byte 0
 .endr

 .long 45

record2:
 .ascii "Marilyn\0"
 .rept 32 #padding to 40 bytes
 .byte 0
 .endr

 .ascii "Taylor\0"
 .rept 33 #padding to 40 bytes
 .byte 0
 .endr

 .ascii "2224 S Johannan St\nChicago, IL 12345\0"
 .rept 203 #padding to 240 bytes
 .byte 0
 .endr

 .long 29

record3:
 .ascii "Derrick\0"
 .rept 32 #padding to 40 bytes
 .byte 0
 .endr

 .ascii "McIntire\0"
 .rept 31 #padding to 40 bytes
 .byte 0
 .endr

 .ascii "500 W Oakland\nSan Diego, CA 54321\0"
 .rept 206 #padding to 240 bytes
 .byte 0
 .endr

 .long 36

 #File to write to 
file_name:
 .ascii "test.dat\0"

 .equ ST_FILE_DESCRIPTOR, -4
 .globl _start
_start:
 #copy stack pointer to %ebp
 movl %esp, %ebp
 #Allocate space to hold the file descriptor
 subl $4, %esp

 #open file
 movl $SYS_OPEN, %eax
 movl $file_name, %ebx
 movl $0101, %ecx #create if doesn't exist & open for writing
 movl $0666, %edx
 int $LINUX_SYSCALL

 #store file descriptor
 movl %eax, ST_FILE_DESCRIPTOR(%ebp)

 #write first record
 pushl ST_FILE_DESCRIPTOR(%ebp)
 pushl $record1
 call write_record
 addl $8, %esp

 #write second record
 pushl ST_FILE_DESCRIPTOR(%ebp)
 pushl $record2
 call write_record
 addl $8, %esp

 #write third record
 pushl ST_FILE_DESCRIPTOR(%ebp)
 pushl $record3
 call write_record
 addl $8, %esp

 #close file descriptor
 movl $SYS_CLOSE, %eax
 movl ST_FILE_DESCRIPTOR(%ebp), %ebx
 int $LINUX_SYSCALL

 #exit program
 movl $SYS_EXIT, %eax
 movl $0, %ebx
 int $LINUX_SYSCALL
