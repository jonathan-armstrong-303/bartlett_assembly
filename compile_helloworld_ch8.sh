# build HelloWorld.  This is for 64-bit
# ripped from https://github.com/swseverance/programming-from-the-ground-up/blob/master/ch8/helloworld-lib.s

as -g -o helloworld-nolib.o helloworld-nolib.s && ld -o helloworld-nolib helloworld-nolib.o && ./helloworld-nolib

as -g -o helloworld-lib.o helloworld-lib.s && ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o helloworld-lib helloworld-lib.o -lc && ./helloworld-lib

as -g -o printf-example.o printf-example.s && ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o printf-example printf-example.o -lc && ./printf-example
