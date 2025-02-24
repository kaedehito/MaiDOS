qemu: os.img
	qemu-system-x86_64 -drive format=raw,file=os.img

os.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > os.img

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

kernel.bin: kernel.asm
	nasm -f bin kernel.asm -o kernel.bin

clean:
	rm *.bin
