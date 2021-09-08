#Purpose: Program to manage memory usage (malloc)

#NOTES: programs using these routines will ask for a certain size of memory.
#	We actually use more than that size, but we put it at the beginning,
#	before the pointer we hand back.  We add a size field and an 
#	AVAILABLE/UNAVAILABLE marker.  So, the memory looks like this:
# ##########################################################################
# # Available Marker#Size of memory#Actual memory locations
 ###########################################################################
#                                   ^--Returned pointer points here
#	The pointer we return only points to the actual locations requested
# 	to make it easier for the calling program.  It also allows us to 
#	change our structure without the calling program having to change
############################################################################

.section .data

#########GLOBAL VARIABLES#######

#This points to the beginning of the memory we are managing 
heap_begin:
 .long 0

#This points to one location past the memory we are managing
current_break:
 .long 0

#######STRUCTURE INFORMATION#######
 #size of spadce for memory region header
 .equ HEADER_SIZE, 8
 #location of the "available" flag in header
 .equ HDR_AVAIL_OFFSET, 0
 #location of the size field in the header
 .equ HDR_SIZE_OFFSET, 4

##########CONSTANTS##########
 .equ UNAVAILABLE, 0 #number used to mark space given out
 .equ AVAILABLE, 1 #number used to mark space returned
 .equ SYS_BRK, 45 #system call number for the break 

 .equ LINUX_SYSCALL, 0x80 #make system calls easier to read

 .section .text

##########FUNCTIONS##########

 ##allocate_init##
 #PURPOSE: call function to initialize functions (sets heap_begin and current_break)

 .globl allocate_init
 .type allocate_init, @function
allocate_init:
 pushl %ebp 
 movl %esp, %ebp

 #if brk system call is called with 0 in %ebx, it returns last usable address
 movl $SYS_BRK, %eax
 movl $0, %ebx
 int $LINUX_SYSCALL

 incl %eax #%eax now has last valid address; we want memory location after that
 movl %eax, current_break #store current break

 movl %eax, heap_begin #store current break as our first address.  This will cause
                       #allocate function to get more memory from Linux on first run

 movl %ebp, %esp #exit function
 popl %ebp
 ret
######END OF FUNCTION#####
 ##allocate##
 #PURPOSE:	This function is used to grab a section of memory.  It checks to see
 #              if there are free blocks; if not, asks Linux for a new one
 #
 #PARAMETERS:   this function has one parameter - the size of memory to allocate
 #
 #RETURN VALUE: this function returns the addres of allocated memory in %eax. If
 #              there is no memory available, reutnr 0 in %eax
 #
 ######PROCESSING######
 #Variables used:
 #
 # %ecx - hold size of requested memory (first/only parameter)
 # %eax - current memory region being examined
 # %ebx - current break position
 # %edx - size of current memory region
 #
 #We scan through each memory region starting with heap_begin.  We look at size
 #of each one, and if it has been allocated.  If big enough for requested size and
 #available, it grabs that one.  If it does not find a region large enough, it asks
 #Linux for memory and moves current_break up
 .globl allocate
 .type allocate,@function
 .equ ST_MEM_SIZE, 8 #stack position of memory size to allocate

allocate:
 pushl %ebp
 movl %esp, %ebp

 movl ST_MEM_SIZE(%ebp), %ecx #%ecx holds the desired size [first parameter]

 movl heap_begin, %eax #%eax holds current search location

 movl current_break, %ebx #%ebx holds current break

alloc_loop_begin: #iterate through each memory region

 cmpl %ebx, %eax #compare -- need more memory if equal
 je move_break

 #grab size of this memory
 movl HDR_SIZE_OFFSET(%eax), %edx
 #if space is unavailable, go to the
 cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 je next_location #next one

 cmpl %edx, %ecx #if space available compare size to needed size 
 jle allocate_here #if big enough, go to this line [allocate_here]

next_location:
 addl $HEADER_SIZE, %eax #total size of the memory region is the sum of the size
 addl %edx, %eax #requested (currently stored in %edx), plus another 8 bytes
                 #for the header (4 for the AVAILABLE/UNAVAILABLE flag, and 4 for
                 #the size of the region).  So, adding %edx and $8 to %eax will
                 #get the address of t he next memory region

 jmp alloc_lop_begin #go look at the next location

allocate_here: #if here, that means that the region header of the region
                     #header of the region to allocate is in %eax

 #mark space as unavailable
 movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 addl $HEADER_SIZE, %eax #move %eax past header to usable memory

 movl %ebp, %esp #return from the function
 popl %ebp
 ret

move_break: #if here, we have exhausted all addressable memory and ask for more
            #%ebx holds the current endpoint of the data and %ecx holds its size

 addl $HEADER_SIZE, %ebx #add space for header structure
 addl %ecx, %ebx #add space to the break for the data requested
                #ask Linux for more memory

 pushl %eax #save needed registers
 pushl %ecx
 pushl %ebx

 movl $SYS_BRK, %eax #reset break (%ebx has requested break point)

 int $LINUX_SYSCALL #under normal conditions, this should return the new break in %eax,
                   #which will be either 0 if failure, or equal or larger than requested.
                   

 cmpl $0, %eax #check for error conditions
 je error

 popl %ebx #restore saved registers
 popl %ecx
 popl %eax

 #set memory as unavailable since it is about to be allocated
 movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 #set size of memory
 movl %ecx, HDR_SIZE_OFFSET(%eax)

 #move %eax to actual start of usable memory. %eax now holds return value
 addl $HEADER_SIZE, %eax

 movl %ebx, current_break #save the new break

 movl %ebp, %esp #return function
 popl %ebp
 ret

error:
 movl $0, %eax #on error, return zero
 movl %ebp, %esp
 popl %ebp
 ret
#######END OF FUNCTION#######

##deallocate##
#PURPOSE:	This function returns region of memory to the pool after completion.
#PARAMETERS:	Address of memory to return to memory pool.
#RETURN VALUE:  None

 .globl deallocate
 .type deallocate, @function
 #stack position of memory region to free
 .equ ST_MEMORY_SEG, 4
deallocate:
 #get address of memory to free.  Normally this is 8 (%ebp) but since %ebp wasn't pushed
 #or %esp moved to %ebp, we can just do 4(%esp)
 movl ST_MEMORY_SEG(%esp), %eax

 #get pointer to real beginning of the memory
 subl $HEADER_SIZE, %eax

 #mark it available
 movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)

 #return
 ret
########END OF FUNCTION########


