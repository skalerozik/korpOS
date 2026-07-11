sysart      db '', 0
systeminfo  db 10, 13
            db 'korpOS Aster [x16 Edition]', 10, 13
            db 'Version: 1.0', 10, 13
            db 'Kernel: korpcore-0.10-generic', 10, 13
            db 'Display: 80x25', 10, 13
            db 'Shell: korpTerm', 10, 13
            db 'Nazar Prokudin. 2024-2025', 10, 13
            db 0

do_sysinf:
    mov si, systeminfo
    call print_string
    call print_newline
    ret
