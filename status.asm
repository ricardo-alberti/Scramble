; status.asm

; sets constant strings in status bar
SETUP_STATUS_BAR proc
    ; score
    mov bl, 0Fh ; color 
    mov dh, 0   ; line 
    mov dl, 0   ; column 
    mov bp, offset score 
    call PRINT_STR

    ; timer
    mov bl, 0Fh ; color 
    mov dh, 0   ; line 
    mov dl, 30   ; column 
    mov bp, offset timer 
    call PRINT_STR

    ; lives
    mov bx, 110
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE

    add bx, 24
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE

    add bx, 24
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE

    ret
SETUP_STATUS_BAR endp

UPDATE_TIMER proc
    push ax
    push dx

    call READ_RTC
    cmp dh, [current_rtc]
    je EXIT_TIMER

    mov [current_rtc], dh  ; updates rtc time passed

DEC_TIMER:
    mov ax, [current_timer]
    dec ax
    mov [current_timer], ax

REDRAW_TIMER:
    mov dh, 0
    mov dl, 38
    call SET_POS_CURSOR

    ; clean
    push ax
    mov ah, 0Eh
    mov al, ' '
    int 10h
    int 10h
    pop ax

    mov dh, 0
    mov dl, 38
    call SET_POS_CURSOR
    call ESC_UINT16

EXIT_TIMER:
    pop dx
    pop ax
    ret
UPDATE_TIMER endp

UPDATE_LIVES proc
    ret
UPDATE_LIVES endp

UPDATE_SCORE proc
    ret
UPDATE_SCORE endp
