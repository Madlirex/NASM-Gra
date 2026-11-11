default rel

; HANDLE GetStdHandle(DWORD nStdHandle)
extern GetStdHandle

; BOOL WriteConsoleA(HANDLE hConsoleOutput, const VOID *lpBuffer, DWORD nNumberOfCharsToWrite, LPDWORD lpNumberOfCharsWritten, LPVOID lpReserved)
extern WriteConsoleA

; BOOL ReadConsoleA(HANDLE hConsoleInput, LPVOID lpBuffer, DWORD nNumberOfCharsToRead, LPDWORD lpNumberOfCharsRead, PCONSOLE_READCONSOLE_CONTROL pInputControl)
extern ReadConsoleA

; void Sleep(DWORD dwMilliseconds)
extern Sleep

section .data
    STD_OUTPUT_HANDLE equ -11
    STD_INPUT_HANDLE equ -10

    stage db 0

    intro_msg db "Let's play a game of hangman!", 0
    intro_msg_len equ $ - intro_msg

section .bss
    inHandle resq 1
    outHandle resq 1

    chars_written resd 1
    chars_read    resd 1
    buffer        resb 64

section .text
    global main

main:
    mov rcx, STD_INPUT_HANDLE
    call get_handle
    mov [inHandle], rax

    mov rcx, STD_OUTPUT_HANDLE
    call get_handle
    mov [outHandle], rax

    lea rcx, [intro_msg]
    mov rdx, intro_msg_len
    call print

    mov rcx, 5000
    call sleep

    xor rax, rax
    ret

; VOID print(STRING* message, INT length)
print:
    sub rsp, 40

    mov r8, rdx
    mov rdx, rcx
    mov rcx, [outHandle]
    lea r9, [chars_written]
    mov qword [rsp + 32], 0

    call WriteConsoleA

    add rsp, 40
    ret

; VOID sleep(int milliseconds)
sleep:
    sub rsp, 40

    call Sleep

    add rsp, 40
    ret

; HANDLE get_handle(INT type)
get_handle:
    sub rsp, 40

    call GetStdHandle

    add rsp, 40
    ret