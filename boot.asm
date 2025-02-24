org 0x7C00
bits 16

start:
    mov ah, 0x02   ; 読み込みコマンド
    mov al, 1      ; 読み込むセクタ数（1セクタ = 512バイト）
    mov ch, 0      ; シリンダー番号
    mov cl, 2      ; セクタ番号（1から始まるので、2を読む）
    mov dh, 0      ; ヘッド番号
    mov dl, 0x80   ; ドライブ番号（0x80 = HDD）
    mov bx, 0x7E00 ; 読み込み先メモリアドレス
    mov es, bx     ; `ES:BX` に格納
    xor bx, bx     ; `BX` を 0 にする（0x7E00:0000 でアクセス）
    int 0x13       ; ディスクから読み込む

    jmp 0x07E0:0x0200   ; 読み込んだカーネルを実行

times 510-($-$$) db 0   ; 512バイトにパディング
dw 0xAA55               ; ブートセクタのシグネチャ
