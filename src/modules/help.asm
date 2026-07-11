help_msg db 10, 13
         db 'fetch - Information about system', 10, 13
         db 'clear - Clears the screen', 10, 13
         db 'date - Prints current date', 10, 13
         db 'time - Prints current time', 10, 13
         db 'shutdown - Shutdown the pc', 10, 13
         db 'reboot - Reboots the pc', 10, 13
         db 'load - Programs launcher',10, 13
         db '-------- Programs --------', 10, 13
         db '7 - Hello World', 10, 13
         db '8 - PRos memory viewer', 10, 13
         db 0

do_help:
    mov si, help_msg
    call print_string
    call print_newline
    ret
