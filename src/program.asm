[BITS 16]
[ORG 800h]

start:
    ; Очищаем экран
    mov ax, 0x03
    int 0x10

    ; Отображаем сообщение
    mov si, hello_msg
    call print_string

    ; Ждём нажатия клавиши
    mov ah, 0x00
    int 0x16

    ; Возврат в терминал
    jmp 7c00h

print_string:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x0F
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_char
.done:
    ret

hello_msg db 'Hello, world!', 0
