; game.asm

UPDATE_GAME proc

    push ax
    push bx
    push cx
    push dx
    push di
    push si

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
    ; alien
    mov si, 4
    mov [pos_y_high + si], 90 ; y stays fixed
    mov ax, [pos_x_high + si]

    cmp ax, SCREEN_WIDTH - SPRITE_WIDTH
    jae TURN_LEFT
    cmp ax, 0
    jbe TURN_RIGHT

    jmp MOVE_CONTINUE
TURN_LEFT:
    mov [direction + si], LEFT
    jmp MOVE_CONTINUE
TURN_RIGHT:
    mov [direction + si], RIGHT    
    jmp MOVE_CONTINUE
MOVE_CONTINUE:
    call UPDATE_POS
    mov bx, [pos_x_high + si]
    mov cx, [pos_y_high + si]
    mov si, offset alien
    call DRAW_SPRITE

    ; jet
    xor si, si
    mov [pos_y_high], 60 ; y
    mov [direction], RIGHT    
    call UPDATE_POS

    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov si, offset jet
    call DRAW_SPRITE

    ; meteor
    mov si, 2
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left
    call UPDATE_POS
    mov bx, [pos_x_high + si]
    mov cx, [pos_y_high + si]
    mov si, offset meteor
    call DRAW_SPRITE

    ; TODO: game logic

    pop ax
    pop bx
    pop cx
    pop dx
    pop di
    pop si
    ret
UPDATE_GAME endp
