fasm asm_code.asm
gcc -c c_code.c
ld -nostdlib -T kolibri.ld -o e80.kex asm_code.obj kolibri.o stdlib.o string.o c_code.o z80.o
objcopy e80.kex -O binary
pause