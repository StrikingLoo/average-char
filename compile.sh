gcc -c -o main.o main.c
nasm -f elf64 -o main_asm.o main.asm
gcc -o main.exe *.o
