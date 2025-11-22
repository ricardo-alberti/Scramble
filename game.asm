; game.asm

; status HUD
INCLUDE status.asm
INCLUDE sectors.asm

DRAW_GAME proc

NEXT_SECTOR:
    mov di, [current_sector]
    cmp di, 4
    je END_WINNER
    add di, 2
    mov [current_sector], di
    mov bx, [sectors + di]
    call bx

; -----------------------
; UPDATE_GAME
; -----------------------
SECTOR_LOOP:
    call RESOLVE_INPUT
    call UPDATE_TIMER

    mov bx, [lives]
    cmp bx, 0
    je END_GAME_OVER
    ; if timer 0 go to next sector

    mov bx, [current_timer]
    cmp bx, 0
    je NEXT_SECTOR

    ; update positions and draw elements
    xor si, si
    mov cx, [active_count]
.update_elements:

    call UPDATE_POS
    mov bl, [has_moved]
    cmp bl, 0           ; if no movement dont draw
    je .continue

    push si
    push cx
    mov bx, [pos_x_high + si]
    mov cx, [pos_y_high + si]

    cmp si, 0
    jnz .set_obstacle_sprite
.set_jet_sprite:
    mov si, offset jet
    jmp .draw 
.set_obstacle_sprite:
    mov si, [obstacle_str_offset]
.draw:
    call DRAW_SPRITE
    pop cx
    pop si
.continue:
    add si, 2
    loop .update_elements

    jmp SECTOR_LOOP
; -----------------------

END_WINNER:
    mov ax, 1
    call END_SCREEN
    jmp EXIT_UPD_GAME
END_GAME_OVER:
    mov ax, 0
    call END_SCREEN
    
EXIT_UPD_GAME:
    ret
DRAW_GAME endp

; maps input to jet direction
RESOLVE_INPUT proc
    mov [shooting], 0     ; default: not shooting

READ_KEYS:
    ; Check if a key is waiting (AH=01h)
    mov ah, 01h
    int 16h
    jz RESOLVED               ; no more keys -> exit

    ; Read key (AH=00h)
    mov ah, 00h
    int 16h               ; AL = ASCII, AH = scan code

    ; ----- direction keys -----
    cmp ah, KEY_RIGHT
    jne .check_left
    or  al, RIGHT
.check_left:
    cmp ah, KEY_LEFT
    jne .check_up
    or  al, LEFT
.check_up:
    cmp ah, KEY_UP
    jne .check_down
    or  al, UP
.check_down:
    cmp ah, KEY_DOWN
    jne .check_space
    or  al, DOWN

    ; ----- space key -----
.check_space:
    cmp ah, KEY_SPACE
    jne READ_KEYS
    mov [shooting], 1
    jmp READ_KEYS

RESOLVED:
    mov [direction], al   ; apply movement mask
    ret
RESOLVE_INPUT endp

; Input:
; SI = offset (index * 2)
; Output:
; has_moved = 1 or 0
UPDATE_POS PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov [has_moved], 0

    ;----------------------------------
    ; LOAD DIRECTION for this object
    ;----------------------------------
    mov bx, si
    mov bl, [direction + bx]

    ;----------------------------------
    ; HORIZONTAL MOVEMENT
    ;----------------------------------

    ; Load X position
    mov ax, [pos_x_low  + si]
    mov dx, [pos_x_high + si]

CHECK_RIGHT:
    test bl, RIGHT
    jz CHECK_LEFT

    add ax, [speed_low  + si]
    adc dx, [speed_high + si]

    cmp dx, SCREEN_WIDTH - SPRITE_WIDTH
    jae block_right
    jmp STORE_X

wrap_left:
    cmp dx, SCREEN_WIDTH
    jb STORE_X
    xor dx, dx
    jmp STORE_X

block_right:
    mov cx, [wrap_screen]
    cmp cx, si
    jne wrap_left
    mov dx, SCREEN_WIDTH - SPRITE_WIDTH
    jmp STORE_X

CHECK_LEFT:
    test bl, LEFT
    jz STORE_X

    sub ax, [speed_low  + si]
    sbb dx, [speed_high + si]

    js wrap_right
    jmp STORE_X

wrap_right:
    mov cx, [wrap_screen]
    cmp cx, si
    je block_left
    mov dx, SCREEN_WIDTH
    jmp STORE_X

block_left:
    xor dx, dx
    jmp STORE_X

STORE_X:
    mov cx, [pos_x_high]
    cmp cx, dx
    je SAVE_X
    mov [has_moved], 1

SAVE_X:
    mov [pos_x_low  + si], ax
    mov [pos_x_high + si], dx

    ;----------------------------------
    ; VERTICAL MOVEMENT
    ;----------------------------------

    mov ax, [pos_y_low  + si]
    mov dx, [pos_y_high + si]

CHECK_UP:
    test bl, UP
    jz CHECK_DOWN

    sub ax, [speed_low  + si]
    sbb dx, [speed_high + si]

    cmp dx, SCREEN_TOP_LIMIT
    jae STORE_Y
    mov dx, SCREEN_TOP_LIMIT

CHECK_DOWN:
    test bl, DOWN
    jz STORE_Y

    add ax, [speed_low  + si]
    adc dx, [speed_high + si]

    cmp dx, SCREEN_HEIGHT - SPRITE_HEIGHT
    jb STORE_Y
    mov dx, SCREEN_HEIGHT - SPRITE_HEIGHT

STORE_Y:
    mov cx, [pos_y_high]
    cmp cx, dx
    je SAVE_Y
    mov [has_moved], 1

SAVE_Y:
    mov [pos_y_low  + si], ax
    mov [pos_y_high + si], dx

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
UPDATE_POS endp

; Input:
; bp = str offset
PRINT_PHASE proc
    push bx
    push dx

    call CLEAR_SCREEN

    mov bl, 05h ; color 
    mov dh, 12   ; line 
    mov dl, 16  ; column 
    call PRINT_STR

    mov CX, 1EH
    call DELAY
    call CLEAR_SCREEN

    pop dx
    pop bx
    ret
PRINT_PHASE endp

; Input:
; ax = 1 win or 0 loss
END_SCREEN proc
    push bx
    push dx

    call CLEAR_SCREEN

    mov [str_int_color], 0Fh
    mov [current_sector], FIRST_SECTOR   ; restart from first level

    cmp ax, 1
    je SET_WINNER
SET_GAME_OVER:
    mov bl, 04h ; color 
    mov bp, offset game_over
    mov dh, 10   ; line 
    mov dl, 0  ; column 
    call PRINT_STR
    jmp EXIT_END_SCREEN
SET_WINNER:
    mov bl, 02h ; color 
    mov bp, offset winner
    mov dh, 10   ; line 
    mov dl, 0  ; column 
    call PRINT_STR

    mov bl, 0Fh ; color
    mov bp, offset score_foreground
    mov dh, 18  ; row
    mov dl, 17 ; column
    call PRINT_STR 

    mov dh, 18  ; row
    mov dl, 21 ; column
    call SET_POS_CURSOR

    mov bx, [score_points]
    add ax, bx
    mov [score_points], ax
    mov bl, 0Fh
    call ESC_UINT16

EXIT_END_SCREEN:
    mov CX, 1EH
    call DELAY

    call CLEAR_SCREEN
    mov [menu_active], 1

    pop dx
    pop bx
    ret
END_SCREEN endp
