qemu: os.bin
	qemu-system-x86_64 -drive format=raw,file=os.bin

os.bin: boot.bin kernel.bin
	cat boot.bin kernel.bin > os.bin

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

kernel.bin: kernel.asm
	nasm -f bin kernel.asm -o kernel.bin

clean:
	rm *.bin
