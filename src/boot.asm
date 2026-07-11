[BITS 16]
[ORG 7c00h]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ax, 0x03
    int 0x10

    ;Чтение секторов с диска
    mov ah, 0x02
    mov al, 3
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov bx, 0x500
    int 0x13

    jc disk_error

    jmp 0x500

disk_error:
    mov si, error_message
    mov di, 0xB800
    call print_string
    jmp $

print_string:
    mov ah, 0x0E
.print_char:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .print_char
.done:
    ret

error_message db "LimeanBoot ERROR: Disk read error", 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55
