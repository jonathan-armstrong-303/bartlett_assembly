#PURPOSE: Count characters until a null byte is reached.
#
#INPUT: The address of the character string
#
#OUTPUT: Returns the count in %eax
#
#PROCESS:
#  Registers used:
#    %ecx - character count
#    %al - current character
#    %edx - current character address

 .type count_chars, @function
 .globl count_chars

 #One parameter is on the stack
 .equ ST_STRING_START_ADDRESS, 8
count_chars:
 pushl %ebp
 movl %esp, %ebp

 #Counter starts at zero
 movl $0, %ecx

 #Starting address of data
 movl ST_STRING_START_ADDRESS(%ebp), %edx

count_loop_begin:
 #Grab the current character
 movb (%edx), %al
 #Check if null
 cmpb $0, %al
 #Exit if null
 je count_loop_end
 #Else increment counter and pointer
 incl %ecx
 incl %edx
 #Re-enter loop
 jmp count_loop_begin

count_loop_end:
 #Finished, move count to %eax and return
 movl %ecx, %eax

 popl %ebp
 ret



