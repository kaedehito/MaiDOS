[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov si, VAL_msgLoading
    call print

    mov bx, 0x1000 ; カーネルをロードするメモリ位置
    mov dh, 2      ; 読み込むセクタ数
    call disk_load

    jmp 0x1000:0000  ; カーネルを実行

; =======================
; ディスクからカーネルを読み込む
; 入力: BX=メモリ位置, DH=読み込むセクタ数
; =======================

disk_load:
    mov ah, 0x02
    mov al, dh
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0  ; BIOSが渡したブートデバイスをそのまま使う
    mov si, 3  ; リトライ回数

.disk_done:
    ret

.disk_retry:
mov si, VAL_msgRetry
    call print
    push si
    int 0x13
    pop si
    jc disk_error   ; キャリーがセットされていたらエラー
    jnc .disk_done
    dec si
    jnz .disk_retry	

disk_error:
    mov si, VAL_msgDiskError
    call print
    jmp abort


abort:
    cli
    hlt

; =======================
; 画面に文字列を表示
; =======================
print: 
    mov ah, 0x0E
.loop:
    lodsb
    or al, al
    jz .done
    cmp al, 0x0A
    je .loop
    cmp al, 0x0D
    je .newline
    int 0x10
    jmp .loop
.newline:
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    jmp .loop
.done:
    ret

; メッセージデータ
VAL_msgLoading db "Loading kernel...", 0
VAL_msgDiskError db "Error: Disk read error!", 0
VAL_msgRetry db "Retry...", 0

times 510-($-$$) db 0
dw 0xAA55
