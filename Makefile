qemu: boot.bin
	qemu-system-x86_64 -drive format=raw,file=boot.bin

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

clean:
	rm *.bin
