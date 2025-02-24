qemu: kernel.bin
	qemu-system-x86_64 -drive format=raw,file=kernel.bin

kernel.bin: kernel.asm
	nasm -f bin kernel.asm -o kernel.bin

clean:
	rm *.bin
