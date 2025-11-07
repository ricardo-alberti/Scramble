; game.asm

UPDATE_GAME proc
    push ax
    push di

    mov al, menu_active
    cmp al, 1
    je MENU_DRAW

    MENU_DRAW:
        mov bl, 0Ah ; color 
        mov dh, 0   ; line 
        mov dl, 0   ; column 
        mov bp, offset scramble_title 
        call PRINT_STR

        mov bl, 0Ch ; color 
        mov dh, 16  ; line 
        mov dl, 18  ; column 
        mov bp, offset start 
        call PRINT_STR

        mov bl, 15 ; color 
        mov dh, 19 ; line 
        mov dl, 18 ; column 
        mov bp, offset exit 
        call PRINT_STR

    MENU_ANIMATION:
        mov si, offset meteor
        mov bx, [pos_x + 2]
        mov cl, 60
        call DRAW_SPRITE
        ;add [pos_x + 4], 1

        mov si, offset alien
        mov bx, [pos_x + 4]
        mov cl, 90
        call DRAW_SPRITE
        ;add [pos_x + 4], 1

        mov si, offset jet
        mov bx, [pos_x]
        mov cl, 170
        call DRAW_SPRITE
        ;add [pos_x], 1

    ; TODO: game logic

    pop ax
    pop di
    ret
UPDATE_GAME endp
