[BITS 16]
[ORG 0x1000]  ; カーネルはブートローダーにより 0x1000 にロードされる

; ==========================
; カーネルのエントリポイント
; ==========================
start:
    cli                 ; 割り込みを禁止
    xor ax, ax          ; セグメントレジスタを初期化
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; スタックの初期化
    sti                 ; 割り込みを許可

    ; ウェルカムメッセージを表示
    mov si, VAL_msgWelcome
    call IO_printStr
    call IO_printNewLine
    call IO_printNewLine

; ==========================
; シェルのメインループ
; ==========================
SHELL_start:
    mov si, VAL_msgPrompt    ; プロンプト表示
    call IO_printStr

    mov bx, 0   ; 入力バッファのインデックス
    xor dh, dh  ; スペース入力フラグを初期化

SHELL_mainLoop:
    call IO_getKey      ; ユーザー入力取得

    cmp al, 0x0D        ; Enterキー (CR) かチェック
    je SHELL_execute    ; Enterならコマンド実行

    cmp al, ' '         ; スペースキーかチェック
    je SHELL_mainLoop__space

    cmp al, 0x08        ; バックスペースキーかチェック
    je IO_backspace

    cmp bx, 49          ; バッファがいっぱいなら入力を制限
    jae SHELL_mainLoop

    call IO_printChar   ; 入力文字を画面に表示
    mov [BUF_input + bx], al  ; 入力バッファに格納
    inc bx

    jmp SHELL_mainLoop

; スペースキー処理
SHELL_mainLoop__space:
    call IO_printChar

    cmp dh, 0
    jne SHELL_mainLoop__spaceSecond

    mov byte [BUF_input + bx], 0  ; Null文字を挿入
    inc bx
    inc dh                        ; スペースフラグを立てる
    jmp SHELL_mainLoop

SHELL_mainLoop__spaceSecond:
    mov byte [BUF_input + bx], ' '
    inc bx
    jmp SHELL_mainLoop

; ==========================
; コマンドの実行
; ==========================
SHELL_execute:
    mov byte [BUF_input + bx], 0  ; 文字列終端を追加
    call IO_printStr  ; 改行

    mov si, BUF_input
    call KERNEL_launchApp  ; コマンド解析・実行

    call IO_printNewLine  ; 2回改行
    call IO_printNewLine

    jmp SHELL_start  ; シェル再開

; ==========================
; アプリケーションの起動
; ==========================
KERNEL_launchApp:
    mov si, BUF_input
    mov di, VAL_cmdEcho
    call STR_compare
    cmp ax, 1
    je APP_echo

    mov si, BUF_input
    mov di, VAL_cmdClear
    call STR_compare
    cmp ax, 1
    je APP_clear

    mov si, BUF_input
    mov di, VAL_cmdHelp
    call STR_compare
    cmp ax, 1
    je APP_help

    mov si, BUF_input
    mov di, VAL_cmdExit
    call STR_compare
    cmp ax, 1
    je APP_exit

    mov si, VAL_msgError  ; 未知のコマンド
    call IO_printStr
    mov si, BUF_input
    call IO_printStr

    ret

; ==========================
; 各アプリケーションの処理
; ==========================
APP_echo:
    mov si, BUF_input
    add si, 5
    call IO_printStr
    ret

APP_clear:
    mov ax, 0x07C0
    mov ds, ax
    mov ah, 0x00
    mov al, 0x03
    int 0x10  ; BIOS コールで画面クリア
    ret

APP_help:
    mov si, VAL_msgHelp
    call IO_printStr
    ret

APP_exit:
    cli
    hlt

; ==========================
; 文字列操作関数
; ==========================
STR_compare:
    mov cx, 20
STR_compare_loop:
    mov al, [si]
    mov ah, [di]
    cmp al, ah
    jne STR_compare_noMatch
    test al, al
    jz STR_compare_match
    inc si
    inc di
    jmp STR_compare_loop
STR_compare_match:
    mov ax, 1
    ret
STR_compare_noMatch:
    xor ax, ax
    ret

; ==========================
; 入出力処理 (IO)
; ==========================
IO_getKey:
    mov ah, 0x00
    int 0x16
    ret

IO_printChar:
    mov ah, 0x0E
    int 0x10
    ret

IO_printStr:
    lodsb
    or al, al
    jz IO_printStr_done
    call IO_printChar
    jmp IO_printStr
IO_printStr_done:
    ret

IO_printNewLine:
    mov si, VAL_newLine
    call IO_printStr
    ret

IO_backspace:
    cmp bx, 0
    jz SHELL_mainLoop
    dec bx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp SHELL_mainLoop

; ==========================
; データ領域
; ==========================
VAL_msgWelcome db 'Welcome to MaiDOS!', 0
VAL_msgPrompt db '[sh]> ', 0
VAL_msgError db 'Error: Unknown command: ', 0
VAL_msgHelp db 'MaiDOS v0.2.5', 0x0D, 0x0A, \
    '(c) 2025 Kajizuka Taichi', 0x0D, 0x0A, \
    'Commands: echo, clear, help, exit', 0

BUF_input times 50 db 0
VAL_newLine db 0x0D, 0x0A, 0

VAL_cmdEcho db 'echo', 0
VAL_cmdClear db 'clear', 0
VAL_cmdHelp db 'help', 0
VAL_cmdExit db 'exit', 0
