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
UPD_ELEMENTS:

    push si
    push cx
    mov bx, [pos_x_high + si]
    mov cx, [pos_y_high + si]

    cmp si, 0
    jnz OBSTACLE_SPRITE
JET_SPRITE:
    mov si, offset jet
    jmp DRAW 
OBSTACLE_SPRITE:
    mov si, [obstacle_str_offset]
DRAW:
    call DRAW_SPRITE

    pop cx
    pop si

    call UPDATE_POS
    add si, 2
    loop UPD_ELEMENTS

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


; maps user input to game actions
RESOLVE_INPUT proc
    call GET_INPUT
    jnz CHECK_KEY_RIGHT  
    jmp NO_INPUT

CHECK_KEY_RIGHT:
    xor al, al 
    cmp ah, KEY_RIGHT
    jnz CHECK_KEY_LEFT
    or al, RIGHT
CHECK_KEY_LEFT:
    cmp ah, KEY_LEFT
    jnz CHECK_KEY_UP
    or al, LEFT
CHECK_KEY_UP:
    cmp ah, KEY_UP
    jnz CHECK_KEY_DOWN
    or al, UP
CHECK_KEY_DOWN:
    cmp ah, KEY_DOWN
    jnz CHECK_KEY_SPACE
    or al, DOWN
CHECK_KEY_SPACE:
    cmp ah, KEY_SPACE
    jnz RESOLVE
    mov [shooting], 1 ; sets to shoot
    jmp RESOLVE
NO_INPUT:
    ;xor ax, ax
    mov [shooting], 0 ; sets to shoot

RESOLVE:
    mov [direction], al ; change jet direction
    ret
RESOLVE_INPUT endp

; Input:
; SI = index (of object)
UPDATE_POS PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Each position has low and high bytes stored in arrays:
    ; pos_x_low[], pos_x_high[], pos_y_low[], pos_y_high[]

    ; LOAD direction
    mov bl, [direction + si]

    mov cx, si               ; CX = index

    ; HORIZONTAL
    ; Load X position
    mov si, offset pos_x_low
    add si, cx
    mov ax, [si]


    mov di, offset pos_x_high
    add di, cx
    mov dx, [di]

    ; Move right
CHECK_RIGHT:
    test bl, RIGHT
    jz CHECK_LEFT
    add ax, [speed_low]
    adc dx, [speed_high]
    cmp dx, SCREEN_WIDTH - SPRITE_WIDTH
    jae BLOCK_RIGHT
    jmp STORE_X
WRAP_LEFT:
    pop ax
    cmp dx, SCREEN_WIDTH
    jb STORE_X
    xor dx, dx               ; wrap to 0
    jmp STORE_X
BLOCK_RIGHT:
    push ax
    mov ax, [wrap_screen] 
    cmp ax, cx
    jne WRAP_LEFT
    pop ax
    mov dx, SCREEN_WIDTH - SPRITE_WIDTH
    jmp STORE_X
    
CHECK_LEFT:
    test bl, LEFT
    jz STORE_X
    sub ax, [speed_low]
    sbb dx, [speed_high]
    js WRAP_RIGHT            ; if negative
    jmp STORE_X
WRAP_RIGHT:
    push ax
    mov ax, [wrap_screen]
    cmp ax, cx
    je BLOCK_LEFT
    pop ax
    mov dx, SCREEN_WIDTH
    jmp STORE_X
BLOCK_LEFT:
    pop ax
    xor dx, dx
    jmp STORE_X

STORE_X:
    mov [si], ax
    mov [di], dx

    ; VERTICAL
    mov si, offset pos_y_low
    add si, cx
    mov ax, [si]

    mov di, offset pos_y_high
    add di, cx
    mov dx, [di]

CHECK_UP:
    test bl, UP
    jz CHECK_DOWN
    sub ax, [speed_low]
    sbb dx, [speed_high]
    cmp dx, SCREEN_TOP_LIMIT
    js BLOCK_UP
    jmp STORE_Y
BLOCK_UP:
    mov dx, SCREEN_TOP_LIMIT
    jmp STORE_Y

CHECK_DOWN:
    test bl, DOWN
    jz STORE_Y
    add ax, [speed_low]
    adc dx, [speed_high]
    cmp dx, SCREEN_HEIGHT - SPRITE_HEIGHT
    jb STORE_Y
BLOCK_DOWN:
    mov dx, SCREEN_HEIGHT - SPRITE_HEIGHT               ; wrap to 0

STORE_Y:
    mov [si], ax
    mov [di], dx

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
