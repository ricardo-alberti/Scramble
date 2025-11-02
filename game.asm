; game.asm

UPDATE_GAME proc
    push ax

    mov al, menu_active
    cmp al, 1
    je MENU_DRAW

    MENU_DRAW:
        mov bl, 2 ; color 
        mov dh, 0 ; line 
        mov dl, 0 ; column 
        mov bp, offset scramble_title 
        call PRINT_STR

        mov bl, 15 ; color 
        mov dh, 16 ; line 
        mov dl, 18 ; column 
        mov bp, offset start 
        call PRINT_STR

        mov bl, 15 ; color 
        mov dh, 19 ; line 
        mov dl, 18 ; column 
        mov bp, offset exit 
        call PRINT_STR

    MENU_ANIMATION:
        mov si, offset jet
        mov bx, 300
        mov cl, 180
        call DRAW_SPRITE


    ; TODO: game logic

    pop ax
    ret
UPDATE_GAME endp
