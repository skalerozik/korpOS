[BITS 16]
[ORG 500h]

start:
    call clear_screen
    mov si, hello_msg
    call print_string
    call print_newline

    call shell

hang:
    jmp hang

shell:
    mov si, prompt
    call print_string

    call read_command
    call print_newline

    call execute_command
    jmp shell

read_command:
    mov di, command_buffer
    xor cx, cx
.read_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je .done_read
    cmp al, 0x08
    je .handle_backspace
    cmp cx, 255
    jge .done_read
    stosb
    mov ah, 0x0E
    mov bl, 0x1F
    int 0x10
    inc cx
    jmp .read_loop

.handle_backspace:
    cmp di, command_buffer
    je .read_loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .read_loop

.done_read:
    mov byte [di], 0
    ret

execute_command:
    mov si, command_buffer
    mov di, sysinf_str
    call compare_strings
    je do_sysinf

    mov si, command_buffer
    mov di, help_str
    call compare_strings
    je do_help

    mov si, command_buffer
    mov di, clr_str
    call compare_strings
    je do_clear

    mov si, command_buffer
    mov di, dat_str
    call compare_strings
    je print_date

    mov si, command_buffer
    mov di, time_str
    call compare_strings
    je print_time

    mov si, command_buffer
    mov di, shut_str
    call compare_strings
    je do_shutdown

    mov si, command_buffer
    mov di, reboot_str
    call compare_strings
    je do_reboot

    mov si, command_buffer
    mov di, load_str
    call compare_strings
    je load_program

    call unknown_command
    ret

compare_strings:
    xor cx, cx
.next_char:
    lodsb
    cmp al, [di]
    jne .not_equal
    cmp al, 0
    je .equal
    inc di
    jmp .next_char
.not_equal:
    ret
.equal:
    ret

do_clear:
    call clear_screen
    ret

do_shutdown:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ret

do_reboot:
    jmp 0xFFFF:0x00

print_date:
    mov si, date_msg
    call print_string
    
    pusha
    ; Получить дату
    mov ah, 0x04
    int 0x1a  ; Получаем дату: ch - век, cl - год, dh - месяц, dl - день

    mov ah, 0x0e  ; Установить функцию для вывода символа

    ; Вывести день (dl)
    mov al, dl
    shr al, 4
    add al, '0'  ; Преобразовать в ASCII
    int 0x10     ; Выводим
    mov al, dl
    and al, 0x0F
    add al, '0'  ; Преобразовать в ASCII
    int 0x10     ; Выводим

    ; Вывести точку
    mov al, '.'
    int 0x10

    ; Вывести месяц (dh)
    mov al, dh
    shr al, 4
    add al, '0'
    int 0x10
    mov al, dh
    and al, 0x0F
    add al, '0'
    int 0x10

    ; Вывести точку
    mov al, '.'
    int 0x10

    ; Вывести год (cl)
    mov al, cl
    shr al, 4
    add al, '0'
    int 0x10
    mov al, cl
    and al, 0x0F
    add al, '0'
    int 0x10
    
    mov si, mt
    call print_string
    
    popa
    ret
    
date_msg db 'Current date: ', 0

print_time:
    mov si, time_msg
    call print_string
    
    pusha
    ; Получить время
    mov ah, 0x02
    int 0x1a  ; Получаем время: ch - часы, cl - минуты, dh - секунды

    mov ah, 0x0e  ; Установить функцию для вывода символа

    ; Вывести часы
    mov al, ch
    shr al, 4
    add al, '0'  ; Преобразовать в ASCII
    int 0x10     ; Выводим
    mov al, ch
    and al, 0x0F
    add al, '0'  ; Преобразовать в ASCII
    int 0x10     ; Выводим

    ; Вывести разделитель
    mov al, ':'
    int 0x10

    ; Вывести минуты
    mov al, cl
    shr al, 4
    add al, '0'
    int 0x10
    mov al, cl
    and al, 0x0F
    add al, '0'
    int 0x10

    ; Вывести разделитель
    mov al, ':'
    int 0x10

    ; Вывести секунды
    mov al, dh
    shr al, 4
    add al, '0'
    int 0x10
    mov al, dh
    and al, 0x0F
    add al, '0'
    int 0x10
    
    mov si, mt
    call print_string
    
    popa
    ret
    
time_msg db 'Current time: ', 0


load_program:
    mov si, load_prompt
    call print_string
    call read_number  ; Читаем номер сектора

    mov si, mt

    ; Загружаем программу с указанного сектора
    call start_program
    ret

read_number:
    mov di, number_buffer
    xor cx, cx
.read_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D      ; Проверка на Enter
    je .done_read
    cmp al, 0x08      ; Проверка на Backspace
    je .handle_backspace
    cmp cx, 5         ; Максимальная длина числа (5 цифр)
    jge .read_loop    ; Если достигнут максимум, игнорируем ввод
    cmp al, '0'       ; Проверка, что символ является цифрой
    jb .read_loop
    cmp al, '9'
    ja .read_loop
    stosb             ; Сохраняем символ в буфер
    mov ah, 0x0E      ; Выводим символ на экран
    mov bl, 0x1F
    int 0x10
    inc cx            ; Увеличиваем счётчик введённых символов
    jmp .read_loop

.handle_backspace:
    cmp cx, 0         ; Если буфер пуст, игнорируем Backspace
    je .read_loop
    dec di            ; Уменьшаем указатель буфера
    dec cx            ; Уменьшаем счётчик символов
    mov ah, 0x0E      ; Удаляем символ с экрана
    mov al, 0x08      ; Backspace
    int 0x10
    mov al, ' '       ; Пробел
    int 0x10
    mov al, 0x08      ; Снова Backspace
    int 0x10
    jmp .read_loop

.done_read:
    mov byte [di], 0  ; Завершаем строку нулевым символом
    call convert_to_number  ; Преобразуем строку в число
    ret

convert_to_number:
    mov si, number_buffer
    xor ax, ax
    xor cx, cx
.convert_loop:
    lodsb
    cmp al, 0         ; Проверка на конец строки
    je .done_convert
    sub al, '0'       ; Преобразуем символ в цифру
    imul cx, 10       ; Умножаем текущее значение на 10
    add cx, ax        ; Добавляем новую цифру
    jmp .convert_loop
.done_convert:
    mov [sector_number], cx  ; Сохраняем число в переменную
    ret

load_prompt db 'Enter sector number: ', 0
number_buffer db 6 dup(0)
sector_number dw 0

start_program:
    pusha
    mov ah, 0x02      ; Функция чтения сектора
    mov al, 1         ; Количество секторов для чтения
    mov ch, 0         ; Номер дорожки (цилиндра)
    mov dh, 0         ; Номер головки
    mov cl, [sector_number]  ; Номер сектора
    mov bx, 800h      ; Адрес, куда загружать данные
    int 0x13
    jc .disk_error    ; Если ошибка, переходим к обработке ошибки
    jmp 800h          ; Переход к загруженной программе
    popa
    ret

.disk_error:
    mov si, disk_error_msg
    call print_string
    popa
    ret

disk_error_msg db 'Disk read error!', 0


unknown_command:
    mov si, unknown_msg
    call print_string
    call print_newline
    ret

clear_screen:
    mov ax, 0x03
    int 0x10
    ret

hello_msg db 'Welcome to korpOS Aster!', 0

sysinf_str db 'fetch', 0
help_str db 'help', 0
clr_str db 'clear', 0
dat_str db 'date', 0
time_str db 'time', 0
shut_str db 'shutdown', 0
reboot_str db 'reboot', 0
load_str db 'load', 0

prompt db '[root@korpOS] >: ', 0
command_buffer db 25 dup(0)
unknown_msg db 'Unknown command.', 0
mt db 13, 10, 0

%include 'modules/fetch.asm'
%include 'modules/help.asm'
%include 'libs/io.inc'
