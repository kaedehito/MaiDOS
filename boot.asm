mov ax, 0x07c0
mov ds, ax
mov ah, 0x0
mov al, 0x3
int 0x10

welcome:
    mov si, welcome_msg
    call println_str
    call start

start:
    mov si, prompt  ; プロンプト文字列を表示
    call print_str

    mov bx, 0       ; 入力バッファのインデックスをリセット

main_loop:
    call get_key    ; ユーザー入力取得

    cmp al, 0x0D    ; Enterキーかチェック (0x0D = CR)
    je execute_cmd  ; Enterが押されたらコマンド実行

    cmp al, 0x08    ; Backspaceキーかチェック (0x08 = BS)
    je backspace

    cmp bx, 19      ; バッファが一杯なら入力を制限
    jae main_loop

    call print_char         ; 入力文字を画面に表示
    mov [cmd_buf + bx], al  ; 入力をバッファに保存
    inc bx
    jmp main_loop

execute_cmd:
    mov byte [cmd_buf + bx], 0  ; 文字列終端を追加

    mov si, newline
    call print_str

    mov si, cmd_buf
    call compare_cmd

    mov si, newline
    call print_str

    jmp start

backspace:
    cmp bx, 0
    jz main_loop    ; 何も入力されていなければスキップ
    dec bx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10       ; カーソルを戻す
    mov al, ' '
    int 0x10       ; 空白を上書き
    mov al, 0x08
    int 0x10       ; カーソルを再び戻す
    jmp main_loop

get_key:
    mov ah, 0x00
    int 0x16
    ret

print_char:
    mov ah, 0x0E
    int 0x10
    ret

print_str:
    lodsb
    or al, al
    jz done
    call print_char
    jmp print_str
done:
    ret

println_str:
    call print_str
    mov si, newline
    call print_str
    ret

compare_cmd:
    mov si, cmd_buf
    mov di, help_cmd
    call str_cmp
    cmp ax, 1
    je print_help

    mov si, cmd_buf
    mov di, info_cmd
    call str_cmp
    cmp ax, 1
    je print_info

    mov si, cmd_buf
    mov di, exit_cmd
    call str_cmp
    cmp ax, 1
    je halt_system

    ret

print_help:
    mov si, help_msg
    call println_str
    ret

print_info:
    mov si, info_msg_0
    call println_str
    mov si, info_msg_1
    call println_str
    ret

halt_system:
    cli
    hlt

str_cmp:
    ; SI: 入力文字列, DI: 比較対象
    mov cx, 20  ; 最大20文字比較
loop_cmp:
    mov al, [si]
    mov ah, [di]
    cmp al, ah
    jne no_match
    test al, al
    jz match     ; 両方の文字列が `0x00` に到達したら一致
    inc si
    inc di
    loop loop_cmp
match:
    mov ax, 1
    ret
no_match:
    xor ax, ax
    ret



; データ
;--------------------------

prompt db 'SHELL> ', 0
newline db 0x0D, 0x0A, 0

help_cmd db 'help', 0
info_cmd db 'info', 0
exit_cmd db 'exit', 0

help_msg db 'Available commands: help, info, exit', 0
welcome_msg db 'Welcome back to your computer, master!', 0

info_msg_0 db 'Simplified OS v0.1.0', 0
info_msg_1 db 'This OS is just for my learning', 0

cmd_buf times 20 db 0

times 510-($-$$) db 0
db 0x55
db 0xAA
