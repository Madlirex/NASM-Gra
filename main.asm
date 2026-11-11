default rel

; HANDLE GetStdHandle(DWORD nStdHandle)
extern GetStdHandle

; BOOL WriteConsoleA(HANDLE hConsoleOutput, const VOID *lpBuffer, DWORD nNumberOfCharsToWrite, LPDWORD lpNumberOfCharsWritten, LPVOID lpReserved)
extern WriteConsoleA

; BOOL ReadConsoleA(HANDLE hConsoleInput, LPVOID lpBuffer, DWORD nNumberOfCharsToRead, LPDWORD lpNumberOfCharsRead, PCONSOLE_READCONSOLE_CONTROL pInputControl)
extern ReadConsoleA

; HANDLE CreateFileA(LPCSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, LPSECURITY_ATTRIBUTES lpSecurityAttributes, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile)
extern CreateFileA

; BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped)
extern ReadFile

; BOOL CloseHandle(HANDLE hObject)
extern CloseHandle

; ULONGLONG GetTickCount64()
extern GetTickCount64

; void Sleep(DWORD dwMilliseconds)
extern Sleep

section .data
    STD_OUTPUT_HANDLE equ -11
    STD_INPUT_HANDLE equ -10
    BUFFER_SIZE equ 64

    WORD_BUFFER_SIZE equ 64
    FILE_BUFFER_SIZE equ 4096

    GENERIC_READ          equ 0x80000000
    FILE_SHARE_READ       equ 1
    OPEN_EXISTING         equ 3
    FILE_ATTRIBUTE_NORMAL equ 0x80
    INVALID_HANDLE_VALUE  equ -1

    words_file db "words.txt", 0

    stage db 0

    intro_msg db "Let's play a game of hangman!", 0
    intro_msg_len equ $ - intro_msg

    prompt_msg db "Your guess: ", 0
    prompt_msg_len equ $ - prompt_msg

    wrong_msg db "Wrong guess!", 0
    wrong_msg_len equ $ - wrong_msg

    try_again_msg db "Try again!", 0
    try_again_msg_len equ $ - try_again_msg

section .bss
    inHandle resq 1
    outHandle resq 1

    chars_written resd 1
    chars_read    resd 1
    buffer        resb BUFFER_SIZE

    file_handle     resq 1
    bytes_read      resd 1
    file_buffer     resb FILE_BUFFER_SIZE

    secret_word     resb WORD_BUFFER_SIZE
    secret_word_len resq 1

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

    call input_char

    lea rcx, [buffer]
    mov rdx, BUFFER_SIZE
    call print

    call load_random_word

    lea rcx, [secret_word]
    mov rdx, [secret_word_len]
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

; CHAR input_char()
input_char:
    sub rsp, 40

    mov rcx, [inHandle]
    lea rdx, [buffer]
    mov r8, BUFFER_SIZE
    lea r9, [chars_read]
    mov qword [rsp + 32], 0

    call ReadConsoleA

    movzx rax, byte [buffer]

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

; HANDLE open_file(STRING* file_name)
open_file:
    sub rsp, 56

    mov edx, GENERIC_READ
    mov r8d, FILE_SHARE_READ
    mov r9, 0
    mov qword [rsp + 32], OPEN_EXISTING
    mov qword [rsp + 40], FILE_ATTRIBUTE_NORMAL
    mov qword [rsp + 48], 0
    call CreateFileA

    add rsp, 56
    ret

; DWORD read_file(HANDLE hFile, VOID* buffer, DWORD max_bytes)
read_file:
    sub rsp, 40

    lea r9, [bytes_read]
    mov qword [rsp + 32], 0
    call ReadFile

    mov eax, [bytes_read]
    add rsp, 40
    ret

; BOOL close_file(HANDLE hFile)
close_file:
    sub rsp, 40

    call CloseHandle

    add rsp, 40
    ret

; UINT64 get_random(UINT64 max)
get_random:
    sub rsp, 40
    push rbx

    mov rbx, rcx
    call GetTickCount64
    xor rdx, rdx
    div rbx
    mov rax, rdx

    pop rbx
    add rsp, 40
    ret

; VOID load_random_word()
load_random_word:
    sub rsp, 40
    push rsi
    push rdi

    lea rcx, [words_file]
    call open_file
    cmp rax, INVALID_HANDLE_VALUE
    je .done
    mov [file_handle], rax

    mov rcx, [file_handle]
    lea rdx, [file_buffer]
    mov r8d, FILE_BUFFER_SIZE - 1
    call read_file

    lea rcx, [file_buffer]
    mov byte [rcx + rax], 0

    mov rcx, [file_handle]
    call close_file

    lea rsi, [file_buffer]
    xor rcx, rcx

.count_loop:
    mov al, [rsi]
    cmp al, 0
    je .count_finished
    cmp al, 10
    jne .next_count_char
    inc rcx

.next_count_char:
    inc rsi
    jmp .count_loop

.count_finished:
    cmp rcx, 0
    je .done

    call get_random
    mov rdx, rax

    lea rsi, [file_buffer]

.skip_loop:
    cmp rdx, 0
    je .copy_word
    mov al, [rsi]
    cmp al, 0
    je .done
    inc rsi
    cmp al, 10
    jne .skip_loop
    dec rdx
    jmp .skip_loop

.copy_word:
    lea rdi, [secret_word]
    xor rcx, rcx

.copy_loop:
    mov al, [rsi]
    cmp al, 0
    je .finish_copy
    cmp al, 13
    je .finish_copy
    cmp al, 10
    je .finish_copy

    mov [rdi], al
    inc rsi
    inc rdi
    inc rcx
    jmp .copy_loop

.finish_copy:
    mov byte [rdi], 0
    mov [secret_word_len], rcx

.done:
    pop rdi
    pop rsi
    add rsp, 40
    ret