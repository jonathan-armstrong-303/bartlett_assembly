#PURPOSE	Given a number, this program computes the factorial. 

#This program shows how to call a function recursively.

 .section .data

#This program has no global data [section just included to illustrate best practices]

 .section .text

 .globl _start
 .globl factorial	#not needed unless function needs to be shared across programs

_start:
 pushl $4		#number we want a factorial of
 call factorial		#run the factorial function
 addl $4, %esp		#scrubs the parameter that was pushed on the stack
 movl %eax, %ebx	#factorial returns the answer in %eax, but we want it in #ebx
			#to send it as our exit status

 movl $1, %eax		#call the kernel's exit function. Return values stored in %eax
 int $0x80

 .type factorial,@function
factorial:
 pushl %ebp		#restore %ebp to its prior state before returning
 movl %esp, %ebp	#we use %ebp because we don't want to modify the stack pointer
 movl 8(%ebp), %eax	#this moves the first argument to %eax
			#4(%ebp) holds the return address; 8(%ebp) holds first parameter
 cmpl $1, %eax		#if number is 1, that is our base case and we return.
			#(1 is already in %eax as the rturn value)
 je end_factorial
 decl %eax		#if it's not 1, decrease the value
 pushl %eax		#push it for our call to factorial
 call factorial		#call factorial 
 movl 8(%ebp), %ebx	#%eax has the return value, so we reload our paramter into %ebx

 imull %ebx, %eax	#multiply that by the result of the last call to the factorial
			#(in %eax). The answer is stored in %eax

end_factorial:
 movl %ebp, %esp	#restore %ebp and %esp to status before function started
 popl %ebp
 ret
 
