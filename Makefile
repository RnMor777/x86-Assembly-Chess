NAME=Chess

all: Chess

Chess: Chess.asm
	nasm -f elf -F dwarf -g Chess.asm
	gcc -g -m32 -o Chess Chess.o
	rm -rf Chess.o
