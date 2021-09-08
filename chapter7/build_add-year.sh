# I shuffled around some of the functions since there were some wacky discrepancies in the book I couldn't account for.
# YMMV, but this will at least get Chapter 7 to compile based on what I've given here.
as --32 add-year.s -o add-year.o
as --32 error-exit.s -o error-exit.o
ld -m elf_i386 -s -o add-year.o write-newline.o error-exit.o write-records.o count-chars.o -o add-year

