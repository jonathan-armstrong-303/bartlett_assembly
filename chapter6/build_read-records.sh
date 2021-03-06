#Note: AFAICT, there's no "read-record.s" referenced in the book.
#I added the "read_record" function to "write-records.s" and adjusted the linker directives accordingly.
#The builds in the book do not seem to work as advertised.  To build the two main projects in Chapter VI:
as --32 write-records.s -o  write-records.o
as --32 read-records.s -o read-records.o
as --32 count-chars.s -o count-chars.o
as --32 write-newline.s -o write-newline.o
ld -m elf_i386 -s -o read-records.o count-chars.o write-newline.o write-records.o -o read-records

as --32 add-year.s -o add-year.o
ld -m elf_i386 -s -o add-year.o count-chars.o write-records.o -o add-year
