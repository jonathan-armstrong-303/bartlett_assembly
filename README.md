# bartlett_assembly
Exercises from Jonathan Bartlett's "Programming From The Ground Up: An Introduction To Programming Using Linux Assembly Language"

Recently, I decided to review basic CompSci concepts and get into some low-level code since my knowledge had atrophied (to put it mildly) since the 1990's and decided to step through Jonathan Bartlett's excellent *Programming From The Ground Up*.

One change of note: since the publication of this book in 2007, most of us are now using 64 bit Linux machines, and as someone long since working in higher-level languages I had forgotten how non-trivial the differences are between 32 and 64 bit assembly language.  After some initial frustration trying to recode the assignments to be congruent with 64-bit, I gave up and just ran these in their intended 32 bit form with no issues thus far: simply use the **--32** flag to assemble and link per the syntax below before execution:

as power.s --32 -o power.o
ld -m elf_i386 -s -o power power.o

The *compile_link.sh* script in this project automates both of these steps.
