# QEMUでエミュレート
qemu: build/maidos.img
	qemu-system-i386 -drive format=raw,file=build/maidos.img -boot order=a -d int &



# OSイメージの作成
build/maidos.img: build/bootloader.bin build/kernel.bin
	cat build/bootloader.bin build/kernel.bin > build/maidos.img

# ブートローダーをビルド (512バイト固定)
build/bootloader.bin: src/bootloader.asm | build
	nasm -f bin src/bootloader.asm -o build/bootloader.bin
	truncate -s 512 build/bootloader.bin  # 512バイトに強制調整

# カーネルをビルド
build/kernel.bin: src/kernel.asm | build
	nasm -f bin src/kernel.asm -o build/kernel.bin

# ビルド用ディレクトリ作成
build:
	mkdir -p build/

# クリーンアップ
clean:
	rm -rf build/*
