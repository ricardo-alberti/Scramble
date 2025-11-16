; game.asm

;DRAW_STATUS proc

;PRINT_PHASE proc
;mov CX, 1EH
;call DELAY
;PRINT_PHASE endp

UPDATE_GAME proc
    push ax
    call CLEAR_SCREEN

;SETUP_SECTOR_ONE:
;SETUP_SECTOR_TWO:
;SETUP_SECTOR_THREE:

SECTOR_LOOP:
    ; jet
    xor si, si
    mov [pos_y_high], 60 ; y
    mov [direction], RIGHT    
    call UPDATE_POS

    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov si, offset jet
    call DRAW_SPRITE
    jmp SECTOR

EXIT_UPD_GAME:
    pop ax
    ret
UPDATE_GAME endp

; -------------------------
; MENU
UPDATE_MENU proc
    push bx
    push dx
    push bp
    push ax
    push bx
    push si

    call CLEAR_SCREEN

    ; title
    mov bl, 0Ah ; color 
    mov dh, 0   ; line 
    mov dl, 0   ; column 
    mov bp, offset scramble_title 
    call PRINT_STR

DRAW_BUTTONS:
    ; start button
    xor bx, bx
    mov bl, [active_button ]
    mov bl, [button_colors + bx]
    mov dh, 16  ; line 
    mov dl, 18  ; column 
    mov bp, offset start 
    call DRAW_BUTTON

    ; exit button
    mov bl, [active_button + 1]
    mov bl, [button_colors + bx]
    mov dh, 19 ; line 
    mov dl, 18 ; column 
    mov bp, offset exit 
    call DRAW_BUTTON

    ; animate_menu_loop
ANIMATE_MENU:
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

CHECK_INPUT:
    call GET_INPUT

    ; change button selected
    cmp AH, KEY_DOWN
    je CHANGE_BUTTON
    cmp AH, KEY_UP
    je CHANGE_BUTTON

    ; select button
    cmp AH, KEY_ENTER
    je SELECT_BUTTON

    jmp ANIMATE_MENU

CHANGE_BUTTON:
    xor [active_button], 1 ; sets active_button 0b or 1b
    xor [active_button + 1], 1 ; sets active_button 0b or 1b
    jmp DRAW_BUTTONS

SELECT_BUTTON:
    mov al, active_button
    cmp al, 0  ; exit selected
    je EXIT_BUTTON

START_BUTTON:
    mov [menu_active], 0
    jmp EXIT_UPD_MENU

EXIT_BUTTON:
    mov [exit_game], 1

EXIT_UPD_MENU:
    call CLEAR_SCREEN

    pop bx
    pop dx
    pop bp
    pop ax
    pop bx
    pop si
    ret
UPDATE_MENU endp
; -------------------------
