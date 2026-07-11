sysart      db '', 0
systeminfo  db 10, 13
            db 'korpOS Aster [x16 Edition]', 10, 13
            db 'Version: 0.0.1', 10, 13
            db 'Kernel: mandarn', 10, 13
            db 'Display: 80x25', 10, 13
            db 'skalerozik. 2024-2026', 10, 13
            db 0

do_sysinf:
    mov si, systeminfo
    call print_string
    call print_newline
    ret
