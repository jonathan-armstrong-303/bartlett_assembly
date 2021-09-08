.section .data

helloworld:
    .ascii "hello world\n"
helloworld_end:

.equ helloworld_len, helloworld_end - helloworld

.equ STDOUT, 1
.equ EXIT, 60
.equ WRITE, 1

.section .text

.global _start

_start:
    mov $WRITE, %rax
    mov $STDOUT, %rdi
    mov $helloworld, %rsi
    mov $helloworld_len, %rdx
    syscall

    mov $EXIT, %rax
    mov $0, %rdi
    syscall
