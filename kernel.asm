welcome:
    call clear_screen   ; BIOSの画面をクリア

    mov si, welcome_msg ; 起動メッセージ
    call println_str

    mov si, newline     ; 改行
    call print_str

start:
    mov si, prompt  ; プロンプト文字列を表示
    call print_str

    mov bx, 0       ; 入力バッファのインデックスをリセット

main_loop:
    call get_key    ; ユーザー入力取得

    cmp al, 0x0D    ; Enterキーかチェック (0x0D = CR)
    je execute_cmd  ; 押されたらコマンド実行

    cmp al, 0x08    ; Backspaceキーかチェック (0x08 = BS)
    je backspace

    cmp bx, 19      ; バッファが一杯なら入力を制限
    jae main_loop

    call print_char         ; 入力文字を画面に表示
    mov [cmd_buf + bx], al  ; 入力をバッファに保存
    inc bx                  ; バッファを指すbxを進める

    jmp main_loop           ; ループ継続

execute_cmd:
    mov byte [cmd_buf + bx], 0  ; 文字列終端を追加

    mov si, newline     ; 改行
    call print_str

    mov si, cmd_buf     ; コマンドを実行
    call compare_cmd

    mov si, newline     ; 改行
    call print_str

    jmp start       ; プロンプト開始へ戻る

backspace:
    cmp bx, 0
    jz main_loop    ; 何も入力されていなければスキップ
    dec bx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10        ; カーソルを戻す
    mov al, ' '
    int 0x10        ; 空白を上書き
    mov al, 0x08
    int 0x10        ; カーソルを再び戻す
    jmp main_loop

get_key:
    mov ah, 0x00    ; 入力
    int 0x16        ; BIOS コール
    ret

print_char:
    mov ah, 0x0E    ; 出力
    int 0x10        ; BIOS コール
    ret

print_str:
    lodsb           ; 文字をロード
    or al, al       ; Null文字か
    jz done         ; ならば終了
    call print_char
    jmp print_str   ; 次の文字へ
done:
    ret

println_str:
    call print_str
    mov si, newline ; 改行を出力
    call print_str
    ret

compare_cmd:
    mov si, cmd_buf     ; ヘルプ
    mov di, shcmd_help
    call str_cmp        ; 入力とコマンド名"help"が同じか比較
    cmp ax, 1           ; ならば実行する
    je print_help

    mov si, cmd_buf     ; 画面クリア
    mov di, shcmd_clear
    call str_cmp        ; 入力とコマンド名"clear"が同じか比較
    cmp ax, 1           ; ならば実行する
    je clear_screen

    mov si, cmd_buf     ; ２倍
    mov di, shcmd_dup
    call str_cmp        ; 入力とコマンド名"dup"が同じか比較
    cmp ax, 1           ; ならば実行する
    je dup_arg

    mov si, cmd_buf     ; 終了
    mov di, shcmd_exit
    call str_cmp        ; 入力とコマンド名"exit"が同じか比較
    cmp ax, 1           ; ならば実行する
    je halt_system

    ret

print_help:
    mov si, help_msg    ; ヘルプを表示
    call println_str
    ret

clear_screen:
    mov ax, 0x07c0  ; 画面をクリア
    mov ds, ax
    mov ah, 0x0
    mov al, 0x3
    int 0x10        ; BIOS コール
    ret

dup_arg:
    mov ax, [cmd_buf + bx + 1]
    sub ax, '0'
    add ax, ax
    add ax, '0'
    call print_char
    ret

halt_system:        ; システム終了
    cli
    hlt

str_cmp:            ; 文字列比較
    mov cx, 20      ; 最大20文字比較
loop_cmp:
    mov al, [si]    ; SI: 入力文字列, DI: 比較対象
    mov ah, [di]
    cmp al, ah
    jne no_match    ; 違えば終了

    test al, al
    jz match        ; 両方の文字列が Null文字に到達したら一致
    cmp al, ' '
    je match        ; スペースでも終了

    inc si
    inc di
    jmp loop_cmp   ; 比較ループ継続
match:
    mov ax, 1
    ret
no_match:
    xor ax, ax
    ret

prompt db '[sh]> ', 0
newline db 0x0D, 0x0A, 0

shcmd_help db 'help', 0
shcmd_clear db 'clear', 0
shcmd_dup db 'dup', 0
shcmd_exit db 'exit', 0

welcome_msg db 'Welcome back to computer, master!', 0
help_msg db 'Simplified OS v0.1.0', 0x0D, 0x0A, \
    '(c) 2024 Kajizuka Taichi', 0x0D, 0x0A, \
    'Commands: help, info, clear, now, exit', 0

; コマンド入力受け付け領域
cmd_buf times 20 db 0

times 510-($-$$) db 0
db 0x55
db 0xAA
