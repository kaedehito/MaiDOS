org 0x7C00   ; ブートセクタの開始位置
bits 16      ; 16ビットモード

start:
    mov ah, 0x02    ; 読み込みコマンド
    mov al, 1       ; 読み込むセクタ数（1セクタ = 512バイト）
    mov ch, 0       ; シリンダー番号（トラック）
    mov cl, 2       ; セクタ番号（1から始まるので、2を読む）
    mov dh, 0       ; ヘッド番号
    mov dl, 0x80    ; ドライブ番号（0x80 = HDD, 0x00 = フロッピー）
    mov bx, 0x7E00  ; 読み込み先のメモリアドレス
    mov es, bx      ; `ES:BX` に格納（BIOS 仕様）
    xor bx, bx      ; `BX` を 0 にする（0x7E00:0000 でアクセス）
    int 0x13        ; ディスクから読み込む

    jc disk_error   ; キャリーフラグが立っていたらエラー処理

    jmp 0x7E00      ; 読み込んだコードを実行

disk_error:
    mov si, err_msg
    call print_string
    cli
    hlt

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

err_msg db "Disk read error!", 0

times 510-($-$$) db 0  ; 512バイトにパディング
dw 0xAA55              ; ブートセクタのシグネチャ
