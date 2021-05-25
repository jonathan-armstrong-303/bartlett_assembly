input_token=$1
as --32 ${1}.s -o ${1}.o
ld -m elf_i386 -s -o ${1} ${1}.o
