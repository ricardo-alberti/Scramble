; status.asm

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

    ; lifes
    mov bx, 100
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE

    mov bx, 124
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE

    mov bx, 148
    mov cx, 0
    mov si, offset jet
    call DRAW_SPRITE

    ret
SETUP_STATUS_BAR endp

;UPDATE_STATUS_BAR proc
;
;
    ;ret
;UPDATE_STATUS_BAR endp
