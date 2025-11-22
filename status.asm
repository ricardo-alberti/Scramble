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
    mov cx, [lives]
    mov bx, 120
DRAW_LIFE: 
    push cx
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE
    add bx, 24
    pop cx
    loop DRAW_LIFE

    ret
SETUP_STATUS_BAR endp

UPDATE_TIMER proc
    push ax
    push bx
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
    mov bl, 02h
    call ESC_UINT16

    mov ax, [sector_bonus_points]
    call UPDATE_SCORE

EXIT_TIMER:
    pop dx
    pop bx
    pop ax
    ret
UPDATE_TIMER endp

UPDATE_LIVES proc
    push bx
    push cx
    push si

    mov bx, 120
    mov cx, 0
    mov si, offset empty_sprite
    call DRAW_SPRITE
    add bx, 24
    call DRAW_SPRITE
    add bx, 24
    call DRAW_SPRITE

    ; dec lives
    mov cx, [lives]
    dec cx
    mov [lives], cx
    cmp cx, 0
    jbe EXIT_UPD_LIVES
    mov bx, 110
DRAW_PLAYER_LIFE: 
    push cx
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE
    add bx, 24
    pop cx
    loop DRAW_PLAYER_LIFE

EXIT_UPD_LIVES:
    pop si
    pop cx
    pop bx
    ret
UPDATE_LIVES endp

; Input:
; ax = score gain
UPDATE_SCORE proc
    mov bl, 02h ; color
    mov dh, 0   ; row
    mov dl, 7   ; column
    mov bp, offset score_foreground
    call PRINT_STR 

    mov dh, 0  ; row
    mov dl, 10 ; column
    call SET_POS_CURSOR

    mov bx, [score_points]
    add ax, bx
    mov [score_points], ax
    mov bl, 02h
    call ESC_UINT16

    ret
UPDATE_SCORE endp
