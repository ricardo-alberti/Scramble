; game.asm

UPDATE_GAME proc
    push ax

    mov al, menu_active
    cmp al, 1
    je MENU_LOOP

    MENU_LOOP:
        mov BL, 2 ; color 
        mov DH, 0 ; line 
        mov DL, 0 ; column 
        mov BP, offset scramble_title 
        call PRINT_STR

        mov BL, 15 ; color 
        mov DH, 16 ; line 
        mov DL, 18 ; column 
        mov BP, offset start 
        call PRINT_STR

        mov BL, 15 ; color 
        mov DH, 19 ; line 
        mov DL, 18 ; column 
        mov BP, offset exit 
        call PRINT_STR

    ; TODO: game logic

    pop ax
    ret
UPDATE_GAME endp
