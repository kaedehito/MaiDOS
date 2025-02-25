; === Simplified OS ===

welcome:
    call APP_clear          ; BIOSの画面をクリア

    mov si, VAL_welcomeMsg  ; 起動メッセージ
    call IO_printLnStr

    mov si, VAL_newline     ; 改行
    call IO_printStr


; === シェル ===

SHELL_start:
    mov si, VAL_shprompt    ; プロンプト文字列を表示
    call IO_printStr

    mov bx, 0       ; 入力バッファのインデックスを初期化

SHELL_mainloop:
    call IO_getKey  ; ユーザー入力取得

    cmp al, 0x0D    ; Enterキーかチェック (0x0D = CR)
    je SHELL_execute; 押されたらコマンド実行

    cmp al, 0x08    ; Backspaceキーかチェック (0x08 = BS)
    je IO_backspace

    cmp bx, 19      ; バッファが一杯なら入力を制限
    jae SHELL_mainloop

    call IO_printChar       ; 入力文字を画面に表示
    mov [BUF_input + bx], al  ; 入力をバッファに保存
    inc bx                  ; バッファを指すbxを進める

    jmp SHELL_mainloop      ; ループ継続

SHELL_execute:
    mov byte [BUF_input + bx], 0  ; 文字列終端を追加

    mov si, VAL_newline     ; 改行
    call IO_printStr

    mov si, BUF_input         ; コマンドを実行
    call SHELL_matchCmd

    mov si, VAL_newline     ; 改行
    call IO_printStr

    jmp SHELL_start     ; プロンプト開始へ戻る

SHELL_matchCmd:
    mov si, BUF_input     ; ヘルプ
    mov di, VAL_shcmdHelp
    call STR_compare    ; 入力とコマンド名"help"が同じか比較
    cmp ax, 1           ; ならば実行する
    je APP_help

    mov si, BUF_input     ; 画面クリア
    mov di, VAL_shcmdClear
    call STR_compare    ; 入力とコマンド名"clear"が同じか比較
    cmp ax, 1           ; ならば実行する
    je APP_clear

    mov si, BUF_input     ; ２倍
    mov di, VAL_shcmdDup
    call STR_compare        ; 入力とコマンド名"dup"が同じか比較
    cmp ax, 1           ; ならば実行する
    je APP_dup

    mov si, BUF_input     ; 終了
    mov di, VAL_shcmdExit
    call STR_compare    ; 入力とコマンド名"exit"が同じか比較
    cmp ax, 1           ; ならば実行する
    je APP_exit

    ret


; === アプリ ===

APP_help:
    mov si, VAL_helpMsg    ; ヘルプを表示
    call IO_printLnStr
    ret

APP_clear:
    mov ax, 0x07c0  ; 画面をクリア
    mov ds, ax
    mov ah, 0x0
    mov al, 0x3
    int 0x10        ; BIOS コール
    ret

APP_dup:    ; ２倍する
    mov ax, [BUF_input + bx + 1]
    sub ax, '0'     ; 数値に変換
    add ax, ax
    add ax, '0'     ; 文字に戻す
    call IO_printChar
    ret

APP_exit:   ; システム終了
    cli
    hlt


; === 文字列操作 ===

STR_compare:        ; 文字列比較
    mov cx, 20      ; 最大20文字比較
STR_compare__loop:
    mov al, [si]    ; SI: 入力文字列, DI: 比較対象
    mov ah, [di]
    cmp al, ah
    jne STR_compare__no_match   ; 違えば終了

    test al, al
    jz STR_compare__match       ; 両方の文字列が Null文字に到達したら一致
    cmp al, ' '
    je STR_compare__match       ; スペースでも終了

    inc si
    inc di
    jmp STR_compare__loop       ; 比較ループ継続
STR_compare__match:
    mov ax, 1
    ret
STR_compare__no_match:
    xor ax, ax
    ret


; === 入出力処理(IO) ===

IO_getKey:
    mov ah, 0x00    ; 入力
    int 0x16        ; BIOS コール
    ret

IO_printChar:
    mov ah, 0x0E    ; 出力
    int 0x10        ; BIOS コール
    ret

IO_printStr:
    lodsb           ; 文字をロード
    or al, al       ; Null文字か
    jz IO_printStr__done    ; ならば終了
    call IO_printChar
    jmp IO_printStr         ; 次の文字へ
IO_printStr__done:
    ret

IO_printLnStr:
    call IO_printStr
    mov si, VAL_newline ; 改行を出力
    call IO_printStr
    ret

IO_backspace:
    cmp bx, 0
    jz SHELL_mainloop    ; 何も入力されていなければスキップ
    dec bx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10        ; カーソルを戻す
    mov al, ' '
    int 0x10        ; 空白を上書き
    mov al, 0x08
    int 0x10        ; カーソルを再び戻す
    jmp SHELL_mainloop


; === データ ===

VAL_shprompt db '[sh]> ', 0
VAL_newline db 0x0D, 0x0A, 0

; コマンド群
VAL_shcmdHelp db 'help', 0
VAL_shcmdClear db 'clear', 0
VAL_shcmdDup db 'dup', 0
VAL_shcmdExit db 'exit', 0

VAL_welcomeMsg db 'Welcome back to computer, master!', 0
VAL_helpMsg db 'Simplified OS v0.1.0', 0x0D, 0x0A, \
    '(c) 2025 Kajizuka Taichi', 0x0D, 0x0A, \
    'Commands: help, dup, clear, exit', 0

; コマンド入力受け付け用バッファ領域
BUF_input times 20 db 0

times 510-($-$$) db 0
db 0x55
db 0xAA
